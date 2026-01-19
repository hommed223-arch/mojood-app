import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscure = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
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

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى تعبئة الحقول المطلوبة")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // ✅ إنشاء حساب Auth
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      // (اختياري لاحقاً) تقدر تضيف إدخال جدول users هنا
      // إذا عندك جدول users وتبغى تخزن الاسم/الجوال

      if (!mounted) return;

      // لو عندك Email confirmation ممكن يكون session = null
      final needsConfirm = res.session == null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            needsConfirm
                ? "تم إنشاء الحساب ✅ تحقق من البريد ثم سجل دخولك"
                : "تم إنشاء الحساب ✅ سجل دخولك الآن",
          ),
        ),
      );

      Navigator.pop(context); // رجوع لتسجيل الدخول
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "إنشاء حساب",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),

                // ✅ عنوان بسيط
                const Text(
                  "ابدأ معانا الآن",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "سجّل بياناتك وخلّ الحجز أسهل",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.75),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // ✅ الاسم
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _decor(
                    hint: "الاسم",
                    icon: Icons.person_outline,
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ البريد (LTR)
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

                // ✅ الجوال (اختياري)
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decor(
                      hint: "رقم الجوال (اختياري)",
                      icon: Icons.phone_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ كلمة المرور
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  style: const TextStyle(color: Colors.white),
                  decoration: _decor(
                    hint: "كلمة المرور",
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white.withOpacity(.85),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ✅ زر إنشاء
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: loading ? null : signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(.45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : const Text(
                            "إنشاء حساب",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ رجوع لتسجيل الدخول
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(.85),
                  ),
                  child: const Text(
                    "عندي حساب؟ تسجيل الدخول",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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