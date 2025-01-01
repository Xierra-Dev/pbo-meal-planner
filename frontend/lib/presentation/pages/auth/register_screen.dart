import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/auth_service.dart';
import 'login_screen.dart';
import '../../widgets/requirement_item.dart';
import 'dart:ui';
import 'package:nutriguide/utils/navigation_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // Import mask_text_input_formatter

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _cardNumberFormatter = MaskTextInputFormatter(
      mask: '####-####-####-####'); // Masker untuk nomor kartu
  final _cvvFormatter = MaskTextInputFormatter(mask: '###');
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _expiryDateController = TextEditingController();
  final _expiryDateFormatter =
      MaskTextInputFormatter(mask: '##-##-##'); // Mask untuk Expiry Date

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedRole;
  bool _has8Characters = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;

  final AuthService _authService = AuthService();

<<<<<<< HEAD
  // Di dalam _handleRegister()
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _confirmPasswordController.text.trim(),
      );

      if (mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Animation
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Lottie.asset(
                        'assets/animations/success.json',
                        repeat: true, // Set to true untuk looping
                        animate: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Success Title with Animation
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: const Text(
                        'Registration Successful!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Success Message with Animation
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'Welcome to NutriGuide, ${_usernameController.text}!\nYour account has been created successfully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Continue Button with Animation
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          NavigationHelper.navigateToPage(
                            context,
                            const LoginScreen(),
                            replace: true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Continue to Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 1500),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, double value, child) {
                                return Transform.translate(
                                  offset: Offset(8 * sin(value * 3 * pi), 0),
                                  child: child,
                                );
                              },
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Error Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red[600],
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Error Title
                    const Text(
                      'Registration Failed',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Error Message
                    Text(
                      e.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Try Again Button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

=======
>>>>>>> parent of f725b88 (Revert "register role tapi navigasi home screen belum sesuai")
  void _checkPasswordRequirements(String password) {
    setState(() {
      _has8Characters = password.length >= 8;
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  Future<bool> _showPaymentDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium,
                      size: 48, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  Text('Premium Subscription',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  Text('Premium Features:',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('• Personalized meal plans'),
                  const Text('• Advanced nutrition tracking'),
                  const Text('• Expert consultation access'),
                  const SizedBox(height: 24),
                  Text('Monthly fee: \$5.00', // Ubah harga menjadi 5 dolar
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildCardInputFields(),
                  const SizedBox(height: 24),
                  _buildPaymentDialogActions(),
                ],
              ),
            ),
          ),
        ) ??
        false; // Ensure a boolean is returned (false if the dialog is dismissed)
  }

  Future<bool> _verifyAdminEmail() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text('Verifying Admin Credentials',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Please check your email for verification link.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('I\'ve Verified My Email'),
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Checking the role and proceeding accordingly
      if (_selectedRole == 'premium_user') {
        final paid = await _showPaymentDialog();
        if (!paid) {
          throw Exception('Payment required for premium registration');
        }
      } else if (_selectedRole == 'nutritionist_admin') {
        final isVerified = await _verifyAdminEmail();
        if (!isVerified) {
          throw Exception(
              'Admin verification required. Please check your email.');
        }
      }

      await _authService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRole ??
            'free_user', // This will fallback to 'free_user' if null
      );

      if (mounted) {
        _showRegistrationSuccessDialog();
      }
    } catch (e) {
      // Catching and passing the error as an Exception to the snack bar
      _showErrorSnackBar(e is Exception ? e : Exception(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  width: 150,
                  height: 150,
                  child: Lottie.asset('assets/animations/success.json',
                      repeat: false)),
              const SizedBox(height: 24),
              Text('Welcome to NutriGuide!',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(
                  'You\'ve successfully registered as a ${_selectedRole?.replaceAll('_', ' ') ?? ''}',
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  NavigationHelper.navigateToPage(context, const LoginScreen(),
                      replace: true);
                },
                child: const Text('Continue to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(Exception e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: InputDecoration(
            labelText: 'Select Role',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: const [
            DropdownMenuItem(value: 'free_user', child: Text('Free User')),
            DropdownMenuItem(
                value: 'premium_user', child: Text('Premium User')),
            DropdownMenuItem(
                value: 'nutritionist_admin', child: Text('Admin Ahli Gizi')),
          ],
          onChanged: (value) => setState(() => _selectedRole = value),
          validator: (value) => value == null ? 'Please select a role' : null,
        ),
        if (_selectedRole != null) ...[
          const SizedBox(height: 8),
          Text(
            _selectedRole == 'premium_user'
                ? '* Premium subscription required (\$5.00/month)'
                : _selectedRole == 'nutritionist_admin'
                    ? '* Email verification required'
                    : '',
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }

  Widget _buildCardInputFields() {
    return Column(
      children: [
        _buildTextField('Card Number',
            keyboardType: TextInputType.number,
            inputFormatters: [_cardNumberFormatter]),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTextField('Expiry Date',
                controller: _expiryDateController,
                width: 120,
                inputFormatters: [_expiryDateFormatter]),
            _buildTextField('CVV',
                width: 100,
                inputFormatters: [_cvvFormatter],
                maxLength: 3), // Max 3 digit CVV
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label,
      {TextEditingController? controller,
      TextInputType keyboardType = TextInputType.text,
      double width = double.infinity,
      bool obscureText = false,
      Function(String)? onChanged,
      List<TextInputFormatter>? inputFormatters,
      int? maxLength}) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters, // Terapkan input formatters
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        maxLength: maxLength, // Menambahkan batasan panjang untuk CVV
      ),
    );
  }

  Widget _buildPaymentDialogActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Subscribe'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  _buildRegistrationCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/hero-bg.jpg'),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(color: Colors.black.withOpacity(0.1)),
      ),
    );
  }

  Widget _buildRegistrationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create Account',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              _buildTextField('Username', controller: _usernameController),
              const SizedBox(height: 16),
              _buildTextField('Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildRoleDropdown(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(),
              const SizedBox(height: 16),
              _buildPasswordRequirements(),
              const SizedBox(height: 24),
              _buildCreateAccountButton(),
              const SizedBox(height: 16),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField('Password',
        controller: _passwordController,
        obscureText: _obscurePassword,
        onChanged: _checkPasswordRequirements);
  }

  Widget _buildConfirmPasswordField() {
    return _buildTextField('Confirm Password',
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword);
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Password Requirements:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RequirementItem(
              text: 'At least 8 characters', isMet: _has8Characters),
          RequirementItem(text: 'Contains a number', isMet: _hasNumber),
          RequirementItem(text: 'Contains a symbol', isMet: _hasSymbol),
        ],
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleRegister,
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('Create Account'),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Already have an account? Login'),
    );
  }
}
