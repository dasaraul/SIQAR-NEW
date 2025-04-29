import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siqar_app/providers/auth_provider.dart';
import 'package:siqar_app/utils/constants.dart';
import 'package:siqar_app/utils/validators.dart';
import 'package:siqar_app/widgets/custom_button.dart';
import 'package:siqar_app/widgets/custom_text_field.dart';
import 'package:siqar_app/widgets/loading_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isRequestSent = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _sendResetRequest() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.forgotPassword(
        _emailController.text.trim(),
      );
      
      if (success && mounted) {
        setState(() {
          _isRequestSent = true;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.message),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return LoadingOverlay(
      isLoading: authProvider.loading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lupa Password'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _isRequestSent
              ? _buildSuccessView()
              : _buildRequestForm(),
        ),
      ),
    );
  }
  
  Widget _buildRequestForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Text(
            'Reset Password',
            style: TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan email Anda untuk menerima instruksi reset password.',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          
          // Email field
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Masukkan email Anda',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 32),
          
          // Send Button
          CustomButton(
            text: 'Kirim Link Reset',
            onPressed: _sendResetRequest,
          ),
          const SizedBox(height: 16),
          
          // Back Button
          CustomButton(
            text: 'Kembali ke Login',
            onPressed: () => Navigator.pop(context),
            outlined: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Icon(
          Icons.mark_email_read,
          size: 80,
          color: AppConstants.successColor,
        ),
        const SizedBox(height: 24),
        Text(
          'Email Terkirim!',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Kami telah mengirim instruksi reset password ke email:',
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text,
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Silakan periksa email Anda dan ikuti instruksi yang diberikan untuk reset password.',
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Kembali ke Login',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}