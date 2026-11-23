import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/valora_logo.dart';
import '../../../data/services/auth_service.dart';
import '../../../state/settings_provider.dart';
import '../../../state/subscription_provider.dart';
import '../../navigation/main_navigation_screen.dart';
import '../subscription/subscription_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  final bool isStandalone;
  final bool isMandatory;

  const LoginScreen({
    super.key,
    this.onSuccess,
    this.isStandalone = false,
    this.isMandatory = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscure = true;

  // Register controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  bool _regObscure = true;
  bool _regConfirmObscure = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  void _finishAuth() {
    if (widget.onSuccess != null) {
      widget.onSuccess!();
    } else if (!widget.isMandatory && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      final sub = context.read<SubscriptionProvider>();
      if (!sub.hasAcceptedTrial) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const SubscriptionScreen(isFirstLaunch: true),
          ),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final settings = context.read<SettingsProvider>();

    try {
      await settings.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        UiFeedback.showSuccess(context, 'Bem-vindo(a) de volta, ${settings.userFirstName}!');
        _finishAuth();
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UiFeedback.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UiFeedback.showError(context, 'Erro ao entrar: $e');
      }
    }
  }



  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final settings = context.read<SettingsProvider>();

    try {
      await settings.register(
        name: _regNameController.text.trim(),
        email: _regEmailController.text.trim(),
        password: _regPasswordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        UiFeedback.showSuccess(context, 'Conta criada com sucesso! Olá, ${settings.userFirstName}!');
        _finishAuth();
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UiFeedback.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UiFeedback.showError(context, 'Erro ao criar conta: $e');
      }
    }
  }



  void _showForgotPasswordDialog() {
    final email = _loginEmailController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      try {
        final settings = context.read<SettingsProvider>();
        settings.authService.sendPasswordResetEmail(email).catchError((_) {});
      } catch (_) {}
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.softWhite,
        title: Row(
          children: [
            const Icon(Icons.lock_reset, color: AppColors.forestGreen, size: 24),
            const SizedBox(width: 8),
            Text(
              'Recuperar Senha',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
        content: Text(
          email.isNotEmpty
              ? 'Instruções para redefinir sua senha foram enviadas para:\n\n$email\n\n(No modo offline local do Valora, você pode redefinir seus dados ou entrar com outra conta a qualquer momento).'
              : 'Informe seu e-mail cadastrado no campo de login para receber as orientações de redefinição de acesso.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.subHeader, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Entendido',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.forestGreen),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isMandatory,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: (!widget.isMandatory && Navigator.of(context).canPop())
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
        ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Brand Wordmark
                  Center(
                    child: Column(
                      children: [
                        const ValoraLogo(size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Valora',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD0EAC9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Despensa consciente & sustentável',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tabs: Entrar / Criar Conta
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.forestGreen,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            offset: Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.subHeader,
                      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Entrar'),
                        Tab(text: 'Criar Conta'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tab Views
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      return _tabController.index == 0
                          ? _buildLoginForm()
                          : _buildRegisterForm();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email
          Text(
            'E-mail',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: 'seu.email@exemplo.com',
              icon: Icons.alternate_email,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Informe seu e-mail';
              if (!val.contains('@') || !val.contains('.')) return 'Informe um e-mail válido';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Senha',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
              ),
              InkWell(
                onTap: _showForgotPasswordDialog,
                child: Text(
                  'Esqueceu a senha?',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _loginObscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _loginObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.subHeader,
                ),
                onPressed: () => setState(() => _loginObscure = !_loginObscure),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Informe sua senha';
              if (val.length < 4) return 'A senha deve ter no mínimo 4 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Submit
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Entrar no Valora',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name
          Text(
            'Seu Nome',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regNameController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: 'Ex: Marcus, Helena, Ana...',
              icon: Icons.person_outline,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Informe seu nome';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Email
          Text(
            'E-mail',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: 'seu.email@exemplo.com',
              icon: Icons.alternate_email,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Informe seu e-mail';
              if (!val.contains('@') || !val.contains('.')) return 'Informe um e-mail válido';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Password
          Text(
            'Senha',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regPasswordController,
            obscureText: _regObscure,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: 'Mínimo 6 caracteres',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _regObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.subHeader,
                ),
                onPressed: () => setState(() => _regObscure = !_regObscure),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Informe uma senha';
              if (val.length < 6) return 'Mínimo de 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Confirm Password
          Text(
            'Confirmar Senha',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regConfirmPasswordController,
            obscureText: _regConfirmObscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleRegister(),
            decoration: _inputDecoration(
              hint: 'Repita a senha digitada',
              icon: Icons.lock_clock_outlined,
              suffix: IconButton(
                icon: Icon(
                  _regConfirmObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.subHeader,
                ),
                onPressed: () => setState(() => _regConfirmObscure = !_regConfirmObscure),
              ),
            ),
            validator: (val) {
              if (val != _regPasswordController.text) {
                return 'As senhas não coincidem';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Submit
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Criar Minha Conta',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.check, size: 16),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppColors.subHeader),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.forestGreen, width: 1.5),
      ),
    );
  }
}
