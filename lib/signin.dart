import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _riveAsset = 'assets/animation/13321-25212-auth-teddy.riv';

  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMIBool? _isPeeking;
  SMINumber? _numLook;
  SMITrigger? _successTrigger;
  SMITrigger? _failTrigger;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    emailFocusNode.addListener(() {
      _isChecking?.value = emailFocusNode.hasFocus;
    });
    passwordFocusNode.addListener(() {
      _isHandsUp?.value = passwordFocusNode.hasFocus;
      if (passwordFocusNode.hasFocus) _isChecking?.value = false;
    });
  }

  void _onRiveInit(Artboard artboard) {
    final controller =
    StateMachineController.fromArtboard(artboard, 'Login Machine');
    if (controller == null) {
      debugPrint('Rive: State machine "Login Machine" not found');
      return;
    }
    artboard.addController(controller);

    _isChecking = controller.findSMI<SMIBool>('isFocus');
    _isHandsUp = controller.findSMI<SMIBool>('isPrivateField');
    _isPeeking = controller.findSMI<SMIBool>('isPrivateFieldShow');
    _numLook = controller.findSMI<SMINumber>('numLook');
    _successTrigger = controller.findSMI<SMITrigger>('successTrigger');
    _failTrigger = controller.findSMI<SMITrigger>('failTrigger');
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // دالة لحفظ الـ ID الخاص بالمستخدم محلياً
  Future<void> saveCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);
  }

  // (اختياري) دالة لحذف الـ ID عند تسجيل الخروج لاحقاً
  Future<void> clearCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  // التحقق من وجود الإيميل وحفظ الـ id
  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    _isChecking?.value = false;
    _isHandsUp?.value = false;
    _isPeeking?.value = false;

    if (!formKey.currentState!.validate()) {
      _failTrigger?.fire();
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('email', _emailCtrl.text.trim())
          .maybeSingle();

      if (response != null) {
        // المستخدم موجود في الداتابيز: نحفظ الـ id عشان باقي الشاشات تعرفه
        final userId = response['id'].toString();
        await saveCurrentUserId(userId);

        _successTrigger?.fire();
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        // يمكنك تمرير الـ id مباشرة مع الانتقال لو أردت عبر arguments
        Navigator.of(context).pushReplacementNamed('/home', arguments: userId);
      } else {
        // المستخدم غير مسجل مسبقاً
        await clearCurrentUserId(); // تنظيف أي بيانات قديمة احتياطياً
        _failTrigger?.fire();
        if (mounted) {
          _showMessage('البريد الإلكتروني غير مسجل، قم بإنشاء حساب جديد'.tr());
        }
      }
    } catch (e) {
      _failTrigger?.fire();
      if (mounted) _showMessage('حصل خطأ، حاول تاني: $e'.tr());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale;

    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Text(
          'تسجيل الدخول'.tr(),
          style: const TextStyle(
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: isKeyboardVisible ? 150 : 260,
                width: double.infinity,
                child: RiveAnimation.asset(
                  _riveAsset,
                  fit: BoxFit.contain,
                  onInit: _onRiveInit,
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      focusNode: emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide:
                          const BorderSide(color: Color(0xFF0A2152)),
                        ),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'ادخل البريد الإلكتروني'.tr();
                        final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(v);
                        if (!ok) return 'البريد الإلكتروني غير صحيح'.tr();
                        return null;
                      },
                      // تم تصحيح الخطأ هنا (إضافة علامة الضرب *)
                      onChanged: (value) {
                        _numLook?.value = (value.length * 2.0).clamp(0.0, 80.0);
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _passCtrl,
                      focusNode: passwordFocusNode,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور'.tr(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() => _obscure = !_obscure);
                            _isPeeking?.value = !_obscure;
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide:
                          const BorderSide(color: Color(0xFF0A2152)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ادخل كلمة المرور'.tr();
                        }
                        if (value.length < 6) {
                          return 'كلمة المرور قصيرة'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
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
                          'دخول'.tr(),
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟'.tr(),
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/signup'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'إنشاء حساب'.tr(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}