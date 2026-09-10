import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../providers/auth_provider.dart';
import '../../home/home_screen.dart';

class PhoneOtpSheet extends StatefulWidget {
  const PhoneOtpSheet({super.key});

  @override
  State<PhoneOtpSheet> createState() => _PhoneOtpSheetState();
}

class _PhoneOtpSheetState extends State<PhoneOtpSheet> {
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _otpController = TextEditingController(text: '849201');
  bool _otpSent = false;
  final int _timerSeconds = 30;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_phoneController.text.trim().length >= 10) {
      setState(() => _otpSent = true);
    }
  }

  Future<void> _verifyOtp() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithPhoneOtp(
      _phoneController.text.trim(),
      _otpController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassContainer(
        blur: 24,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _otpSent ? 'Enter 6-Digit OTP' : 'Phone Verification',
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 6),
            Text(
              _otpSent
                  ? 'We sent a verification code to ${_phoneController.text}'
                  : 'Enter your mobile number to receive a one-time password',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 20),
            if (!_otpSent) ...[
              CustomTextField(
                controller: _phoneController,
                label: 'Mobile Number',
                hint: '+91 98765 43210',
                prefixIcon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Send Verification Code',
                onPressed: _sendOtp,
                icon: Icons.sms_outlined,
              ),
            ] else ...[
              CustomTextField(
                controller: _otpController,
                label: '6-Digit Verification Code',
                hint: '849201',
                prefixIcon: Icons.lock_clock_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Resend code in ${_timerSeconds}s', style: AppTypography.caption),
                  TextButton(
                    onPressed: () => setState(() => _otpSent = false),
                    child: Text('Change Number', style: AppTypography.caption.copyWith(color: AppColors.primaryEmerald)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Verify & Sign In',
                isLoading: auth.isLoading,
                onPressed: _verifyOtp,
                icon: Icons.check_circle_outline_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
