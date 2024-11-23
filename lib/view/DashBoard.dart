import 'dart:convert';
import 'dart:ffi';

import 'package:distributers_app/dataModels/CountDashBoard.dart';
import 'package:distributers_app/dataModels/TopSalesManRes.dart';
import 'package:distributers_app/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dataModels/OutStandingDashBoard.dart';
class DashBoardContent extends StatefulWidget {
  const DashBoardContent({Key? key}) : super(key: key);

  @override
  State<DashBoardContent> createState() => _DashBoardContentState();
}

class _DashBoardContentState extends State<DashBoardContent> {
  late Future<OutStandingDashBoard> _dashboardFuture;
  double receivableBalance = 0.0;
  double payableBalance = 0.0;
  int totalOrder = 0;
  int totalInvoices = 0;
  double invAmt = 0.0;
  late Future<Map<String, dynamic>> _data;
  List<TopSalesMan> topSalesMan = [];


  @override
  void initState() {
    super.initState();
    fetchOutStandingDashboard(); // Initialize the API call
    fetchCountDashboard();
    _data = getDistributorRetailerData(
      'D000004',
      '2024-11-15',
      '2024-11-21',
      'R000001',
    );
    fetchData();
  }

  Future<void> fetchOutStandingDashboard() async {
    // Get reg_code and companyId from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? regCode = prefs.getString('reg_code');
    final int? companyId = prefs.getInt('companyId');

    // Check if values are null
    if (regCode == null || companyId == null) {
      throw Exception('Shared preferences do not contain reg_code or companyId');
    }

    // API request
    final response = await http.post(
      Uri.parse(ApiConfig.reqDashboardReceivablePayable()), // Replace with your endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "regcode": regCode,
        "companyid": companyId,
      }),
    );

    print("check body ${regCode} ${companyId}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final outstanding =  OutStandingDashBoard.fromJson(jsonResponse);
      setState(() {
        receivableBalance = outstanding.receivableBalance ?? 0.0;
        payableBalance = outstanding.payableBalance ?? 0.0;
      });
      print("check the dashboard outstanding data ${jsonResponse}");
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }

  Future<void> fetchCountDashboard() async {
    // Get reg_code and companyId from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? regCode = prefs.getString('reg_code');
    final int? companyId = prefs.getInt('companyId');

    // Check if values are null
    if (regCode == null || companyId == null) {
      throw Exception('Shared preferences do not contain reg_code or companyId');
    }

    // API request
    final response = await http.post(
      Uri.parse(ApiConfig.reqDashboardcountOrder()), // Replace with your endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "dist_id": regCode,
        "companyid": companyId,
      }),
    );

    print("check body ${regCode} ${companyId}");

    if (response.statusCode == 200) {
      print("HERE");
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      final outstanding =  CountDashBoard.fromJson(jsonResponse);
      setState(() {
        invAmt = outstanding.invamt ?? 0.0;
        totalOrder = outstanding.totalOrder ?? 0;
        totalInvoices = outstanding.totalInvoice ?? 0;
      });
      print("hhhhhhhhhhhhhhhhhhhhhhhhhhhh:   ${totalOrder}");
      print("check the dashboard outstanding data ${jsonResponse}");
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }

  Future<Map<String, dynamic>> getDistributorRetailerData(String distid, String startDate, String endDate, String rid) async {
    final url = Uri.parse(
      'http://182.70.116.222:8000/get_distributor_retailer_comparison?'
          'distid=$distid&startDate=$startDate&endDate=$endDate&rid=$rid',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {
        'data': responseData['data'],
        'check_high_score': responseData['check_high_score'],
      };
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }


  Future<TopSalesManRes?> fetchTopSalesManData({
    required String regcode,
    required String startDate,
    required String endDate,
    required String companyid,
  }) async {
    final String baseUrl = ApiConfig.reqGet_top_10_salesmen(); // Replace with your API URL

    // Construct query parameters
    final Map<String, String> queryParams = {
      'regcode': regcode,
      'startDate': startDate,
      'endDate': endDate,
      'companyid': companyid,
    };

    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      // API call
      final http.Response response = await http.get(uri);

      // Check for successful response
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return TopSalesManRes.fromJson(jsonResponse);
      } else {
        // Handle non-200 responses
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Error occurred while fetching data: $e');
      return null;
    }
  }

  void fetchData() async {
    final String regcode = 'D000004';
    final String startDate = '2024-11-01';
    final String endDate = '2024-11-25';
    final String companyid = '1';

    final TopSalesManRes? result = await fetchTopSalesManData(
      regcode: regcode,
      startDate: startDate,
      endDate: endDate,
      companyid: companyid,
    );

    if (result != null) {
      print('Status Code: ${result.statusCode}');
      topSalesMan = result.data! ;
      print('fhfdhgfh: ${json.encode(topSalesMan)}');
    } else {
      print('Failed to fetch data.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 100,left: 24,right: 24,bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                _buildQuickStats(isTablet),
                const SizedBox(height: 24),
                FutureBuilder<Map<String, dynamic>>(
                  future: _data,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _buildRevenueSection(true, snapshot.data!['data'], snapshot.data!['check_high_score']);
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                const SizedBox(height: 24),
                if (isTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildOrdersTable()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildActiveRetailers()),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildOrdersTable(),
                      const SizedBox(height: 24),
                      _buildActiveRetailers(),
                    ],
                  ),
                const SizedBox(height: 24),
                _buildProductPerformance(isTablet),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductPerformance(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product Performance',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Export'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Sales')),
                DataColumn(label: Text('Revenue')),
                DataColumn(label: Text('Growth')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Status')),
              ],
              rows: [
                _buildProductRow(
                  'iPhone 13 Pro',
                  '842',
                  '₹84.2L',
                  '+12.4%',
                  '124',
                  'In Stock',
                ),
                _buildProductRow(
                  'Samsung S22',
                  '634',
                  '₹63.4L',
                  '+8.7%',
                  '82',
                  'Low Stock',
                ),
                _buildProductRow(
                  'OnePlus 10',
                  '542',
                  '₹54.2L',
                  '-2.4%',
                  '0',
                  'Out of Stock',
                ),
                _buildProductRow(
                  'Google Pixel 7',
                  '421',
                  '₹42.1L',
                  '+5.6%',
                  '45',
                  'In Stock',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1000,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = [
                            'iPhone',
                            'Samsung',
                            'OnePlus',
                            'Pixel'
                          ];
                          if (value.toInt() < titles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                titles[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 200,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[200],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _createBarGroup(0, 842),
                    _createBarGroup(1, 634),
                    _createBarGroup(2, 542),
                    _createBarGroup(3, 421),
                    _createBarGroup(4, 1000),

                  ],
                ),
              ),
            ),
          ],

      ),
    );
  }

  DataRow _buildProductRow(
      String product,
      String sales,
      String revenue,
      String growth,
      String stock,
      String status,
      ) {
    return DataRow(
      cells: [
        DataCell(Text(product)),
        DataCell(Text(sales)),
        DataCell(Text(revenue)),
        DataCell(
          Text(
            growth,
            style: TextStyle(
              color: growth.startsWith('+') ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DataCell(Text(stock)),
        DataCell(_buildStockStatus(status)),
      ],
    );
  }

  Widget _buildStockStatus(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'in stock':
        color = Colors.green;
        break;
      case 'low stock':
        color = Colors.orange;
        break;
      case 'out of stock':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  BarChartGroupData _createBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue[700],
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back, Admin',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isTablet) {
    final stats = [
      _StatItem(
        icon: Icons.shopping_cart,
        label: 'Total Orders',
        value: '$totalOrder',
        growth: '+12.5%',
        color: Colors.blue,
      ),
      _StatItem(
        icon: Icons.person,
        label: 'Total Invoices',
        value: '$totalInvoices',
        growth: '+8.2%',
        color: Colors.green,
      ),
      _StatItem(
        icon: Icons.store,
        label: 'Invoice Amount',
        value: '$invAmt',
        growth: '+5.7%',
        color: Colors.purple,
      ),
      _StatItem(
        icon: Icons.pending_actions,
        label: 'Receivable',
        value: '₹$receivableBalance',
        growth: '-2.4%',
        color: Colors.orange,
        isNegative: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isTablet ? 1.14 : 1.05,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: stat.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(stat.icon, color: stat.color),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stat.isNegative
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stat.growth,
                      style: TextStyle(
                        color: stat.isNegative ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                stat.value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.label,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueSection(bool isTablet, List<dynamic> data, int checkHighScore) {
    print("Data received: ${data.toString()}");

    // Current date and last 7 days
    final DateTime currentDate = DateTime.now();
    final List<DateTime> last7Days = List.generate(
      7,
          (index) => currentDate.subtract(Duration(days: index)),
    ).reversed.toList();

    // Debug: Print last 7 days
    print("Last 7 Days: ${last7Days.map((date) => date.toIso8601String()).toList()}");

    // Prepare spots for distributor_count line chart
    final List<FlSpot> distributorSpots = last7Days.map((date) {
      final matchingData = data.firstWhere(
            (item) =>
        DateTime.parse(item['odate']).toLocal().year == date.year &&
            DateTime.parse(item['odate']).toLocal().month == date.month &&
            DateTime.parse(item['odate']).toLocal().day == date.day,
        orElse: () => {'distributor_count': 0, 'retailer_count': 0},
      );

      final xValue = last7Days.indexOf(date).toDouble();
      final yValue = matchingData['distributor_count']?.toDouble() ?? 0.0;

      print("Distributor -> Date: ${date.toIso8601String()}, Count: $yValue");
      return FlSpot(xValue, yValue);
    }).toList();

    // Prepare spots for retailer_count line chart
    final List<FlSpot> retailerSpots = last7Days.map((date) {
      final matchingData = data.firstWhere(
            (item) =>
        DateTime.parse(item['odate']).toLocal().year == date.year &&
            DateTime.parse(item['odate']).toLocal().month == date.month &&
            DateTime.parse(item['odate']).toLocal().day == date.day,
        orElse: () => {'distributor_count': 0, 'retailer_count': 0},
      );

      final xValue = last7Days.indexOf(date).toDouble();
      final yValue = matchingData['retailer_count']?.toDouble() ?? 0.0;

      print("Retailer -> Date: ${date.toIso8601String()}, Count: $yValue");
      return FlSpot(xValue, yValue);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distributor & Retailer Count Overview',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: checkHighScore.toDouble(),
                minX: 0,
                maxX: (last7Days.length - 1).toDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < last7Days.length) {
                          return Text(
                            DateFormat('dd/MM').format(last7Days[index]),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: distributorSpots,
                    isCurved: true,
                    color: Colors.blue[700],
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue[700]!.withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: retailerSpots,
                    isCurved: true,
                    color: Colors.green[400],
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green[400]!.withOpacity(0.1),
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


  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            'Last 6 months',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[700],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Orders',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Code')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Amount')),
              ],
              rows: [
                for (var salesMan in topSalesMan)
                  _buildOrderRow(
                    salesMan.regcode ?? 'N/A',       // Order Number or Region Code
                    salesMan.sman ?? 'N/A',         // Salesman Name
                    salesMan.status ?? 'Unknown',   // Order Status
                    '₹${salesMan.invamt?.toString() ?? '0'}', // Invoice Amount
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow  _buildOrderRow(String orderId,
      String customer,
      String status,
      String amount,) {
    return DataRow(
      cells: [
        DataCell(Text(orderId)),
        DataCell(Text(customer)),
        DataCell(_buildStatusChip(status)),
        DataCell(Text(amount)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActiveRetailers() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Retailers',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: Colors.blue[700],
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: '25%',
                    color: Colors.green[600],
                    radius: 45,
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: Colors.orange[400],
                    radius: 40,
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: Colors.purple[300],
                    radius: 35,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickStatsCarousel extends StatefulWidget {
  const QuickStatsCarousel({Key? key}) : super(key: key);

  @override
  _QuickStatsCarouselState createState() => _QuickStatsCarouselState();
}

class _QuickStatsCarouselState extends State<QuickStatsCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildStatCard(_StatItem stat, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      transform: Matrix4.identity()..scale(isActive ? 1.05 : 1.0), // Apply transform here
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(stat.icon, color: stat.color),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: stat.isNegative
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    stat.growth,
                    style: TextStyle(
                      color: stat.isNegative ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              stat.value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.label,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        (stats.length / 3).ceil(),
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.blue
                : Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220, // Adjusted height to accommodate the cards
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: (stats.length / 3).ceil(),
            itemBuilder: (context, pageIndex) {
              // Calculate the start and end indices for the current page
              int start = pageIndex * 3;
              int end = start + 3;
              List<_StatItem> pageStats = stats.sublist(
                  start,
                  end > stats.length ? stats.length : end
              );

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pageStats.map((stat) {
                  int statIndex = stats.indexOf(stat);
                  return Expanded(
                    child: _buildStatCard(
                        stat,
                        statIndex == _currentPage * 3 ||
                            statIndex == _currentPage * 3 + 1 ||
                            statIndex == _currentPage * 3 + 2
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildPageIndicator(),
      ],
    );
  }

  // Your existing _StatItem class remains the same
  final List<_StatItem> stats = [
    _StatItem(
      icon: Icons.shopping_cart,
      label: 'Total Orders',
      value: '2,543',
      growth: '+12.5%',
      color: Colors.blue,
    ),
    _StatItem(
      icon: Icons.person,
      label: 'Active Users',
      value: '1,234',
      growth: '+8.2%',
      color: Colors.green,
    ),
    _StatItem(
      icon: Icons.store,
      label: 'Active Retailers',
      value: '487',
      growth: '+5.7%',
      color: Colors.purple,
    ),
    _StatItem(
      icon: Icons.pending_actions,
      label: 'Receivable',
      value: '₹50,000',
      growth: '-2.4%',
      color: Colors.orange,
      isNegative: true,
    ),
  ];
}

// Existing _StatItem class definition
class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final String growth;
  final Color color;
  final bool isNegative;

  _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.growth,
    required this.color,
    this.isNegative = false,
  });
}