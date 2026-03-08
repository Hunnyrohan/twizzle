import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/widgets/space_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _identifier.dispose();
    _pass.dispose();
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
                        padding: const EdgeInsets.all(4), // Space for clipping
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
                            color: Colors.white, // Ensure white background for the badge
                            child: Image.asset(
                              'assets/images/app_logo.jpeg',
                              height: 100, // Slightly larger for better detail
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.flutter_dash,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .shimmer(duration: 3.seconds, color: Colors.blue.withOpacity(0.2)),
                    
                    const SizedBox(height: 48),

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
                                const Text(
                                  'Log in to Twizzle',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                                
                                const SizedBox(height: 32),
                                
                                _buildGlassTextField(
                                  controller: _identifier,
                                  label: 'Email or Username',
                                  icon: Icons.person_outline,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                                
                                const SizedBox(height: 20),
                                
                                _buildGlassTextField(
                                  controller: _pass,
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  isObscure: _obscure,
                                  toggleObscure: () => setState(() => _obscure = !_obscure),
                                  validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                                ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                                
                                const SizedBox(height: 12),
                                
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(color: Color(0xff1DA1F2), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 700.ms),
                                
                                const SizedBox(height: 24),
                                
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final ok = await prov.loginUser(
                                          _identifier.text,
                                          _pass.text,
                                        );
                                        if (!mounted) return;
                                        if (ok) {
                                          Navigator.pushReplacementNamed(context, '/home');
                                        } else {
                                          if (prov.needsReactivation) {
                                            _showReactivationDialog(context, _identifier.text, _pass.text);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.redAccent,
                                                content: Text(prov.error ?? 'Login failed'),
                                              ),
                                            );
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
                                        : const Text(
                                            'Log In',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                          ),
                                  ),
                                ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9)),
                                
                                const SizedBox(height: 20),
                                
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text('OR', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                    Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                                  ],
                                ).animate().fadeIn(delay: 900.ms),
                                
                                const SizedBox(height: 20),
                                
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final ok = await prov.loginWithGoogle();
                                      if (!mounted) return;
                                      if (ok) {
                                        Navigator.pushReplacementNamed(context, '/home');
                                      } else if (prov.error.isNotEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.redAccent,
                                            content: Text(prov.error),
                                          ),
                                        );
                                      }
                                    },
                                    icon: Image.network(
                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                                      height: 24,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                                    ),
                                    label: const Text(
                                      'Continue with Google',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 1000.ms).scale(begin: const Offset(0.9, 0.9)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),

                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xff1DA1F2),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1000.ms),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white70),
                tooltip: 'Server Settings',
                onPressed: () => Navigator.pushNamed(context, '/server-settings'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
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
      ),
      validator: validator,
    );
  }

  void _showReactivationDialog(BuildContext context, String identifier, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff15202b),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reactivate your account?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your account is currently deactivated. Would you like to reactivate it and log in?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final prov = context.read<UserProvider>();
              Navigator.pop(context); // Close dialog
              
              final success = await prov.loginUser(identifier, password, confirmReactivate: true);
              if (success && mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1DA1F2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Yes, Reactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
