import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:twizzle/features/verification/data/services/payment_service.dart';
import 'package:twizzle/injection_container.dart';
import 'package:url_launcher/url_launcher.dart';
// If using universal_html for web redirect
// import 'dart:html' as html; 

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = false;
  final _paymentService = sl<PaymentService>();

  Future<void> _initiateVerification() async {
    setState(() => _isLoading = true);
    try {
      final res = await _paymentService.initiateVerification();
      if (res['success'] == true) {
        final data = res['data'];
        final gatewayUrl = data['gatewayUrl'];
        final params = Map<String, dynamic>.from(data['params']);

        if (kIsWeb) {
          _submitWebForm(gatewayUrl, params);
        } else {
          _launchMobilePayment(gatewayUrl, params);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submitWebForm(String url, Map<String, dynamic> params) {
    // In a real app with universal_html:
    /*
    final form = html.FormElement()
      ..method = 'POST'
      ..action = url;
    
    params.forEach((key, value) {
      form.append(html.InputElement()
        ..type = 'hidden'
        ..name = key
        ..value = value.toString());
    });
    
    html.document.body?.append(form);
    form.submit();
    */
    
    // Alternative: Use a helper JS function through dart:js
    print('Redirecting to eSewa Web... $url with $params');
    // For now, let's just attempt to launch URL if eSewa allows GET (test env often does)
    // but production usually requires POST.
    _launchUrlWithFallback(url, params);
  }

  void _launchMobilePayment(String url, Map<String, dynamic> params) {
    print('Launching eSewa Mobile... $url with $params');
    _launchUrlWithFallback(url, params);
  }

  Future<void> _launchUrlWithFallback(String url, Map<String, dynamic> params) async {
    // To handle POST on mobile, usually we'd use a WebView that can inject a form and submit it.
    // Or redirect the user to a backend endpoint that redirects them with the form.
    // For this implementation, we'll assume the URL launcher can at least reach the gateway.
    final uri = Uri.parse(url).replace(queryParameters: params.map((k, v) => MapEntry(k, v.toString())));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Twizzle Verified')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Get the blue badge',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Verified users get priority in search and notifications, and show everyone they are the real deal.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _initiateVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Verify with eSewa (NPR 199)'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
