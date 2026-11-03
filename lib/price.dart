import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PriceEstimationScreen extends StatefulWidget {
  const PriceEstimationScreen({super.key});

  @override
  State<PriceEstimationScreen> createState() => _PriceEstimationScreenState();
}

class _PriceEstimationScreenState extends State<PriceEstimationScreen> {
  static const Color primaryNavy = Color(0xFF123653);
  static const Color primaryTeal = Color(0xFF20A6A0);

  dynamic _selectedProductId;
  String? _selectedActivityLevel;
  double _estimatedPrice = 0;
  bool _isCalculated = false;

  late Future<List> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProductsFromSupabase();
  }

  Future<List> _fetchProductsFromSupabase() async {
    final response = await Supabase.instance.client
        .from('price_estimation')
        .select();

    return List.from(response);
  }

  void _calculatePrice(List dbProducts) {
    if (_selectedProductId == null || _selectedActivityLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('من فضلك اختر نوع الطرف ومستوى النشاط أولاً'.tr())),
      );
      return;
    }

    // العثور على المنتج المختار باستخدام الـ id
    final selectedProduct = dbProducts.firstWhere(
          (p) => p['id'] == _selectedProductId,
      orElse: () => null,
    );

    if (selectedProduct == null) return;

    double basePrice = double.tryParse(selectedProduct['base_price'].toString()) ?? 0;
    double multiplier = 1.0;

    // المقارنة بالنص العربي الأصلي (الـ key) وليس بالنص المترجم
    if (_selectedActivityLevel == 'رياضي / عالي الحركة') {
      multiplier = 1.25;
    }

    setState(() {
      _estimatedPrice = basePrice * multiplier;
      _isCalculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'حاسبة التكاليف التقديرية'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: FutureBuilder<List>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryTeal),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ أثناء تحميل البيانات: {}'.tr(args: [snapshot.error.toString()]),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final dbProducts = snapshot.data ?? [];
          if (dbProducts.isEmpty) {
            return Center(
              child: Text(
                'لا توجد منتجات حالياً'.tr(),
                style: TextStyle(fontSize: 16, color: cs.primary),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
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
                      const Icon(Icons.info_outline, color: primaryTeal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'أدخل التفاصيل أدناه للحصول على تقدير مبدئي لتكلفة الطرف الصناعي المناسب لحالتك.'.tr(),
                          style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'اختر نوع الطرف الصناعي:'.tr(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.primary),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<dynamic>(
                  value: _selectedProductId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                  hint: Text('حدد الطرف المطلوب'.tr()),
                  items: dbProducts.map<DropdownMenuItem<dynamic>>((product) {
                    return DropdownMenuItem<dynamic>(
                      value: product['id'], // استخدام الـ id كقيمة فريدة
                      child: Text(product['name'] ?? '', style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProductId = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'مستوى النشاط اليومي:'.tr(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.primary),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedActivityLevel,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                  hint: Text('حدد طبيعة نشاطك'.tr()),
                  items: ['حركة خفيفة / يومية معتادة', 'رياضي / عالي الحركة'].map<DropdownMenuItem<String>>((String level) {
                    return DropdownMenuItem<String>(
                      value: level, // القيمة تفضل النص العربي الأصلي
                      child: Text(level.tr(), style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivityLevel = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _calculatePrice(dbProducts),
                    child: Text(
                      'احسب التكلفة التقريبية'.tr(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_isCalculated) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryNavy,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'التكلفة التقديرية المتوقعة'.tr(),
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_estimatedPrice.toStringAsFixed(0)} ${'ج.م'.tr()}',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 8),
                        Text(
                          'السعر يعتمد على القياسات الدقيقة والتقييم الطبي داخل المركز.'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}