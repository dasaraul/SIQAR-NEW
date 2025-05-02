<?php

namespace App\Filament\Pages\Auth;

use Filament\Pages\Auth\Login as BaseLogin;
use Filament\Http\Responses\Auth\Contracts\LoginResponse;
use Illuminate\Validation\ValidationException;

class CustomLogin extends BaseLogin
{
    // Override method authenticate dengan return type yang benar
    public function authenticate(): ?LoginResponse
    {
        $data = $this->form->getState();

        if (! $this->auth()->attempt([
            'email' => $data['email'],
            'password' => $data['password'],
        ], $data['remember'] ?? false)) {
            throw ValidationException::withMessages([
                'data.email' => __('filament-panels::pages/auth/login.messages.failed'),
            ]);
        }

        // Verifikasi user adalah admin
        $user = $this->auth()->user();
        if ($user->peran !== 'admin') {
            $this->auth()->logout();
            
            throw ValidationException::withMessages([
                'data.email' => __('Hanya admin yang dapat mengakses panel ini.'),
            ]);
        }

        // Update terakhir login
        $user->terakhir_login = now();
        $user->save();

        session()->regenerate();
        
        return $this->getLoginResponse();
    }
}