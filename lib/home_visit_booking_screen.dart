import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_common.dart';


class HomeVisitBookingScreen extends StatefulWidget {
  const HomeVisitBookingScreen({super.key});

  @override
  State<HomeVisitBookingScreen> createState() => _HomeVisitBookingScreenState();
}

class _HomeVisitBookingScreenState extends State<HomeVisitBookingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: primaryTeal,
            indicatorColor: primaryTeal,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'حجز جديد'.tr()),
              Tab(text: 'حجوزاتي'.tr()),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _NewHomeVisitTab(
                  onBooked: () {
                    setState(() => _refreshKey++);
                    _tabController.animateTo(1);
                  },
                ),
                MyBookingsTab(key: ValueKey(_refreshKey), visitType: 'home'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// تاب: حجز جديد (زيارة منزلية)
// =====================================================
class _NewHomeVisitTab extends StatefulWidget {
  final VoidCallback onBooked;
  const _NewHomeVisitTab({required this.onBooked});

  @override
  State<_NewHomeVisitTab> createState() => _NewHomeVisitTabState();
}

class _NewHomeVisitTabState extends State<_NewHomeVisitTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String? _service;
  DateTime? _date;
  String? _slot;
  bool _saving = false;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillAddress();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _prefillAddress() async {
    try {
      final client = Supabase.instance.client;
      final uid = await getCurrentUserId();
      if (uid == null) return;

      final row = await client
          .from('users')
          .select('address')
          .eq('id', uid)
          .maybeSingle();

      final address = row?['address']?.toString() ?? '';
      if (mounted && address.isNotEmpty && _addressController.text.isEmpty) {
        _addressController.text = address;
      }
    } catch (_) {}
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? tomorrow,
      firstDate: tomorrow,
      lastDate: tomorrow.add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    final client = Supabase.instance.client;

    final userId = await getCurrentUserId();
    if (userId == null) {
      if (!mounted) return;
      _showSnack('سجل الدخول أولاً لإتمام الحجز'.tr());
      return;
    }

    if (_service == null || _date == null || _slot == null) {
      _showSnack('من فضلك اختر سبب الحجز والتاريخ والوقت'.tr());
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showSnack('من فضلك أدخل العنوان'.tr());
      return;
    }

    setState(() => _saving = true);

    try {
      await client.from('appointments').insert({
        'user_id': userId,
        'visit_type': 'home',
        'service': _service,
        'appointment_date': _date!.toIso8601String().split('T').first,
        'appointment_time': _slot,
        'address': address,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      });

      if (!mounted) return;
      _showSnack('تم إرسال طلب الحجز بنجاح'.tr());

      setState(() {
        _service = null;
        _date = null;
        _slot = null;
        _notesController.clear();
      });

      widget.onBooked();
    } catch (e) {
      if (!mounted) return;
      _showSnack('حدث خطأ أثناء الحجز: {}'.tr(args: [e.toString()]));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    InputDecoration fieldDecoration({String? label, Widget? prefix}) {
      return InputDecoration(
        labelText: label,
        prefixIcon: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.cardColor,
      );
    }

    TextStyle sectionStyle() => TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: cs.primary,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryTeal.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.home_outlined, color: primaryTeal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'سيتواصل معك المركز لتأكيد الموعد بعد إرسال الطلب.'.tr(),
                    style: TextStyle(
                        fontSize: 13, color: cs.onSurface, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('سبب الحجز:'.tr(), style: sectionStyle()),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _service,
            decoration: fieldDecoration(),
            hint: Text('حدد سبب الحجز'.tr()),
            items: serviceLabels.entries
                .map((e) => DropdownMenuItem<String>(
                      value: e.key,
                      child: Text(e.value.tr(),
                          style: const TextStyle(fontSize: 14)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _service = v),
          ),
          const SizedBox(height: 20),

          Text('تاريخ الموعد:'.tr(), style: sectionStyle()),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickDate,
            child: InputDecorator(
              decoration: fieldDecoration(
                prefix: const Icon(Icons.calendar_month, color: primaryTeal),
              ),
              child: Text(
                _date == null ? 'اختر التاريخ'.tr() : formatDate(_date!),
                style: TextStyle(
                  fontSize: 14,
                  color: _date == null ? Colors.grey : cs.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('الوقت المناسب:'.tr(), style: sectionStyle()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bookingSlots.map((slot) {
              final selected = _slot == slot;
              return ChoiceChip(
                label: Text(
                  slot,
                  style: TextStyle(
                      color: selected ? Colors.white : cs.onSurface),
                ),
                selected: selected,
                selectedColor: primaryTeal,
                showCheckmark: false,
                onSelected: (_) => setState(() => _slot = slot),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: fieldDecoration(
              label: 'العنوان'.tr(),
              prefix:
                  const Icon(Icons.location_on_outlined, color: primaryTeal),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: fieldDecoration(label: 'ملاحظات (اختياري)'.tr()),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'تأكيد الحجز'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
