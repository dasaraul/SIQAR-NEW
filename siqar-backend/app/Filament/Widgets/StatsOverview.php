<?php

namespace App\Filament\Widgets;

use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use App\Models\Karyawan;
use App\Models\Absensi;
use Carbon\Carbon;

class StatsOverview extends BaseWidget
{
    protected static ?string $pollingInterval = '60s';

    protected function getStats(): array
    {
        // Hitung total karyawan
        $totalKaryawan = Karyawan::count();
        
        // Data absensi hari ini
        $today = Carbon::today();
        $totalAbsensiHariIni = Absensi::where('tanggal', $today)->count();
        
        // Hitung karyawan yang hadir hari ini (status hadir atau terlambat)
        $karyawanHadirHariIni = Absensi::where('tanggal', $today)
            ->whereIn('status', ['hadir', 'terlambat'])
            ->count();
        
        // Hitung persentase kehadiran
        $persentaseKehadiran = $totalKaryawan > 0 
            ? round(($karyawanHadirHariIni / $totalKaryawan) * 100, 2) 
            : 0;
            
        // Hitung karyawan yang terlambat hari ini
        $karyawanTerlambatHariIni = Absensi::where('tanggal', $today)
            ->where('status', 'terlambat')
            ->count();

        return [
            Stat::make('Total Karyawan', $totalKaryawan)
                ->description('Jumlah seluruh karyawan')
                ->descriptionIcon('heroicon-m-users')
                ->color('primary'),

            Stat::make('Kehadiran Hari Ini', $karyawanHadirHariIni . ' dari ' . $totalKaryawan)
                ->description('Persentase: ' . $persentaseKehadiran . '%')
                ->descriptionIcon('heroicon-m-check-badge')
                ->color('success')
                ->chart([0, 0, $persentaseKehadiran, $persentaseKehadiran, $persentaseKehadiran, $persentaseKehadiran, $persentaseKehadiran]),

            Stat::make('Keterlambatan Hari Ini', $karyawanTerlambatHariIni)
                ->description('Karyawan yang terlambat hari ini')
                ->descriptionIcon('heroicon-m-clock')
                ->color('warning'),
        ];
    }
}