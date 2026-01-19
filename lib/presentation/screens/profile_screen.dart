import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import '../../core/app_colors.dart';
import 'package:mojood_app/core/core.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  Map<String, dynamic>? profile;

  User? get currentUser => supabase.auth.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      loadProfile();
    } else {
      loading = false;
    }
  }

  Future<void> loadProfile() async {
    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();

      setState(() {
        profile = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("خطأ: $e")));
    }
  }

  // ======================
  // ✏️ تعديل الملف الشخصي
  // ======================
  void showEditProfile() {
    final nameController =
        TextEditingController(text: profile?['display_name'] ?? '');
    final phoneController =
        TextEditingController(text: profile?['phone'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "تعديل الملف الشخصي",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),

              _darkField(
                controller: nameController,
                label: "الاسم",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),

              _darkField(
                controller: phoneController,
                label: "رقم الجوال",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await supabase.from('users').update({
                        'display_name': nameController.text.trim(),
                        'phone': phoneController.text.trim().isEmpty
                            ? null
                            : phoneController.text.trim(),
                      }).eq('id', currentUser!.id);

                      Navigator.pop(context);
                      await loadProfile();

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم تحديث البيانات بنجاح ✅"),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("خطأ: $e")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "حفظ",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================
  // 🌍 اللغة
  // ======================
  void showLanguageSheet() {
    final localeProvider = context.read<LocaleProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              "اختيار اللغة",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Divider(color: Colors.white24),

            ListTile(
              leading: Icon(Icons.language, color: AppColors.primary),
              title: const Text("العربية",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                localeProvider.setArabic();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.language, color: AppColors.primary),
              title: const Text("English",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                localeProvider.setEnglish();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("سجّل الدخول")),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "الملف الشخصي",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(.18),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(.45),
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      profile?['display_name']?.toString().isNotEmpty == true
                          ? profile!['display_name']
                          : "بدون اسم",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      profile?['email'] ?? currentUser!.email ?? "",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.75),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      profile?['phone'] ?? "لا يوجد رقم جوال",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.65),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Edit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: showEditProfile,
                        icon: const Icon(Icons.edit),
                        label: const Text("تعديل الملف الشخصي"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Divider(color: Colors.white24),

                    _darkTile(
                      icon: Icons.language,
                      title: "اللغة",
                      onTap: showLanguageSheet,
                    ),
                    _darkTile(
                      icon: Icons.logout,
                      title: "تسجيل الخروج",
                      color: Colors.red,
                      onTap: logout,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ======================
  // 🧱 Helpers
  // ======================
  Widget _darkTile({
    required IconData icon,
    required String title,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
      onTap: onTap,
    );
  }

  Widget _darkField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(.85)),
        filled: true,
        fillColor: AppColors.cardDark,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}