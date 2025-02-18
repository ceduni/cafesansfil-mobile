import 'package:flutter/material.dart';
import 'package:app/config.dart';
import 'package:app/models/Cafe.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/provider/order_provider.dart';
import 'package:app/provider/stock_provider.dart';
import 'package:app/provider/navbar_provider.dart';
import 'package:app/screens/side%20bar/side_bar.dart';
import 'package:app/widgets/Color%20list%20chart/color_list_chart.dart';
import 'package:app/widgets/alert_notification_widget.dart';
import 'package:app/widgets/histogram/custom_bar_chart.dart';
import 'package:app/widgets/Date%20selector/year_picker_widget.dart';
import 'package:app/widgets/histogram/histogram_legend.dart';
import 'package:app/widgets/metric_card.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:app/styles/dashboard_styles.dart';
import 'package:app/screens/dashboard/async_card.dart';
import 'package:app/widgets/expendable_card.dart';

class Dashboard extends StatefulWidget {
    const Dashboard({super.key});

    @override
    State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
    @override
    void initState() {
        super.initState();
        _fetchData();
    }

    Future<void> _fetchData() async {
        // We trigger both fetches without blocking the header.
        // Any errors can be handled inside each section.
        context.read<OrderProvider>().fetchOrders();
        context.read<StockProvider>().fetchStock();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        drawer: const Sidebar(),
        appBar: AppBar(
            title:  Text(
                AppLocalizations.of(context)!.pagesTitles_dashboardTitle,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, // Extra bold
                    fontSize: 24,
                    color: Colors.blueAccent, 
                ),
            ),
            surfaceTintColor: Config.specialBlue,
            actions: [
                Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: AlertNotificationWidget(
                    listOfProductsName: context.watch<StockProvider>().lowStockProcductName),
                ),
            ],
        ),
        body: RefreshIndicator(
            onRefresh: _fetchData,
            child: DashboardContent(), 
        ) ,
        );
    }
}

class DashboardContent extends StatelessWidget {

    List<Widget> _buildAlerts(BuildContext context) {
        // Replace the below logic with your actual conditions.
        int lowStockCount = 3;
        int volunteerHours = 5;
        List<Widget> alerts = [];

        if (lowStockCount > 0) {
            alerts.add(ExpandableAlertCard(
                title: "Low Stock Alert",
                message: "There are $lowStockCount items running low. Please review inventory.",
                buttonText: "View Inventory",
                // This will update the bottom nav index to 1.
                onNavigate: () {
                Provider.of<BottomNavProvider>(context, listen: false).updateIndex(3);
                },
            ));
        }
        if (volunteerHours < 10) {
            alerts.add(const ExpandableAlertCard(
                title: "Volunteer Alert",
                message: "Volunteer hours are low today.",
                buttonText: "Manage Volunteers",
                onNavigate: null, // You can define another navigation action if needed.
            ));
        }

        return alerts;
    }

    @override
    Widget build(BuildContext context) {
        return Scrollbar(
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
            children: [
                CafeCard(),
                const SizedBox(height: 20.0),
                ..._buildAlerts(context),
                ProfitSection(),
                const SizedBox(height: 20.0),
                PeriodSelectorSection(),
                const SizedBox(height: 20.0),
                HistogramSection(),
                const SizedBox(height: 10.0),
                SalesByCategorySection(),
            ],
            ),
        ),
        );
    }
}

class CafeCard extends StatelessWidget {
  const CafeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cafe = Provider.of<CafeProvider>(context, listen: false).selectedCafe;
    if (cafe == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      // Solid background color without any gradient or shadow.
      decoration: BoxDecoration(
        color: Color.fromRGBO(55, 55, 55, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Circular logo (a bit larger)
          CircleAvatar(
            radius: 50, // increased radius for a larger logo
            backgroundImage: NetworkImage(cafe.imageUrl),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 16),
          // Cafe information (name and additional info)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cafe name in uppercase with slightly smaller font size
                Text(
                  cafe.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18, // smaller font size compared to before
                  ),
                ),
                const SizedBox(height: 8),
                // Additional information about the cafe
                const Text(
                  'Volunteers: 12',
                  style: TextStyle(color: Colors.white70, fontSize: 16,),
                ),
                const Text(
                  'Volunteers: 12 | Hours: 8 AM - 8 PM',
                  style: TextStyle(color: Colors.white70, fontSize: 16,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfitSection extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return AsyncCard(
        isLoading: orderProvider.isLoading,
        hasError: orderProvider.hasError,
        errorMessage: orderProvider.errorMessage,
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Expanded(
            child: MetricCard(
                title: AppLocalizations.of(context)!.turnover_text,
                value: orderProvider.turnOver,
            ),
            ),
            const SizedBox(width: 16),
            Expanded(
            child: MetricCard(
                title: AppLocalizations.of(context)!.profits_text,
                value: orderProvider.profit,
            ),
            ),
        ],
        ),
    );
    }
}

class PeriodSelectorSection extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
                color: Color(0xE5E4E2),
                borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    Text(AppLocalizations.of(context)!.choose_period, style: AppStyles.sectionTitle.copyWith(color: Color(0x222222))),
                    YearPickerWidget(),
                ],
            ),
        );
    }
}

class HistogramSection extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                color: Config.specialBlueLighter,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                    ),
                ],
                ),
                child: Column(
                children: [
                    const SizedBox(height: 10),
                    Text(AppLocalizations.of(context)!.turnovers_and_Profits_text,
                        style: AppStyles.metricValue),
                    const SizedBox(height: 10.0),
                    SizedBox(
                    height: 211,
                    child: CustomBarChart(
                        allValues: context.watch<OrderProvider>().valueForHistogram,
                        type: 0,
                    ),
                    ),
                    HistogramLegend(
                        title: AppLocalizations.of(context)!.turnover_text,
                        color: const Color(0xFF1abc9c)),
                    HistogramLegend(
                        title: AppLocalizations.of(context)!.profits_text,
                        color: const Color(0xFF3498db)),
                ],
                ),
            ),
        );
    }
}

class SalesByCategorySection extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
                decoration: BoxDecoration(
                    color: Config.specialBlueLighter,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                    )],
                ),
                child: Column(children: [
                    Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(AppLocalizations.of(context)!.sales_by_category_title, style: AppStyles.metricValue),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ColorListChart(
                            allValues: context.watch<OrderProvider>().valueForColorChart,
                            unity: '\$',
                            orderMap: true,
                        ),
                    ),
                ]),
            ),
        );
    }
}
