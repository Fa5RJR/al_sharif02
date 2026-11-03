import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color primaryTeal = Color(0xFF20A6A0);

// كود الخدمة في الداتا بيز -> النص العربي (هو الـ key بتاع الترجمة)
const Map<String, String> serviceLabels = {
  'consultation': 'استشارة أولية',
  'measurement': 'أخذ القياسات',
  'fitting': 'تركيب الطرف الصناعي',
  'maintenance': 'صيانة دورية',
  'followup': 'متابعة وتعديل',
};

const Map<String, String> statusLabels = {
  'pending': 'قيد المراجعة',
  'confirmed': 'مؤكد',
  'cancelled': 'ملغي',
  'completed': 'مكتمل',
};

const List<String> bookingSlots = [
  '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00',
];

Color statusColor(String status) {
  switch (status) {
    case 'confirmed':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    case 'completed':
      return primaryTeal;
    default:
      return Colors.orange;
  }
}

String formatDate(DateTime d) =>
    '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

// =====================================================
// إدارة الـ user id
// =====================================================

/// المفتاح اللي بتحفظ بيه الـ id وقت تسجيل الدخول (مطابق للي في شاشة اللوجين)
const String _userIdPrefKey = 'current_user_id';

/// نادِها من شاشة اللوجين بعد نجاح تسجيل الدخول (id = users.id)
Future<void> saveCurrentUserId(String id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_userIdPrefKey, id);
  debugPrint('📌 Saved User ID to SharedPreferences: $id');
}

/// نادِها عند تسجيل الخروج
Future<void> clearCurrentUserId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_userIdPrefKey);
}

/// بتجيب id المستخدم من الـ SharedPreferences بشكل أساسي
Future<String?> getCurrentUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_userIdPrefKey);
  debugPrint('📌 Current User ID from SharedPreferences: $saved');

  if (saved != null && saved.isNotEmpty) {
    return saved;
  }

  // كاحتياطي فقط لو تم تفعيل Supabase Auth مستقبلاً
  final authId = Supabase.instance.client.auth.currentUser?.id;
  return authId;
}

// =====================================================
// تاب: حجوزاتي (مشترك - بيتفلتر حسب نوع الزيارة)
// =====================================================
class MyBookingsTab extends StatefulWidget {
  /// 'center' أو 'home'
  final String visitType;
  const MyBookingsTab({super.key, required this.visitType});

  @override
  State<MyBookingsTab> createState() => _MyBookingsTabState();
}

class _MyBookingsTabState extends State<MyBookingsTab> {
  late Future<List> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List> _fetch() async {
    final userId = await getCurrentUserId();
    if (userId == null) return [];

    final response = await Supabase.instance.client
        .from('appointments')
        .select()
        .eq('user_id', userId)
        .eq('visit_type', widget.visitType)
        .order('appointment_date', ascending: false)
        .order('appointment_time', ascending: false);
    return List.from(response);
  }

  Future<void> _cancel(dynamic id) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return;

      await Supabase.instance.client
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', id)
          .eq('user_id', userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إلغاء الحجز'.tr())),
      );
      setState(() => _future = _fetch());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء إلغاء الحجز: {}'.tr(args: [e.toString()])),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryTeal));
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'حدث خطأ أثناء تحميل الحجوزات: {}'
                    .tr(args: [snapshot.error.toString()]),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final bookings = snapshot.data ?? [];

        return RefreshIndicator(
          color: primaryTeal,
          onRefresh: () async {
            setState(() => _future = _fetch());
            await _future;
          },
          child: bookings.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Text(
                        'لا توجد حجوزات سابقة'.tr(),
                        style: TextStyle(
                            fontSize: 15, color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final b = bookings[index] as Map;
                    return _buildBookingCard(b);
                  },
                ),
        );
      },
    );
  }

  Widget _buildBookingCard(Map b) {
    final theme = Theme.of(context);
    final status = (b['status'] ?? 'pending').toString();
    final isHome = b['visit_type'] == 'home';
    final serviceKey = serviceLabels[b['service']] ?? '';
    final time = (b['appointment_time'] ?? '').toString();
    final timeShort = time.length >= 5 ? time.substring(0, 5) : time;
    final date = DateTime.tryParse((b['appointment_date'] ?? '').toString());
    final canCancel = status == 'pending' || status == 'confirmed';
    final color = statusColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHome ? Icons.home_outlined : Icons.local_hospital_outlined,
                color: primaryTeal,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  serviceKey.isEmpty ? '' : serviceKey.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (statusLabels[status] ?? status).tr(),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${isHome ? 'زيارة منزلية'.tr() : 'في المركز'.tr()} ${date == null ? '' : formatDate(date)}\n$timeShort',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          if (isHome && (b['address'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              b['address'].toString(),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
          if (canCancel) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => _cancel(b['id']),
                child: Text(
                  'إلغاء الحجز'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
