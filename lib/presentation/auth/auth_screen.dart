import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/glass_container.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'widgets/phone_otp_sheet.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    bool success = false;

    if (_tabController.index == 0) {
      success = await auth.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      success = await auth.registerWithEmail(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
      );
    }

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted && auth.errorMessage != null) {
      Fluttertoast.showToast(
        msg: auth.errorMessage!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _handleDemoLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithDemoMode();
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _showPhoneOtpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PhoneOtpSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.darkMidnight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Header Logo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.electric_bolt_rounded,
                        color: AppColors.primaryEmerald,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'VYBE CABS',
                      style: AppTypography.heading2.copyWith(letterSpacing: 2),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Welcome to Vybe', style: AppTypography.heading1),
                const SizedBox(height: 4),
                Text(
                  'Book clean, electric & luxury rides in seconds',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24),



                // Tab Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (index) {
                      FocusScope.of(context).unfocus();
                    },
                    indicator: BoxDecoration(
                      color: AppColors.primaryEmerald,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.darkMidnight,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'Sign In'),
                      Tab(text: 'Create Account'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form Fields
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_tabController.index == 1) ...[
                        CustomTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Vicky Patel',
                          prefixIcon: Icons.person_outline_rounded,
                          readOnly: auth.isLoading,
                          validator: (v) => v!.trim().isEmpty ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: '+91 98765 43210',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          readOnly: auth.isLoading,
                          validator: (v) => v!.trim().length < 10 ? 'Enter valid phone number' : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'name@domain.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: auth.isLoading,
                        validator: (v) => (!v!.contains('@')) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        readOnly: auth.isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) => v!.length < 6 ? 'Minimum 6 characters' : null,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: _tabController.index == 0 ? 'Sign In with Email' : 'Create Vybe Account',
                        isLoading: auth.isLoading,
                        onPressed: _handleAuthSubmit,
                      ),
                    ],
                  ),
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
