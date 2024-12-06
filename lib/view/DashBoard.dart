import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:distributers_app/dataModels/CountDashBoard.dart';
import 'package:distributers_app/dataModels/TopProductRes.dart';
import 'package:distributers_app/dataModels/TopSalesManRes.dart';
import 'package:distributers_app/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dataModels/OutStandingDashBoard.dart';
import '../dataModels/TopParrtiesRes.dart';

class Retailer {
  String? name;
  double? totalSales;
  double? percentageGrowth;
}

class DashBoardContent extends StatefulWidget {
  const DashBoardContent({Key? key}) : super(key: key);

  @override
  State<DashBoardContent> createState() => _DashBoardContentState();
}

class _DashBoardContentState extends State<DashBoardContent> {
  late Future<OutStandingDashBoard> _dashboardFuture;
  double receivableBalance = 0.0;
  double payableBalance = 0.0;
  num totalOrder = 0;
  num orderAmount = 0.0;
  num totalInvoices = 0;
  num invAmt = 0.0;
  num totalOrderPer = 0.0;
  num OrderAmtPer = 0.0;
  num totalInvoicePer = 0.0;
  num InvoiceAmtPer = 0.0;
  late Future<Map<String, dynamic>> _data;
  List<TopSalesMan> topSalesMan = [];
  List<TopProduct> topProduct = [];
  List<TopParties> topParties = [];
  late DateTime _selectedDate;
  String formattedToday = "";
  String formattedSixDaysAgo = "";
  bool isTablet = false;
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().subtract(const Duration(days: 1));
    final DateTime today = DateTime.now();
    final DateTime sixDaysAgo = today.subtract(Duration(days: 6));

