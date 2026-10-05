import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/admin_auth_controller.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() =>
      _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await ref
        .read(adminAuthControllerProvider.notifier)
        .login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      context.go('/');
      return;
    }

    final error =
        ref.read(adminAuthControllerProvider).error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error?.toString() ??
              'Unable to sign in. Please check your credentials.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState =
        ref.watch(adminAuthControllerProvider);

    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppDimensions.spacing24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: _buildLoginCard(
                context,
                isLoading,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(
    BuildContext context,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacing32,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBranding(),

            const SizedBox(
              height: AppDimensions.spacing32,
            ),

            Text(
              'Admin Sign In',
              style: AppTextStyles.headingLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(
              height: AppDimensions.spacing8,
            ),

            const Text(
              'Sign in to access the AssetCoin administration dashboard.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(
              height: AppDimensions.spacing32,
            ),

            TextFormField(
              controller: _identifierController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Email or phone',
                hintText: 'Enter your admin email or phone',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
              validator: (value) {
                final identifier =
                    value?.trim() ?? '';

                if (identifier.isEmpty) {
                  return 'Please enter your email or phone.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: AppDimensions.spacing16,
            ),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              enabled: !isLoading,
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? 'Show password'
                      : 'Hide password',
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'Please enter your password.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: AppDimensions.spacing12,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : _showForgotPasswordMessage,
                child: const Text(
                  'Forgot password?',
                ),
              ),
            ),

            const SizedBox(
              height: AppDimensions.spacing16,
            ),

            SizedBox(
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Sign In',
                      ),
              ),
            ),

            const SizedBox(
              height: AppDimensions.spacing24,
            ),

            const Divider(),

            const SizedBox(
              height: AppDimensions.spacing16,
            ),

            const Text(
              'Authorized AssetCoin personnel only.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(
              AppDimensions.radius16,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.account_balance_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),

        const SizedBox(
          height: AppDimensions.spacing16,
        ),

        const Text(
          'AssetCoin',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(
          height: AppDimensions.spacing4,
        ),

        const Text(
          'Administration Portal',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  void _showForgotPasswordMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Admin password recovery will be available soon.',
        ),
      ),
    );
  }
}