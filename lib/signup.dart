import 'package:al_sharif/languageButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String text, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }

  // حفظ الـ ID محلياً فقط في SharedPreferences
  Future<void> _saveCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);
    debugPrint('📌 Saved User ID to SharedPreferences from Signup: $userId');
  }

  // إدخال الاسم والإيميل والتليفون والعنوان فقط (بدون الباسورد نهائياً)
  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final response = await Supabase.instance.client.from('users').insert({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      }).select('id').single();

      if (response['id'] != null) {
        final userId = response['id'].toString();

        // حفظ الـ ID فقط محلياً
        await _saveCurrentUserId(userId);

        if (!mounted) return;

        _showMessage('تم إنشاء الحساب بنجاح!'.tr(), color: Colors.teal);

        Navigator.pushReplacementNamed(context, '/home', arguments: userId);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('حدث خطأ أثناء حفظ البيانات: $e'.tr(), color: Colors.red);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.teal),
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.locale;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF05857F), Color(0xFF0E1C4C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Card(
                  elevation: 10,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) {
                              return Transform.scale(
                                  scale: value, child: child);
                            },
                            child: const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.person_add,
                                  size: 40, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 18),

                          Text(
                            'إنشاء حساب جديد'.tr(),
                            style: TextStyle(
                              fontSize: 26,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 26),

                          // Name
                          TextFormField(
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration:
                            _inputDecoration('الاسم'.tr(), Icons.person),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'من فضلك أدخل اسمك'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                                'البريد الإلكتروني'.tr(), Icons.email),
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return 'من فضلك أدخل بريدك الإلكتروني'.tr();
                              }
                              final emailRegex =
                              RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                              if (!emailRegex.hasMatch(v)) {
                                return 'صيغة البريد الإلكتروني غير صحيحة'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                                'رقم الهاتف'.tr(), Icons.phone),
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return 'من فضلك أدخل رقم الهاتف'.tr();
                              }
                              final phoneRegex = RegExp(r'^\+?\d{8,15}$');
                              if (!phoneRegex.hasMatch(v)) {
                                return 'رقم الهاتف غير صحيح'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Address
                          TextFormField(
                            controller: _addressCtrl,
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.next,
                            maxLines: 2,
                            decoration: _inputDecoration(
                                'العنوان'.tr(), Icons.location_on),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'من فضلك أدخل العنوان'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field (موجود فقط في الواجهة الشكليّة ولا يُرسل للسيرفر)
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscurePass,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                                'كلمة المرور'.tr(), Icons.lock)
                                .copyWith(
                              suffixIcon: IconButton(
                                iconSize: 28,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                                splashRadius: 24,
                                tooltip: _obscurePass
                                    ? 'إظهار كلمة المرور'.tr()
                                    : 'إخفاء كلمة المرور'.tr(),
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.teal,
                                ),
                                onPressed: () => setState(
                                        () => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'من فضلك أدخل كلمة المرور'.tr();
                              }
                              if (value.length < 6) {
                                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                                    .tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscureConfirm,
                            decoration: _inputDecoration(
                                'تأكيد كلمة المرور'.tr(), Icons.lock_outline)
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                        () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'من فضلك أكد كلمة المرور'.tr();
                              }
                              if (value != _passCtrl.text) {
                                return 'كلمة المرور غير متطابقة'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _onSignUp,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.teal, Color(0xFF26A69A)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: _loading
                                      ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                      : Text(
                                    'إنشاء حساب'.tr(),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const PositionedDirectional(
              top: 0,
              end: 8,
              child: SafeArea(child: LanguageButton()),
            ),
          ],
        ),
      ),
    );
  }
}