    formattedToday = DateFormat('yyyy-MM-dd').format(today);
    formattedSixDaysAgo = DateFormat('yyyy-MM-dd').format(sixDaysAgo);
    fetchOutStandingDashboard(); // Initialize the API call
    fetchCountDashboard();
    _data = getDistributorRetailerData(
      formattedSixDaysAgo,
      formattedToday
    );
    fetchData();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // You can adjust this as needed
      lastDate: today, // Restrict to today
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        print("check the date ${ DateFormat('yyyy-MM-dd').format(_selectedDate)}");
        fetchOutStandingDashboard(); // Initialize the API call
        fetchCountDashboard();
        fetchData();

      });
    }
  }

  Future<String?> _getDivision() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("check the value ${prefs.getString("reg_code")}");
    return prefs.getString("reg_code"); // Replace with your key
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
    final String? grpCode = prefs.getString('grpCode');
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
        "regcode":grpCode!.isNotEmpty ? grpCode : (regCode?.substring(0, 7) ?? ''),
        "companyid": companyId,
        "toDate": DateFormat('yyyy-MM-dd').format(_selectedDate)
      }),
    );

    print("check body count ${response.body} ${DateFormat('yyyy-MM-dd').format(_selectedDate)}");

    if (response.statusCode == 200) {
      print("HERE");
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      final outstanding =  CountDashBoard.fromJson(jsonResponse);
      setState(() {
        invAmt = outstanding.invamt ?? 0;
        totalOrder = outstanding.totalOrder ?? 0;
        totalInvoices = outstanding.totalInvoice ?? 0;
        orderAmount = outstanding.totalAmtOrder ?? 0.0;
        totalOrderPer = outstanding.totalOrderPercentage ?? 0.0;
        OrderAmtPer = outstanding.totalOrderAmtPercentage ?? 0.0;
        totalInvoicePer = outstanding.totalInvoicePercentage ?? 0.0;
        InvoiceAmtPer = outstanding.invamtprecentage ?? 0.0;
      });
      print("hhhhhhhhhhhhhhhhhhhhhhhhhhhh:   ${totalOrder}");
      print("check the dashboard outstanding data ${jsonResponse}");
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }

  Future<Map<String, dynamic>> getDistributorRetailerData(String startDate, String endDate) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? grpCode = prefs.getString('grpCode');
    final String? regCode = prefs.getString('reg_code');
    final int? companyId = prefs.getInt('companyId');
    final code = grpCode!.isNotEmpty ? grpCode : (regCode?.substring(0, 7) ?? '');
    final url = Uri.parse(
      'http://182.70.116.222:8000/get_distributor_retailer_comparison?'
          'regcode=$code&fromDate=$startDate&toDate=$endDate&companyid=$companyId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("graph comparision ${responseData}");
      return {
        'data': responseData['data'],
        'check_high_score': responseData['check_high_score'],
      };
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }


  Future<TopPartiesRes?> fetchTopPartiesData({
    required String regcode,
    required String startDate,
    required String companyid,
  }) async {
    final String baseUrl = ApiConfig.reqGet_top_10_parties(); // Replace with your API URL

    // Construct query parameters
    final Map<String, String> queryParams = {
      'regcode': regcode,
      'toDate': startDate,
      'companyid': companyid,
    };

    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    print("parties body${queryParams}");

    try {
      // API call
      final http.Response response = await http.get(uri);

      // Check for successful response
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("parties data${jsonResponse}");
        return TopPartiesRes.fromJson(jsonResponse);
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


  Future<TopSalesManRes?> fetchTopSalesManData({
    required String regcode,
    required String startDate,
    required String companyid,
  }) async {
    final String baseUrl = ApiConfig.reqGet_top_10_salesmen(); // Replace with your API URL

    // Construct query parameters
    final Map<String, String> queryParams = {
      'regcode': regcode,
      'toDate': startDate,
      'companyid': companyid,
    };

    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    print("sales body${queryParams}");

    try {
      // API call
      final http.Response response = await http.get(uri);

      // Check for successful response
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("salesman data${jsonResponse}");
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

  Future<TopProductRes?> fetchTopProductData({
    required String regcode,
    required String companyid,
  }) async {
    final String baseUrl = ApiConfig.reqGet_top_100_product(); // Replace with your API URL

    // Construct query parameters
    final Map<String, String> queryParams = {
      'regcode': regcode,
      'companyid': companyid,
      'toDate': DateFormat('yyyy-MM-dd').format(_selectedDate)
    };

    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      // API call
      final http.Response response = await http.get(uri);

      // Check for successful response
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("product resss${jsonResponse}");
        return TopProductRes.fromJson(jsonResponse);
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? grpCode = prefs.getString('grpCode');
    final String? regCode = prefs.getString('reg_code');
    final int? companyId = prefs.getInt('companyId');
    final code = grpCode!.isNotEmpty ? grpCode : (regCode?.substring(0, 7) ?? '');
    final String startDate =  DateFormat('yyyy-MM-dd').format(_selectedDate);
    final String companyid = companyId.toString();

    final TopSalesManRes? result = await fetchTopSalesManData(
      regcode: code!,
      startDate: startDate,
      companyid: companyid,
    );

    if (result != null) {
      print('Status Code: ${result.statusCode}');
      topSalesMan = result.data! ;
      print('fhfdhgfh: ${json.encode(topSalesMan)}');
    } else {
      print('Failed to fetch data.');
    }


    final TopProductRes? resultPr = await fetchTopProductData(
      regcode: regCode ?? "",
      companyid: companyid,
    );

    if (resultPr != null) {
      print('Status Code: ${resultPr.statusCode}');
      setState(() {
        topProduct = resultPr.data! ;
      });
      print('fhfdhgfh: ${json.encode(topProduct)}');
    } else {
      print('Failed to fetch data.');
    }

    final TopPartiesRes? resultParty = await fetchTopPartiesData(
      regcode: regCode!,
      startDate: startDate,
      companyid: companyid,
    );

    if (resultPr != null) {
      print('Status Code: ${resultParty?.statusCode}');
      setState(() {
        topParties = resultParty!.data! ;
      });
      print('fhfdhgfh: ${json.encode(topProduct)}');
    } else {
      print('Failed to fetch data.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return
      LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

// Debugging print statement (optional, for development only)
        print("Screen width: $screenWidth, Screen height: $screenHeight");

// Adjust the tablet breakpoint to match your device
        isTablet = screenWidth >= 600;

// Check for small screen widths (e.g., <= 360)
        final isSmallScreen = screenWidth <= 360;

// Calculate dynamic card height based on screen height
// Adjust further for small screens
        final desiredCardHeight = isTablet
            ? screenHeight * 0.35 // For tablets
            : isSmallScreen
            ? screenHeight * 0.42 // Slightly taller cards for small screens
            : screenHeight * 0.39; // Default for phones



// Calculate childAspectRatio dynamically
// childAspectRatio = width / height
        const double horizontalPadding = 16.0; // Total horizontal padding (8 on each side)
        final availableWidth = screenWidth - horizontalPadding;
        final cardWidth = isTablet ? availableWidth / 2 : availableWidth;
        final childAspectRatio = cardWidth / desiredCardHeight;

// Debugging prints
        print("Card Height: $desiredCardHeight");
        print("Child Aspect Ratio: $childAspectRatio");

       return RefreshIndicator(
            onRefresh: () async {
              // Implement your refresh logic here
              try {
                // Fetch new data
                setState(() {
                  _data = getDistributorRetailerData(formattedSixDaysAgo, formattedToday); // Assuming this is your data fetching method
                  fetchOutStandingDashboard(); // Initialize the API call
                  fetchCountDashboard();
                  fetchData();
                });

                // Optional: You can add a small delay to show the refresh animation
                await Future.delayed(Duration(milliseconds: 500));
              } catch (e) {
                // Handle any errors during refresh
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to refresh. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    _buildQuickStats(isTablet,childAspectRatio),
                    const SizedBox(height: 24),
                    const SizedBox(height: 24),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _data,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return
                            RevenueSection(isTablet:isTablet,data:snapshot.data!['data'],checkHighScore: snapshot.data!['check_high_score']);
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),

                  ]),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child:
                  topProduct.isEmpty
                      ?Text("")
                      :
                  _buildProductPerformance(isTablet),
                ),
              ),
            ],
          ) ,
        );

      },
    );
  }


  Widget _buildProductPerformance(bool isTablet) {
    // State variables for pagination
    final itemsPerPage = 10;
    final ValueNotifier<bool> showAllProducts = ValueNotifier(false);
    final PageController _carouselController = PageController();
    final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

    return Container(
      height: 800,
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
        children: [
          Expanded(
            child: PageView(
              controller: _carouselController,
              onPageChanged: (index) {
                _currentPage.value = index;
              },
              children: [
                // First Page: Product Performance
                _buildProductPerformanceContent(
                  showAllProducts: showAllProducts,
                  itemsPerPage: itemsPerPage,
                ),

                // Second Page: Top Retailers
                if (topParties.isNotEmpty) _buildTopRetailersContent(),

                // Third Page: Sales Summary
                _buildTopSalesmanContent(),
              ],
            ),
          ),
          // Pagination Indicators
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (context, currentPage, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return GestureDetector(
                      onTap: () {
                        _carouselController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == currentPage
                              ? Colors.blue
                              : Colors.grey[300],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Product Performance Content
  Widget _buildProductPerformanceContent({
    required ValueNotifier<bool> showAllProducts,
    required int itemsPerPage
  }) {
    return Column(
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
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            thickness: 8,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ValueListenableBuilder<bool>(
                  valueListenable: showAllProducts,
                  builder: (context, showAll, child) {
                    final displayedProducts = showAll
                        ? topProduct
                        : topProduct.take(itemsPerPage).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DataTable(
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('Product')),
                            DataColumn(label: Text('Sales')),
                            DataColumn(label: Text('Revenue')),
                            DataColumn(label: Text('Growth')),
                            DataColumn(label: Text('Stock')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: displayedProducts.map((product) {
                            return DataRow(cells: [
                              DataCell(
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    product.pname ?? 'N/A',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ),
                              DataCell(Text(product.productQuantity.toString())),
                              DataCell(Text(product.grsamt.toString())),
                              DataCell(
                                Text(
                                  '${product.percentagediff?.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: '${product.percentagediff}%'.startsWith('+')
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(Text(product.totalStock.toString())),
                              DataCell(_buildStockStatus(product.totalStock ?? 0)),
                            ]);
                          }).toList(),
                        ),
                        if (!showAll && topProduct.length > itemsPerPage)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextButton(
                              onPressed: () => showAllProducts.value = true,
                              child: const Text('Show More'),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.only(left: 6, right: 10, bottom: 10),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: getMaxYValue(topProduct),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey[800],
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final top5Products = topProduct.take(5).toList();
                        if (value.toInt() < top5Products.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Text(
                                top5Products[value.toInt()].pname ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            _formatYAxisLabel(value.toInt()),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: getMaxYValue(topProduct) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                barGroups: topProduct
                    .take(5)
                    .map((product) => _createBarGroup(
                  topProduct.indexOf(product).toDouble(),
                  product.productQuantity?.toDouble() ?? 0,
                ))
                    .toList(),
              ),
            ),
          ),
        )
      ],
    );
  }

// Top Retailers Content
  Widget _buildTopRetailersContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Retailers',
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
        const SizedBox(height: 10),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView.builder(
              itemCount: topParties.length,
              itemBuilder: (context, index) {
                final retailer = topParties[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      retailer.partyname?[0] ?? '',
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                  title: Text(
                    retailer.partyname ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 13),
                  ),
                  subtitle: Text('Total Invoices: ${retailer.invcount}'),
                  trailing: Text(
                    '₹${retailer.invamt?.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: (retailer.invamt ?? 0) >= 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Optional: Add a pie chart or bar chart for retailers
        SizedBox(
          height: 300,
          child:BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: getMaxYValueParties(topParties),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.grey[800],
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
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
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final top5Products = topParties.take(5).toList();
                      if (value.toInt() < top5Products.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              top5Products[value.toInt()].partyname ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          _formatYAxisLabel(value.toInt()),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: getMaxYValueParties(topParties) / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[200],
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                  left: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              barGroups: topParties
                  .take(5)
                  .map((product) => _createBarGroup(
                topParties.indexOf(product).toDouble(),
                product.invamt?.toDouble() ?? 0,
              ))
                  .toList(),
            ),
          )
        ),
      ],
    );
  }

  Widget _buildTopSalesmanContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Salesman',
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
        const SizedBox(height: 10),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView.builder(
              itemCount: topSalesMan.length,
              itemBuilder: (context, index) {
                final retailer = topSalesMan[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      retailer.sman?[0] ?? '',
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                  title: Text(
                    retailer.sman ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 13),
                  ),
                  subtitle: Text('Status: ${retailer.status}'),
                  trailing: Text(
                    '₹${retailer.invamt?.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: (retailer.invamt ?? 0) >= 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Optional: Add a pie chart or bar chart for retailers
        SizedBox(
            height: 300,
            child:BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: getMaxYValueSalesman(topSalesMan),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey[800],
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final top5Products = topSalesMan.take(5).toList();
                        if (value.toInt() < top5Products.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Text(
                                top5Products[value.toInt()].sman ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            _formatYAxisLabel(value.toInt()),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: getMaxYValueSalesman(topSalesMan) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                barGroups: topSalesMan
                    .take(5)
                    .map((product) => _createBarGroup(
                  topSalesMan.indexOf(product).toDouble(),
                  product.invamt?.toDouble() ?? 0,
                ))
                    .toList(),
              ),
            )
        ),
      ],
    );
  }


// Helper method to assign consistent colors to retailers
  Color _getColorForRetailer(String? name) {
    // You can implement a more sophisticated color assignment logic
    final colors = [
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.teal[400]!,
    ];

    // Simple hash-based color selection
    return colors[name.hashCode % colors.length];
  }

  BarChartGroupData _createBarGroup(double x, double y) {
    return BarChartGroupData(
      x: x.toInt(),
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue.withOpacity(0.8),
          width: isTablet ? 30:20, // Reduced width for better spacing
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  // Helper function to format Y-axis labels
  String _formatYAxisLabel(int value) {
    // Implement a method to avoid overlapping and improve readability
    if (value == 0) return '0';

    // Use abbreviated formats for larger numbers
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    // For smaller numbers, potentially add some spacing or formatting
    return value.toString();
  }

// Helper function to get max Y value (updated for better scaling)
  double getMaxYValue(List<TopProduct> products) {
    if (products.isEmpty) return 0;

    // Find the maximum product quantity
    double maxQuantity = products
        .map((product) => product.productQuantity?.toDouble() ?? 0)
        .reduce((a, b) => a > b ? a : b);

    // Add some padding (e.g., 10-20%) to ensure all bars fit comfortably
    return maxQuantity * 1.2;
  }


  double getMaxYValueParties(List<TopParties> products) {
    if (products.isEmpty) return 0;

    // Find the maximum product quantity
    double maxQuantity = products
        .map((product) => product.invamt?.toDouble() ?? 0)
        .reduce((a, b) => a > b ? a : b);

    // Add some padding (e.g., 10-20%) to ensure all bars fit comfortably
    return maxQuantity * 1.2;
  }

  double getMaxYValueSalesman(List<TopSalesMan> products) {
    if (products.isEmpty) return 0;

    // Find the maximum product quantity
    double maxQuantity = products
        .map((product) => product.invamt?.toDouble() ?? 0)
        .reduce((a, b) => a > b ? a : b);

    // Add some padding (e.g., 10-20%) to ensure all bars fit comfortably
    return maxQuantity * 1.2;
  }


  // rows: [
  //
  //   ,
  //   _buildProductRow(
  //     'Samsung S22',
  //     '634',
  //     '₹63.4L',
  //     '+8.7%',
  //     '82',
  //     'Low Stock',
  //   ),
  //   _buildProductRow(
  //     'OnePlus 10',
  //     '542',
  //     '₹54.2L',
  //     '-2.4%',
  //     '0',
  //     'Out of Stock',
  //   ),
  //   _buildProductRow(
  //     'Google Pixel 7',
  //     '421',
  //     '₹42.1L',
  //     '+5.6%',
  //     '45',
  //     'In Stock',
  //   ),
  // ],

  Widget _buildStockStatus(num stockCount) {
    String status;
    Color color;

    if (stockCount < 10) {
      status = 'Low Stock';
      color = Colors.orange;
    } else if (stockCount <= 50) {
      status = 'Limited Stock';
      color = Colors.yellow.shade700;
    } else {
      status = 'In Stock';
      color = Colors.green;
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
        boxShadow: [
          BoxShadow(
            color: Colors.blue[900]!.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Dashboard Overview',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _selectDate(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Welcome back, Admin',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }


  String formatCurrency(num value) {
    if (value >= 10000000) {
      // Convert to Crores
      return '₹${(value / 10000000).toStringAsFixed(2)}C';
    } else if (value >= 100000) {
      // Convert to Lakhs
      return '₹${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      // Convert to Thousands
      return '₹${(value / 1000).toStringAsFixed(2)}K';
    } else {
      // Show as it is
      return '₹${value.toStringAsFixed(2)}';
    }
  }


  Widget _buildQuickStats(bool isTablet, double childAspectRatio) {
    final statsGroups = [
      [
        _StatItem(
          icon: Icons.shopping_cart,
          label: 'Total Orders',
          value: '$totalOrder',
          growth: '$totalOrderPer%',
          color: Colors.blue,
        ),
        _StatItem(
          icon: Icons.shopping_cart,
          label: 'Order Amount',
          value: '$orderAmount',
          growth: '$OrderAmtPer%',
          color: Colors.blue,
        ),
      ],
      [
        _StatItem(
          icon: Icons.store,
          label: 'Total Invoices',
          value: '$totalInvoices',
          growth: '$totalInvoicePer%',
          color: Colors.purple,
        ),
        _StatItem(
          icon: Icons.store,
          label: 'Invoice Amount',
          value: '${formatCurrency(invAmt)}',
          growth: '$InvoiceAmtPer%',
          color: Colors.purple,
        ),
      ],
      [
        _StatItem(
          icon: Icons.currency_rupee,
          label: 'Stock Value',
          value: '220',
          growth: '+12.5%',
          color: Colors.pinkAccent,
        ),
        _StatItem(
          icon: Icons.currency_rupee,
          label: 'Stock Amount',
          value: '₹35000',
          growth: '+5.7%',
          color: Colors.pinkAccent,
        ),
      ],
      [
        _StatItem(
          icon: Icons.pending_actions,
          label: 'Receivable',
          value: '${formatCurrency(receivableBalance)}',
          growth: '-2.4%',
          color: Colors.orange,
          isNegative: true,
        ),
        _StatItem(
          icon: Icons.pending_actions,
          label: 'Payable',
          value: '${formatCurrency(payableBalance)}',
          growth: '-2.4%',
          color: Colors.orange,
          isNegative: true,
        ),
      ],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: statsGroups.length,
      itemBuilder: (context, index) {
        final statGroup = statsGroups[index];
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
          child: CarouselSlider(
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              scrollDirection: Axis.vertical,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
            ),
            items: statGroup.map((stat) {
              return Column(
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
              );
            }).toList(),
          ),
        );
      },
    );
  }
  Widget _buildRevenueSection(bool isTablet, List<dynamic> data, int checkHighScore) {
    final DateTime currentDate = DateTime.now();
    final List<DateTime> last7Days = List.generate(
      7,
          (index) => currentDate.subtract(Duration(days: index)),
    ).reversed.toList();

    // State management for comparison toggle
    final ValueNotifier<bool> showComparison = ValueNotifier<bool>(false);

    // Improved data plotting with proper null handling and validation
    List<FlSpot> getSpots(String countKey, List<DateTime> dates, List<dynamic> sourceData) {
      return dates.map((date) {
        final int index = dates.indexOf(date);
        final matchingData = sourceData.firstWhere(
              (item) {
            final itemDate = DateTime.parse(item['odate']).toLocal();
            return itemDate.year == date.year &&
                itemDate.month == date.month &&
                itemDate.day == date.day;
          },
          orElse: () => {countKey: 0},
        );

        // Ensure we have valid numerical data
        double value = 0.0;
        if (matchingData[countKey] != null) {
          value = (matchingData[countKey] is int)
              ? matchingData[countKey].toDouble()
              : (matchingData[countKey] is double)
              ? matchingData[countKey]
              : 0.0;
        }

        return FlSpot(index.toDouble(), value);
      }).toList();
    }

    final List<FlSpot> distributorSpots = getSpots('distributor_count', last7Days, data);
    final List<FlSpot> retailerSpots = getSpots('retailer_count', last7Days, data);

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
                'Revenue Overview',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // New Compare Toggle Button
              TextButton.icon(
                onPressed: () {
                  showComparison.value = !showComparison.value;
                },
                icon: Icon(
                  Icons.compare_arrows,
                  color: Colors.grey[700],
                ),
                label: ValueListenableBuilder<bool>(
                  valueListenable: showComparison,
                  builder: (context, isComparing, child) {
                    return Text(
                      isComparing ? 'Remove Compare' : 'Compare',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: isTablet ? 300 : 250,
            child: ValueListenableBuilder<bool>(
              valueListenable: showComparison,
              builder: (context, showRetailers, child) {
                return LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: checkHighScore.toDouble(),
                    minX: 0,
                    maxX: (last7Days.length - 1).toDouble(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: checkHighScore > 10 ? checkHighScore / 5 : 2,
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
                          reservedSize: 35,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < last7Days.length) {
                              return Transform.rotate(
                                angle: -0.5,
                                child: SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    DateFormat('dd/MM').format(last7Days[index]),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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
                          interval: checkHighScore > 10 ? checkHighScore / 5 : 2,
                          reservedSize: 35,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
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
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.blue[700]!,
                              strokeWidth: 1,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue[700]!.withOpacity(0.1),
                        ),
                      ),
                      if (showRetailers)
                        LineChartBarData(
                          spots: retailerSpots,
                          isCurved: true,
                          color: Colors.green[400],
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.green[400]!,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green[400]!.withOpacity(0.1),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Dynamic Legend based on comparison state
          ValueListenableBuilder<bool>(
            valueListenable: showComparison,
            builder: (context, showRetailers, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Distributors', Colors.blue[700]!),
                  if (showRetailers) ...[
                    const SizedBox(width: 20),
                    _buildLegendItem('Retailers', Colors.green[400]!),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  Widget _buildOrdersTable() {
    return Container(
      height: 305, // Constrained height
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
            'Top Salesman',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 12.0,
                  horizontalMargin: 10.0,
                  columns: const [
                    DataColumn(
                      label:
                      Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    DataColumn(
                      label: Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: topSalesMan.map((salesMan) {
                    return DataRow(cells: [
                      DataCell(
                        SizedBox(
                          width: 134, // Set a fixed width for the name column
                          child: Text(
                            salesMan.sman ?? 'N/A',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      DataCell(Text(_formatCurrency(salesMan.invamt))),
                      DataCell(
                        Text(
                          salesMan.status ?? 'Unknown',
                          style: TextStyle(
                            color: _getStatusColor(salesMan.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to format currency
  String _formatCurrency(num? value) {
    if (value == null) return '₹0';
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)}C';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return '₹${value.toStringAsFixed(2)}';
    }
  }

  /// Helper to get color for status
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
            height: 200,
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


class RevenueSection extends StatefulWidget {
  final List<dynamic> data;
  final int checkHighScore;
  final bool isTablet;

  const RevenueSection({
    Key? key,
    required this.data,
    required this.checkHighScore,
    this.isTablet = false,
  }) : super(key: key);

  @override
  _RevenueSectionState createState() => _RevenueSectionState();
}

class _RevenueSectionState extends State<RevenueSection> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ValueNotifier<bool> showComparison = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    showComparison.dispose();
    super.dispose();
  }

  // Improved getSpots function to ensure accurate plotting
  List<FlSpot> getSpots(String countKey, List<DateTime> sortedDates, List<dynamic> sourceData, double animationValue) {
    return sortedDates.asMap().map((index, date) {
      // Find matching data for the specific date
      final matchingData = sourceData.firstWhere(
            (item) {
          final itemDate = DateTime.parse(item['odate']).toLocal();
          return itemDate.year == date.year &&
              itemDate.month == date.month &&
              itemDate.day == date.day;
        },
        orElse: () => null,
      );

      // Extract value safely
      double value = 0.0;
      if (matchingData != null && matchingData[countKey] != null) {
        value = (matchingData[countKey] is int)
            ? matchingData[countKey].toDouble()
            : (matchingData[countKey] is double)
            ? matchingData[countKey]
            : 0.0;
      }

      // Improved animation logic
      final totalPoints = sortedDates.length;
      final normalizedAnimationValue = animationValue * (totalPoints - 1);

      // Fully show the point if animation has reached or passed its index
      if (index <= normalizedAnimationValue) {
        // For the last point, ensure full visibility when animation is complete
        if (index == totalPoints - 1 && animationValue == 1.0) {
          return MapEntry(index, FlSpot(index.toDouble(), value));
        }

        // For points before the last, apply previous animation logic
        if (index > normalizedAnimationValue) {
          return MapEntry(index, FlSpot(index.toDouble(), 0));
        }

        // Smooth transition for points being animated
        if (index == normalizedAnimationValue.floor()) {
          final animationProgress = normalizedAnimationValue - normalizedAnimationValue.floor();
          return MapEntry(index, FlSpot(index.toDouble(), value * animationProgress));
        }

        // Show full value for points before current animating point
        return MapEntry(index, FlSpot(index.toDouble(), value));
      }

      return MapEntry(index, FlSpot(index.toDouble(), 0));
    }).values.toList();
  }


  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure dates are extracted and sorted from the input data
    final List<DateTime> sortedDates = widget.data.map((item) {
      return DateTime.parse(item['odate']).toLocal();
    }).toSet().toList()..sort();

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
                'Orders Overview',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showComparison.value = !showComparison.value;
                  _animationController.reset();
                  _animationController.forward();
                },
                icon: Icon(
                  size: 18,
                  Icons.compare_arrows,
                  color: Colors.grey[700],
                ),
                label: ValueListenableBuilder<bool>(
                  valueListenable: showComparison,
                  builder: (context, isComparing, child) {
                    return Text(
                      isComparing ? 'Remove Compare' : 'Compare',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: widget.isTablet ? 300 : 250,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ValueListenableBuilder<bool>(
                  valueListenable: showComparison,
                  builder: (context, showRetailers, _) {
                    final distributorSpots = getSpots(
                        'distributor_count',
                        sortedDates,
                        widget.data,
                        _animationController.value
                    );

                    final retailerSpots = getSpots(
                        'retailer_count',
                        sortedDates,
                        widget.data,
                        _animationController.value
                    );

                    return LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: widget.checkHighScore.toDouble() + 2, // Add some padding
                        minX: 0,
                        maxX: (sortedDates.length - 1).toDouble(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: widget.checkHighScore > 10
                              ? widget.checkHighScore / 5
                              : 2,
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
                              reservedSize: 35,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < sortedDates.length) {
                                  return Transform.rotate(
                                    angle: -0.5,
                                    child: SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        DateFormat('dd/MM').format(sortedDates[index]),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
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
                              interval: widget.checkHighScore > 10
                                  ? widget.checkHighScore / 5
                                  : 2,
                              reservedSize: 35,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
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
                          // Distributor line
                          LineChartBarData(
                            spots: distributorSpots,
                            isCurved: true,
                            color: Colors.blue[700],
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                // Only show dots for points that have been animated
                                if (index > ((sortedDates.length - 1) * _animationController.value)) {
                                  return FlDotCirclePainter(
                                    radius: 0,
                                    color: Colors.transparent,
                                    strokeWidth: 0,
                                    strokeColor: Colors.transparent,
                                  );
                                }
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.blue[700]!,
                                  strokeWidth: 1,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue[700]!.withOpacity(0.1),
                            ),
                          ),
                          // Retailer line (when showing comparison)
                          if (showRetailers)
                            LineChartBarData(
                              spots: retailerSpots,
                              isCurved: true,
                              color: Colors.green[400],
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  // Only show dots for points that have been animated
                                  if (index > ((sortedDates.length - 1) * _animationController.value)) {
                                    return FlDotCirclePainter(
                                      radius: 0,
                                      color: Colors.transparent,
                                      strokeWidth: 0,
                                      strokeColor: Colors.transparent,
                                    );
                                  }
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.green[400]!,
                                    strokeWidth: 1,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.green[400]!.withOpacity(0.1),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: showComparison,
            builder: (context, showRetailers, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Distributors', Colors.blue[700]!),
                  if (showRetailers) ...[
                    const SizedBox(width: 20),
                    _buildLegendItem('Retailers', Colors.green[400]!),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}