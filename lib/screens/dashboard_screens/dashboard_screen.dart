import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:retail_demand/app_colors.dart';
import 'package:retail_demand/models/prediction_state_data.dart' as psd;
import 'package:retail_demand/provider/prediction_notifier.dart';
import 'package:retail_demand/provider/theme_provider.dart';
import 'package:retail_demand/screens/dashboard_screens/competitor_insights_screen.dart';
import 'package:retail_demand/screens/dashboard_screens/forecast_screen.dart';
import 'package:retail_demand/screens/dashboard_screens/inventory_planner_screen.dart';
import 'package:retail_demand/screens/dashboard_screens/price_predictor_screen.dart';
import 'package:retail_demand/screens/dashboard_screens/prediction_summary.dart';
import 'package:retail_demand/screens/dashboard_screens/upload_data_screen.dart';
import 'package:retail_demand/screens/home_page.dart';
import 'package:retail_demand/screens/dashboard_screens/dashboard_card_model.dart';
import 'package:retail_demand/widgets/dashhboard_card_widget.dart';
// Optional: keep if you plan to show it under the summary
// import 'package:retail_demand/widgets/mape_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final predictionState = ref.watch(predictionNotifierProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context, ref, themeMode),
      body: _buildDashboardBody(context, predictionState),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("Retail Demand Dashboard", style: GoogleFonts.poppins()),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
  ) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: ListView(
              children: [
                _drawerItem("Forecast", Icons.analytics, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForecastScreen()),
                  );
                }),
                _drawerItem("Price Predictor", Icons.trending_up, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PricePredictorScreen(),
                    ),
                  );
                }),
                _drawerItem("Competitor Insights", Icons.business, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CompetitorInsightsScreen(),
                    ),
                  );
                }),
                _drawerItem("Inventory Planner", Icons.inventory, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryPlannerScreen(),
                    ),
                  );
                }),
                _drawerItem("Upload Sales Data", Icons.upload_file, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UploadDataScreen()),
                  );
                }),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      _buildThemeSwitch(ref, themeMode),
                      const SizedBox(height: 20),
                      _buildLogoutTile(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        "Welcome!",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      accountEmail: Text(
        "Retail Dashboard",
        style: GoogleFonts.poppins(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.store, size: 36, color: AppColors.textPrimary),
      ),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
    );
  }

  Widget _buildDashboardBody(
    BuildContext context,
    psd.PredictionStateData predictionState,
  ) {
    // --- Compute market insight safely ---
    String marketInsight = "No data yet";
    try {
      final filtered =
          predictionState.displayedData
              .where((d) => d['predicted'] != null && d['date'] != null)
              .toList();
      if (filtered.isNotEmpty) {
        final best = filtered.reduce(
          (a, b) => (a['predicted'] as num) >= (b['predicted'] as num) ? a : b,
        );
        final bestVal = (best['predicted'] as num?)?.toDouble() ?? 0.0;
        final bestDate = (best['date'] as String?) ?? 'Unknown';
        marketInsight = "Peak ${bestVal.toStringAsFixed(2)} on $bestDate";
      }
    } catch (_) {
      marketInsight = "No data yet";
    }

    // --- Forecast accuracy string ---
    final forecastAccuracy =
        predictionState.mape.isNaN
            ? "N/A"
            : "${predictionState.mape.toStringAsFixed(2)}%";

    // --- Date range ---
    final dateRange =
        predictionState.displayedData.isNotEmpty
            ? "${predictionState.displayedData.first['date'] ?? 'N/A'} → ${predictionState.displayedData.last['date'] ?? 'N/A'}"
            : "N/A";

    // --- Cards ---
    final List<DashboardCardModel> cards = [
      DashboardCardModel(
        title: "Market Insights",
        icon: Icons.insights,
        color: Colors.purple, // Fixed typo from Colors Cache.purple
        subtitle: marketInsight,
        onTap: () {
          if (predictionState.status == psd.PredictionState.success &&
              predictionState.result.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PricePredictorScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No prediction result available yet"),
              ),
            );
          }
        },
      ),
      DashboardCardModel(
        title: "Forecast Accuracy",
        icon: Icons.analytics,
        color: Colors.blue,
        subtitle: "Accuracy: $forecastAccuracy",
      ),
      DashboardCardModel(
        title: "Demand Summary",
        icon: Icons.show_chart,
        color: Colors.orange,
        subtitle: "Total Predictions: ${predictionState.totalRows}",
      ),
      DashboardCardModel(
        title: "Trending Products",
        icon: Icons.trending_up,
        color: Colors.green,
      ),
      DashboardCardModel(
        title: "Regional Demand",
        icon: Icons.map,
        color: Colors.red,
      ),
      DashboardCardModel(
        title: "Prediction Confidence",
        icon: Icons.check_circle_outline,
        color: Colors.teal,
      ),
      DashboardCardModel(
        title: "Upload Sales Data",
        icon: Icons.upload_file,
        color: Colors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadDataScreen()),
          );
        },
      ),
    ];

    // --- Fixed 2-column layout ---
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: PredictionSummaryCard(
              totalPredictions: predictionState.totalRows,
              dateRange: dateRange,
              mape: predictionState.mape.isNaN ? 0.0 : predictionState.mape,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Fixed 2 cards per row
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1, // Adjusted for balanced card size
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => DashboardCardWidget(card: cards[index]),
              childCount: cards.length,
            ),
          ),
        ),
      ],
    );
  }

  ListTile _drawerItem(String title, IconData icon, [VoidCallback? onTap]) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildThemeSwitch(WidgetRef ref, ThemeMode themeMode) {
    final isDark = themeMode == ThemeMode.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.light_mode,
          size: 20,
          color: isDark ? Colors.grey : Colors.orange,
        ),
        const SizedBox(width: 8),
        Switch(
          value: isDark,
          activeColor: Colors.white,
          onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(val),
        ),
        Icon(
          Icons.dark_mode,
          size: 20,
          color: isDark ? Colors.lightBlueAccent : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          isDark ? "Dark Mode Enabled" : "Light Mode Enabled",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  ListTile _buildLogoutTile(BuildContext context) {
    return ListTile(
      title: const Text("Logout"),
      leading: const Icon(Icons.logout),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Logged out")));
      },
    );
  }
}
