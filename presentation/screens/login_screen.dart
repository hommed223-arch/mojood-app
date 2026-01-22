import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_screen.dart';
import 'package:mojood_app/core/app_colors.dart';
import 'main_layout_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (loading) return;

    setState(() => loading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.cardDark,
          content: Text(
            "خطأ: $e",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
    );
  }

  InputDecoration _decor({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(.70), fontSize: 15),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(.85)),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.cardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.borderDark.withOpacity(.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:
            BorderSide(color: AppColors.primary.withOpacity(.9), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // 🔵 Logo
                Center(
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.06),
                      border: Border.all(color: AppColors.borderDark),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                          color: AppColors.primary.withOpacity(.20),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/logo/mojood_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "مرحباً بك",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "بالتجربة الرقمية الأفضل",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.75),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 28),

                // 📧 Email
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decor(
                      hint: "البريد الإلكتروني",
                      icon: Icons.mail_outline,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔒 Password
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  style: const TextStyle(color: Colors.white),
                  decoration: _decor(
                    hint: "كلمة المرور",
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white.withOpacity(.85),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 🔘 Login
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: loading ? null : signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : const Text(
                            "تسجيل الدخول",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // 📝 Register
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "إنشاء حساب جديد",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.85),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ⚡ Guest
                InkWell(
                  onTap: continueAsGuest,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(.65)),
                      color: Colors.white.withOpacity(.04),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 22,
                          offset: const Offset(0, 14),
                          color: AppColors.primary.withOpacity(.18),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt,
                            color:
                                AppColors.secondary.withOpacity(.95)),
                        const SizedBox(width: 8),
                        const Text(
                          "الدخول كضيف",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}