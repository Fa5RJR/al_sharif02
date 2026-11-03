import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:al_sharif/ai.dart';
import 'package:al_sharif/price.dart';
import 'package:al_sharif/settings.dart';
import 'package:al_sharif/rehabVideosScreen.dart';
import 'home_visit_booking_screen.dart';
import 'booking_common.dart';
import 'center_booking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryTeal = Color(0xFF20A6A0);

  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboardContent(),
    const PriceEstimationScreen(),
    const RehabVideosScreen(),
    const CenterBookingScreen(),
    const HomeVisitBookingScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مراكز الشريف للأطراف الصناعية'.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > 4 ? 4 : _currentIndex,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'الرئيسية'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calculate),
            label: 'حاسبة الأسعار'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.self_improvement),
            label: 'التأهيل النفسي'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.event_available),
            label: 'حجز موعد'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: 'زيارة منزلية'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'الإعدادات'.tr(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryTeal,
        child: const Icon(Icons.smart_toy, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SmartAssistantScreen(),
            ),
          );
        },
      ),
    );
  }
}

class HomeDashboardContent extends StatefulWidget {
  const HomeDashboardContent({super.key});

  @override
  State<HomeDashboardContent> createState() => _HomeDashboardContentState();
}

class _HomeDashboardContentState extends State<HomeDashboardContent> {
  static const Color primaryTeal = Color(0xFF20A6A0);

  bool isGridView = true;
  late Future<List> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProductsFromSupabase();
  }

  Future<List> _fetchProductsFromSupabase() async {
    final response = await Supabase.instance.client
        .from('products')
        .select();

    return List.from(response);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأطراف الصناعية'.tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.primary),
              ),
              IconButton(
                icon: Icon(
                  isGridView ? Icons.list : Icons.grid_view,
                  color: primaryTeal,
                ),
                onPressed: () {
                  setState(() {
                    isGridView = !isGridView;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'استعراض الأنواع الرئيسية للأطراف الصناعية المتاحة داخل المركز.'.tr(),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          FutureBuilder<List>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: primaryTeal),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'حدث خطأ أثناء تحميل المنتجات: {}'.tr(args: [snapshot.error.toString()]),
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      'لا توجد منتجات حالياً'.tr(),
                      style: TextStyle(fontSize: 15, color: cs.primary),
                    ),
                  ),
                );
              }

              return isGridView
                  ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildCard(
                    title: product['name'] ?? '',
                    desc: product['description'] ?? product['base_price']?.toString() ?? '',
                    isGrid: true,
                  );
                },
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildCard(
                      title: product['name'] ?? '',
                      desc: product['description'] ?? product['base_price']?.toString() ?? '',
                      isGrid: false,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required String desc, required bool isGrid}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isGrid ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            maxLines: isGrid ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
          ),
        ],
      ),
    );
  }
}