import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/widgets/space_background.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
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
                              height: 100,
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
                                const Text(
                                  'Join Twizzle',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                                
                                const Text(
                                  'Experience the new era of social connection.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ).animate().fadeIn(delay: 300.ms),
                                
                                const SizedBox(height: 32),
                                
                                _buildGlassField(
                                  ctrl: _name,
                                  label: 'Full Name',
                                  icon: Icons.person_outline,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                                
                                const SizedBox(height: 16),
                                
                                _buildGlassField(
                                  ctrl: _username,
                                  label: 'Username',
                                  icon: Icons.alternate_email,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                                
                                const SizedBox(height: 16),
                                
                                _buildGlassField(
                                  ctrl: _email,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboard: TextInputType.emailAddress,
                                  validator: (v) => v!.contains('@') ? null : 'Invalid email',
                                ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                                
                                const SizedBox(height: 16),
                                
                                _buildGlassField(
                                  ctrl: _pass,
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  obscure: _obscure,
                                  suffix: IconButton(
                                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                  validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                                ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.1),
                                
                                const SizedBox(height: 32),
                                
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final newUser = User(
                                          id: '',
                                          name: _name.text,
                                          username: _username.text,
                                          email: _email.text,
                                          password: _pass.text,
                                          token: '',
                                        );
                                        final ok = await prov.registerUser(newUser);
                                        if (!mounted) return;
                                        if (ok) {
                                          Navigator.pushReplacementNamed(context, '/login');
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.redAccent,
                                              content: Text(prov.error ?? 'Signup failed'),
                                            ),
                                          );
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
                                            'Create Account',
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
                                        } else if (prov.error != null && prov.error!.isNotEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.redAccent,
                                              content: Text(prov.error!),
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
                                        'Sign up with Google',
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

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Log In',
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
        ],
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5)),
        suffixIcon: suffix,
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
