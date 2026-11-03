import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RehabVideosScreen extends StatefulWidget {
  const RehabVideosScreen({super.key});

  @override
  State<RehabVideosScreen> createState() => _RehabVideosScreenState();
}

class _RehabVideosScreenState extends State<RehabVideosScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List _videos = [];

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  // جلب الفيديوهات من جدول videos في Supabase
  Future<void> _fetchVideos() async {
    try {
      final response = await _supabase
          .from('videos')
          .select()
          .order('id', ascending: true);

      setState(() {
        _videos = List.from(response);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل الفيديوهات: $e'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // استخراج Video ID لرابط اليوتيوب لجلب الصورة المصغرة
  String? _extractVideoId(String url) {
    try {
      final Uri uri = Uri.parse(url);
      String? videoId;

      if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      } else if (uri.host.contains('youtube.com')) {
        videoId = uri.queryParameters['v'];
      }

      if (videoId != null && videoId.contains('?')) {
        videoId = videoId.split('?').first;
      }
      return videoId;
    } catch (e) {
      return null;
    }
  }

  // فتح رابط الفيديو باستخدام url_launcher
  Future<void> _openVideoUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر فتح الرابط'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale;

    return Scaffold(
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      )
          : _videos.isEmpty
          ? Center(
        child: Text(
          'لا توجد فيديوهات متاحة حالياً'.tr(),
          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchVideos,
        color: Colors.teal,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _videos.length,
          itemBuilder: (context, index) {
            final video = _videos[index];
            final title = video['title'] ?? '';
            final channel = video['channel_name'] ?? '';
            final category = video['category'] ?? '';
            final videoUrl = video['video_url'] ?? '';
            final videoId = _extractVideoId(videoUrl);
            final thumbnailUrl = videoId != null
                ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
                : null;

            return Card(
              margin: const EdgeInsets.only(bottom: 20),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openVideoUrl(videoUrl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عرض صورة مصغرة مع زر تشغيل خفيفة جداً عابرة للثقل
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        thumbnailUrl != null
                            ? Image.network(
                          thumbnailUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error,
                              stackTrace) =>
                              Container(
                                height: 200,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                    Icons.video_library,
                                    size: 50,
                                    color: Colors.teal),
                              ),
                        )
                            : Container(
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.video_library,
                              size: 50, color: Colors.teal),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ],
                    ),

                    // تفاصيل الفيديو
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (category.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius:
                                    BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.teal.shade200),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      color: Colors.teal,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.account_circle,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  channel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
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
            );
          },
        ),
      ),
    );
  }
}