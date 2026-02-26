import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/widgets/space_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _newPass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _codeSent = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _newPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<UserProvider>();
    return Scaffold(
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with glow and animation
                    Animate(
                      effects: const [
                        FadeEffect(duration: Duration(milliseconds: 1000)),
                        ScaleEffect(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff1DA1F2).withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            color: Colors.white,
                            child: Image.asset(
                              'assets/images/app_logo.jpeg',
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.flutter_dash,
                                size: 40,
                                color: Color(0xff1DA1F2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .shimmer(duration: 3.seconds, color: Colors.blue.withOpacity(0.2)),
                    
                    const SizedBox(height: 32),

                    // Glassmorphic Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _codeSent ? 'Reset Password' : 'Find Your Account',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                                
                                const SizedBox(height: 12),
                                
                                Text(
                                  _codeSent 
                                    ? 'Enter the 6-digit code sent to your email and your new password.'
                                    : 'Enter the email associated with your account to change your password.',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ).animate().fadeIn(delay: 300.ms),
                                
                                const SizedBox(height: 32),
                                
                                if (!_codeSent) 
                                  _buildGlassField(
                                    controller: _email,
                                    label: 'Email Address',
                                    icon: Icons.email_outlined,
                                    validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
                                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1)
                                else ...[
                                  _buildGlassField(
                                    controller: _code,
                                    label: '6-Digit Code',
                                    icon: Icons.vpn_key_outlined,
                                    validator: (v) => v!.length != 6 ? 'Enter 6 digits' : null,
                                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                                  
                                  const SizedBox(height: 16),
                                  
                                  _buildGlassField(
                                    controller: _newPass,
                                    label: 'New Password',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    isObscure: _obscure,
                                    toggleObscure: () => setState(() => _obscure = !_obscure),
                                    validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                                ],
                                
                                const SizedBox(height: 32),
                                
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        if (!_codeSent) {
                                          final msg = await prov.forgotPassword(_email.text);
                                          if (!mounted) return;
                                          if (msg != null) {
                                            setState(() => _codeSent = true);
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.error)));
                                          }
                                        } else {
                                          final ok = await prov.resetPassword(_code.text, _newPass.text);
                                          if (!mounted) return;
                                          if (ok) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successful!')));
                                            Navigator.pop(context);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.error)));
                                          }
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff1DA1F2),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: prov.isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                          )
                                        : Text(
                                            _codeSent ? 'Reset Password' : 'Send Code',
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                          ),
                                  ),
                                ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                                
                                const SizedBox(height: 16),
                                
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Back to Login',
                                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 800.ms),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.5),
                ),
                onPressed: toggleObscure,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xff1DA1F2), width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }
}

