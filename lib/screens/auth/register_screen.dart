import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../navigation/main_nav_scaffold.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _countryController = TextEditingController(text: 'USA');
  final _zipController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      country: _countryController.text.trim(),
      zipCode: _zipController.text.trim(),
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavScaffold()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Registration failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join Earth DNA to scan footwear and track environmental footprint.',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Jane Doe',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your full name' : null,
                ),
                const SizedBox(height: 18),

                CustomTextField(
                  controller: _emailController,
                  label: 'Email address',
                  hint: 'jane@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 18),

                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Min 6 characters',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _countryController,
                        label: 'Country',
                        hint: 'USA',
                        prefixIcon: Icons.flag_outlined,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _zipController,
                        label: 'Zip Code',
                        hint: '10001',
                        prefixIcon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  text: 'Create Account',
                  isLoading: auth.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.textDarkSecondary, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

