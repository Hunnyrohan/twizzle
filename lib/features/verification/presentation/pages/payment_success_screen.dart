import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/features/verification/data/services/payment_service.dart';
import 'package:twizzle/injection_container.dart';


class PaymentSuccessScreen extends StatefulWidget {
  final String data;

  const PaymentSuccessScreen({
    super.key,
    required this.data,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _isProcessing = true;
  String? _errorMessage;
  final _paymentService = sl<PaymentService>();

  @override
  void initState() {
    super.initState();
    _confirmPayment();
  }

  Future<void> _confirmPayment() async {
    try {
      final res = await _paymentService.confirmVerificationV2(widget.data);

      if (res['success'] == true) {
        if (mounted) {
          context.read<UserProvider>().refreshUserStatus();
          setState(() {
            _isProcessing = false;
          });
        }
        // Success! Wait a bit then go back

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                const Text('Verifying your payment...', style: TextStyle(fontSize: 18)),
              ] else if (_errorMessage != null) ...[
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text('Verification Failed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ] else ...[
                const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                const Text('Payment Successful!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Your account is now Twizzle Verified.', textAlign: TextAlign.center),
                const SizedBox(height: 32),
                const Text('Redirecting to home...', style: TextStyle(color: Colors.grey)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
