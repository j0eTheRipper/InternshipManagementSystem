import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_management_system/api/headhunter.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/Widgets/text_field.dart';

class HeadhunterRegisterPage extends StatefulWidget {
  const HeadhunterRegisterPage({super.key});

  @override
  State<HeadhunterRegisterPage> createState() => _HeadhunterRegisterPageState();
}

class _HeadhunterRegisterPageState extends State<HeadhunterRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyEmailController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyNameController.dispose();
    _companyEmailController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await registerHeadhunter(
        fullname: _fullnameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        companyName: _companyNameController.text.trim(),
        companyEmail: _companyEmailController.text.trim(),
      );
      await AuthState.login(result.headhunter, token: result.token);

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Register as Headhunter",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Represent your company and post internship opportunities',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF717182),
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _fullnameController,
                  hintText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Company Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _companyNameController,
                  hintText: 'Company Name',
                  prefixIcon: const Icon(Icons.business_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your company name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _companyEmailController,
                  hintText: 'Company Email (optional)',
                  prefixIcon: const Icon(Icons.alternate_email_outlined),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _onRegister,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Register', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Already have an account? Sign in',
                    style: TextStyle(
                      color: Color(0xFF717182),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
