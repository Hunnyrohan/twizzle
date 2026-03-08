import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/core/api/dio_client.dart';
import 'package:twizzle/core/config/app_config.dart';
import 'package:twizzle/core/services/biometric_service.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/profile_provider.dart';
import 'package:twizzle/features/verification/data/services/payment_service.dart';
import 'package:twizzle/injection_container.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  final _paymentService = sl<PaymentService>();
  late AnimationController _badgeController;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  Future<void> _initiateVerification() async {
    setState(() => _isLoading = true);
    try {
      final res = await _paymentService.initiateVerification();
      if (res['success'] == true) {
        final data = res['data'];
        final params = Map<String, dynamic>.from(data['params']);
        final txnUuid = params['transaction_uuid'];

        // Backend checkout route which serves the auto-submitting POST form
        final baseUrl = DioClient.getResolvedBaseUrl();
        final checkoutUrl = '$baseUrl/api/payments/esewa/checkout/$txnUuid';
        print('🚀 PAYMENT: Loading Checkout URL: $checkoutUrl');
        
        if (mounted) {
          BiometricService.pauseLock();
          _showPaymentWebView(checkoutUrl);
        }
      }
    } catch (e) {
      print('🚀 PAYMENT ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPaymentWebView(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36")
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final normalizedUrl = request.url.toLowerCase();
            print('🚀 PAYMENT NAV: $normalizedUrl');
            
            // Intercept Success URL (case-insensitive and partial match)
            if (normalizedUrl.contains('/payment/esewa/success')) {
              final uri = Uri.parse(request.url);
              final data = uri.queryParameters['data'];
              print('🚀 PAYMENT SUCCESS: data found = ${data != null}');
              if (data != null) {
                Navigator.pop(context);
                _handlePaymentSuccess(data);
                return NavigationDecision.prevent;
              }
            }
            
            // Intercept Failure URL
            if (normalizedUrl.contains('/payment/esewa/failure')) {
              print('🚀 PAYMENT FAILURE DETECTED');
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('🚀 WEBVIEW START: $url');
          },
          onPageFinished: (String url) {
            print('🚀 WEBVIEW FINISH: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('🚀 WEBVIEW ERROR: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Secure Checkout',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      BiometricService.resumeLock();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // WebView Content
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                child: WebViewWidget(controller: controller),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Ensure lock is resumed if they swipe down to dismiss
      BiometricService.resumeLock();
    });
  }

  Future<void> _handlePaymentSuccess(String data) async {
    setState(() => _isLoading = true);
    try {
      // 1. Confirm with backend
      final result = await _paymentService.confirmVerificationV2(data);
      
      if (result['success'] == true) {
        // 2. Clear loading
        setState(() => _isLoading = false);
        
        // 3. Show success message
        _showSuccessMessage();
        
        // 4. Force refresh profile to show the badge
        // We'll need the current user's username for this
        if (mounted) {
           final profileProvider = context.read<ProfileProvider>();
           if (profileProvider.profileUser != null) {
             profileProvider.loadProfile(profileProvider.profileUser!.username);
           }
        }
      } else {
        throw result['message'] ?? 'Payment confirmation failed';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Confirmation Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful! Your verification is being processed.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Twizzle Verified', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
                      : [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2), const Color(0xFF81D4FA)],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Pulsing Badge
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.1).animate(
                      CurvedAnimation(parent: _badgeController, curve: Curves.easeInOut),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.verified, size: 100, color: Colors.blue),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Get the blue badge',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.blue.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Join the elite and stand out from the crowd.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Glass benefit card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildBenefitItem(
                              icon: Icons.search,
                              title: 'Priority in Search',
                              subtitle: 'Stay at the top of the list everywhere.',
                              isDark: isDark,
                            ),
                            const Divider(height: 32, color: Colors.white24),
                            _buildBenefitItem(
                              icon: Icons.notifications_active,
                              title: 'Notification Boost',
                              subtitle: 'Your interactions get noticed faster.',
                              isDark: isDark,
                            ),
                            const Divider(height: 32, color: Colors.white24),
                            _buildBenefitItem(
                              icon: Icons.star,
                              title: 'Premium Features',
                              subtitle: 'Unlock exclusive tools and styling.',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.blue)
                  else
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _initiateVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 64),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payment, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Verify with eSewa (NPR 199)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
