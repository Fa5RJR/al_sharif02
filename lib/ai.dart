import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SmartAssistantScreen extends StatefulWidget {
  const SmartAssistantScreen({super.key});

  @override
  State<SmartAssistantScreen> createState() => _SmartAssistantScreenState();
}

class _SmartAssistantScreenState extends State<SmartAssistantScreen> {
  static const Color primaryNavy = Color(0xFF123653);
  static const Color primaryTeal = Color(0xFF20A6A0);

  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'isWelcome': true, // بيتترجم وقت العرض عشان يتغير مع اللغة
      'text': 'مرحباً بك! أنا المساعد الذكي لمراكز الشريف للأطراف الصناعية. كيف يمكنني مساعدتك اليوم؟',
    },
  ];

  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _callCerebrasAPI(String promptText) async {
    const String apiKey = "csk-vf8f3fyfyjdhwjwkm8xxh26w6np6c5tn64jwh8xkhm2nej94";
    const String url = "https://api.cerebras.ai/v1/chat/completions";

    // نقرأ لغة التطبيق قبل أي await
    final isEnglish = context.locale.languageCode == 'en';
    final systemPrompt = isEnglish
        ? "You are a smart assistant for Al-Sharif Prosthetics Centers in Egypt. Answer patients' questions in a professional, accurate, and supportive manner in English."
        : "أنت مساعد ذكي مخصص لمراكز الشريف للأطراف الصناعية في مصر. أجب على استفسارات المرضى بأسلوب مهني، دقيق، وداعم باللغة العربية.";

    setState(() {
      _isTyping = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "qwen-3.8-27b",
          "messages": [
            {
              "role": "system",
              "content": systemPrompt,
            },
            {
              "role": "user",
              "content": promptText
            }
          ],
          "max_completion_tokens": 1024,
          "temperature": 0.2,
          "top_p": 1,
          "stream": false,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final aiResponse = data['choices'][0]['message']['content'];

        setState(() {
          _messages.add({
            'isUser': false,
            'text': aiResponse.trim(),
          });
        });
      } else {
        debugPrint("Cerebras Error Response: ${response.body}");
        setState(() {
          _messages.add({
            'isUser': false,
            'text': 'عذراً، حدث خطأ من الخادم ({}).'.tr(args: [response.statusCode.toString()]),
          });
        });
      }
    } catch (e) {
      debugPrint("Cerebras Exception: $e");
      if (!mounted) return;
      setState(() {
        _messages.add({
          'isUser': false,
          'text': 'تأكد من اتصالك بالإنترنت أو قيود المتصفح (CORS).'.tr(),
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty || _isTyping) return;

    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
      });
    });
    _messageController.clear();

    _callCerebrasAPI(text);
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // عشان الشاشة تتبني من جديد لما اللغة تتغير

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'المساعد الذكي'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: primaryTeal.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.psychology_outlined, color: primaryTeal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'اسأل المساعد الذكي عن الأطراف الصناعية والتكاليف.'.tr(),
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.9)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryTeal),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'جاري كتابة الرد...'.tr(),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'اكتب استفسارك هنا...'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: cs.surfaceContainerHighest,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: primaryTeal,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final bool isUser = msg['isUser'];
    final cs = Theme.of(context).colorScheme;

    // رسالة الترحيب بس هي اللي بتتترجم، باقي الرسائل بتتعرض زي ما هي
    final String text = msg['isWelcome'] == true
        ? (msg['text'] as String).tr()
        : msg['text'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 18,
              backgroundColor: primaryNavy,
              child: Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? primaryTeal : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 18),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : cs.onSurface,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}