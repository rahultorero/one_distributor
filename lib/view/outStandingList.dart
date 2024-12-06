import 'dart:io';
import 'dart:ui';

import 'package:distributers_app/components/LoadingIndicator.dart';
import 'package:distributers_app/dataModels/DraftListRes.dart';
import 'package:distributers_app/dataModels/OrderDetailsRes.dart';
import 'package:distributers_app/services/api_services.dart';
import 'package:distributers_app/view/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../components/OutStandingPdfCreator.dart';
import '../dataModels/OrderListRes.dart';
import '../dataModels/StoreModel.dart';
import '../dataModels/outStandingRes.dart';
import '../theme.dart';
import '../dataModels/StoreModel.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_svg/flutter_svg.dart' as svg;


class OutStandingList extends StatefulWidget {
  @override
  _OutStandingListState createState() => _OutStandingListState();
}

class _OutStandingListState extends State<OutStandingList> {
  List<Party> orders = [];
  List<Party> filteredOrders = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  bool _isDropdownVisible = false;
  bool _isSearchVisible = false;
  bool _isDateRangeVisible = false;
  String? regCode;
  String? grpCode;
  int? companyId;
  List<Store> stores = [];
  String? selectedRegCode;
  String? selectedCompanyName;
  int? selectedCompanyId;
  String? formattedStartDate;
  String? formattedEndDate;
  // Dummy data for the dropdown
  String? _selectedStore;
  String userSearch = "";
  late double runningBalance ;

  DateTimeRange? _selectedDateRange;
  @override
  void initState() {
    super.initState();
    fetchData();
    filteredOrders = orders;

    searchController.addListener(() {
      filterOrders(searchController.text);
    });

  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    await _fetchDivisionAndCompanies(); // Call the first function and wait for it to complete
    await fetchOutStandingList(); // Then call the second function
  }

  Future<void> _fetchDivisionAndCompanies() async {
    try {
      // Fetch division
      regCode = await _getDivision();
      grpCode = await _getGrpCode();
      companyId = await _getCompanyId();
      if (regCode != null) {
        // Fetch companies using the division value
        stores = await fetchCompanies(regCode!);
        selectedCompanyId = stores[0].companyId;
      }
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false; // Update loading state
      });
    }
  }

  Future<String?> _getDivision() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("check the value ${prefs.getString("reg_code")}");
    return prefs.getString("reg_code"); // Replace with your key
  }
  Future<String?> _getGrpCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("check the value ${prefs.getString("grpCode")}");
    return prefs.getString("grpCode"); // Replace with your key
  }


  Future<int?> _getCompanyId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("check the value ${prefs.getInt("companyId")}");
    return prefs.getInt("companyId"); // Replace with your key
  }

  Future<List<Store>> fetchCompanies(String regCode) async {
    final response = await http.post(
      Uri.parse(ApiConfig.reqInvoiceDropDown()),
      // Replace with your actual API URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reg_code': regCode, // Add reg_code in the request body
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = jsonDecode(response.body);
      return (decodedJson['data'] as List)
          .map((storeJson) => Store.fromJson(storeJson))
          .toList();
    } else {
      throw Exception('Failed to load companies');
    }
  }


  Future<void> fetchOutStandingList() async {
    // Define the API endpoint URL
    final String url = ApiConfig.reqGetOutStanding(); // Replace with your API URL

    // Create the request body
    final Map<String, dynamic> body = {
      'company_id': companyId,
      'page': 1,
      'regcode': grpCode!.isNotEmpty ? grpCode : (regCode?.substring(0, 7) ?? ''),
      'userInput': searchController.text,
    };

    // Set a loading state
    setState(() {
      isLoading = true; // Assuming you have an isLoading boolean variable
    });

    print(body);

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Parse the response body directly as a list (no 'data' field in the response)
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        print('Response model data: $jsonResponse');

        // Parse the list of parties
        setState(() {
          orders = jsonResponse.map((orderJson) {
            return Party.fromJson(orderJson); // Assuming Party.fromJson exists
          }).toList();
          filteredOrders = orders; // Initialize filtered orders
        });

        print('Order fetched successfully: ${orders.length} orders found.');
      } else {
        // Handle non-200 status codes
        throw Exception('Failed to load order list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      // Optionally, handle the error (e.g., show a dialog or a snackbar)
    } finally {
      // Reset loading state
      setState(() {
        isLoading = false; // Reset loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    print("screen height ${screenHeight}");
    // Adjust the tablet breakpoint to match your device
    final isTablet = screenWidth >= 600;
    final isSmallScreen = screenWidth <= 360;

    // Calculate dynamic card height based on screen height
    // Assuming we want cards to take up roughly 1/3 of screen height on phones
    // and 1/2 of that on tablets
    final desiredCardHeight = isTablet
        ? screenHeight * 0.3  // For tablets
        : isSmallScreen
        ? screenHeight * 0.185
        : screenHeight * 0.175; // For phones

    // Calculate childAspectRatio dynamically
    // childAspectRatio = width / height
    // We need to account for the grid padding and margins
    final horizontalPadding = 16.0; // Total horizontal padding (8 on each side)
    final availableWidth = screenWidth - horizontalPadding;
    final cardWidth = isTablet ? availableWidth / 2 : availableWidth;
    final childAspectRatio = cardWidth / desiredCardHeight;
    return Scaffold(
      appBar: AppBar(
        title: Text('Outstanding Distributor'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFA5A4A4), // Dark Gray
                Color(0xFFD7D7D7), // Light Gray
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD7D7D7), // Light Gray
              Color(0xFFA5A4A4), // Dark Gray
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionButtons(),
            Visibility(
              visible: _isDropdownVisible || _isSearchVisible || _isDateRangeVisible,
              child: _buildFilterFields(),
            ),
            SizedBox(height: _isDropdownVisible || _isSearchVisible || _isDateRangeVisible ? 4 : 2),
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(child: LoadingIndicator())
                  : GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 2 : 1,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 1,
                mainAxisSpacing: 5,
              ),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return InkWell(
                    onTap: () {
                      _showOrderDetailsBottomSheet(context, order.receivableData);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Reduced margin
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.teal.shade50.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.business,
                                        color: Colors.teal,
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              order.partyName,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            "(${order.partyCode})",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    IconButton(
                                      icon: Icon(Icons.share_rounded, size: 18),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(
                                        minWidth: 28,
                                        minHeight: 28,
                                      ),
                                      color: Colors.teal,
                                      onPressed:(){ sharePdf(order);
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              // Handle location tap if needed
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_on_outlined, size: 14, color: Colors.teal),
                                                SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    '${order.area ?? ''}, ${order.city ?? ''}',
                                                    style: TextStyle(fontSize: 12, color: Colors.black87),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          InkWell(
                                            onTap: order.mobile != null ? () async {
                                              final url = 'tel:${order.mobile}';
                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              }
                                            } : null,
                                            child: Row(
                                              children: [
                                                Icon(Icons.phone_outlined, size: 14, color: Colors.teal),
                                                SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    order.mobile ?? 'N/A',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: order.mobile != null ? Colors.teal : Colors.black87,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          InkWell(
                                            onTap: order.email != null ? () async {
                                              final url = 'mailto:${order.email}';
                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              }
                                            } : null,
                                            child: Row(
                                              children: [
                                                Icon(Icons.email_outlined, size: 14, color: Colors.teal),
                                                SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    order.email ?? 'N/A',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: order.email != null ? Colors.teal : Colors.black87,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 50,
                                      width: 1,
                                      margin: EdgeInsets.symmetric(horizontal: 12),
                                      color: Colors.teal.withOpacity(0.2),
                                    ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            decoration: BoxDecoration(
                              color: (double.parse(order.credit_limit!) != null && double.parse(order.credit_limit!) > (order.totalBalance ?? 0))
                                ? Colors.red.withOpacity(0.1):
                              Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Balance',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '₹${order.totalBalance?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: (double.parse(order.credit_limit!) != null && double.parse(order.credit_limit!) > (order.totalBalance ?? 0))
                                        ? Colors.red // Set to red if credit limit is greater than balance
                                        : Colors.teal, // Otherwise, keep teal
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> sharePdf(Party party) async {
    print("Starting PDF generation and sharing process...");

    try {
      // Generate the PDF data with party-specific details
      List<InvoiceData> invoiceDataList = [];

        // Create a list of Invoice items if needed
        List<Invoice> invoices = party.receivableData.map((invoice) => Invoice(
          prefix: invoice.prefix,
          invNo: invoice.invNo.toString(),
          invDate:  DateFormat('dd-MM-yyyy').format(invoice.invDate),
          dueDate: DateFormat('dd-MM-yyyy').format(invoice.dueDate),
          pm: invoice.paymentMethod,
          invAmt: invoice.invAmt,
          cnAmt: invoice.cnAmt,
          recvAmt: invoice.recdAmt,
          balance: invoice.balance,
          salesman: invoice.salesman,
        )).toList();

        // Create an InvoiceData instance for each order
        InvoiceData invoiceData = InvoiceData(
          disName: party.partyName,
          disPartyCode: party.partyCode,
          disArea: party.area,
          disCity: party.city,
          disMobile: party.mobile,
          disEmail: party.email,
          retName: party.partyName,
          retPartyCode: party.partyCode,  // Assuming `partyCode` is available in `order`
          retArea: party.area,
          retCity: party.city,
          retMobile: party.mobile,
          retEmail: party.email,
          invoices: invoices,
          totalBalance: party.totalBalance, // Assuming `totalBalance` is part of each order
        );

        // Add to the list
        invoiceDataList.add(invoiceData);


      print("Generating PDF...");
      final pdfData = await PdfGenerator.generatePdf(invoiceDataList);
      print("PDF generated successfully.");

      // Save the PDF to a temporary file
      print("Saving PDF to temporary file...");
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/outstanding_distributor.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfData);
      print("PDF saved at $filePath");

      // Open the PDF for preview
      print("Opening PDF for preview...");
      await OpenFile.open(filePath);

      // Prompt user for sharing after preview
      print("Attempting to share the PDF...");
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Outstanding Distributor - ${party.partyName}',
        text: 'Check out the outstanding distributor details for ${party.partyName}!',
      );

      // Check the result of the share operation
      if (result.status == ShareResultStatus.success) {
        print("PDF shared successfully.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF shared successfully!'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print("PDF sharing was dismissed or failed.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('An error occurred during PDF generation or sharing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }


  Widget _buildInfoRow(IconData icon, String label, String value) {
    bool isPhoneField = label.toLowerCase().contains('phone');

    Future<void> launchPhoneCall(String phoneNumber) async {
      // Clean the phone number
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      if (phoneNumber == 'N/A' || phoneNumber.isEmpty) {
        return;
      }

      if (await Permission.phone.request().isGranted) {
        try {
          final Uri phoneUri = Uri.parse('tel:$phoneNumber');
          if (await launcher.canLaunchUrl(phoneUri)) {
            await launcher.launchUrl(phoneUri);
          }
        } catch (e) {
          debugPrint('Error launching phone dialer: $e');
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.teal),
          const SizedBox(width: 4),
          Expanded(
            child: isPhoneField && value != 'N/A'
                ? InkWell(
              onTap: () => launchPhoneCall(value),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.blue, // Makes it look clickable
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
                : Text(
              value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  void _showOrderDetailsBottomSheet(BuildContext context, List<ReceivableData> orders) {
    double previousAmount = 0.0;
    DateTime? _startDate;
    DateTime? _endDate;

    // Function to filter orders by date range
    List<ReceivableData> _filterOrdersByDate(List<ReceivableData> orders,
        DateTime? startDate, DateTime? endDate) {
      if (startDate == null || endDate == null) return orders;
      return orders.where((order) {
        DateTime orderDate = order
            .invDate; // Adjust this if `invDate` is a string
        return orderDate.isAfter(startDate.subtract(Duration(days: 1))) &&
            orderDate.isBefore(endDate.add(Duration(days: 1)));
      }).toList();
    }

    // Function to show date range picker
    Future<void> _selectDateRange(BuildContext context) async {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000), // Earliest possible date
        lastDate: DateTime(2100), // Latest possible date
        initialDateRange: _startDate != null && _endDate != null
            ? DateTimeRange(start: _startDate!, end: _endDate!)
            : null,
      );

      if (picked != null) {
        _startDate = picked.start;
        _endDate = picked.end;
      }
    }

    // Function to clear the selected date range
    void _clearDateRange() {
      _startDate = null;
      _endDate = null;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter the orders based on the date range
            List<ReceivableData> filteredOrders = _filterOrdersByDate(
                orders, _startDate, _endDate);

            // Calculate running balances for all items once
            List<double> runningBalances = [];
            double tempBalance = 0.0;
            for (var order in filteredOrders) {
              tempBalance += order.balance;
              runningBalances.add(tempBalance);
            }

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with Exit Icon

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.redAccent),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey[400], thickness: 1.0),
                      const SizedBox(height: 10),

                      // Date Range Picker Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await _selectDateRange(context);
                              setState(() {}); // Refresh UI to apply date filter
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _startDate != null && _endDate != null
                                  ? '${formatDateTime(_startDate!)} - ${formatDateTime(_endDate!)}'
                                  : 'Select Date Range',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          if (_startDate != null || _endDate != null)
                            ElevatedButton(
                              onPressed: () {
                                _clearDateRange();
                                setState(() {}); // Refresh UI to clear date filter
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Clear',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Expanded ListView with Invoices
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) => _buildInvoiceItem(
                              filteredOrders[index],
                              index,
                              runningBalances[index]  // Pass pre-calculated running balance
                          ),
                        ),
                      ),

                      // Fixed Total Section at Bottom
                      _buildTotalSection(filteredOrders),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );


  }

  String formatDateTime(DateTime dateTime) {
    // Format: YYYY-MM-DD
    return '${dateTime.year.toString().padLeft(4, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }

  Widget _buildInvoiceItem(ReceivableData receivable, int index, double runningBalance) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPairedInfo('TYPE', receivable.invType!, 'INV NO', receivable.invNo!.toString()),
          const SizedBox(height: 6),
          _buildPairedInfo('INV DATE', formatDateTime(receivable.invDate!), 'DUE DATE', formatDateTime(receivable.dueDate!)),
          const SizedBox(height: 6),
          _buildPairedInfo('PM', receivable.paymentMethod!, 'SMAN', receivable.salesman!),
          const Divider(height: 16),
          _buildAmountSection(receivable, index, runningBalance),  // Pass the pre-calculated running balance
        ],
      ),
    );
  }
  Widget _buildPairedInfo(String leftLabel, String leftValue, String rightLabel, String rightValue) {
    return Row(
      children: [
        // Left side with flexible content
        Expanded(
          child: Row(
            children: [
              Text(
                '$leftLabel: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Flexible(
                child: Text(
                  leftValue,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8), // Add some spacing between pairs
        // Right side with flexible content
        Expanded(
          child: Row(
            children: [
              Text(
                '$rightLabel: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Flexible(
                child: Text(
                  rightValue,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(ReceivableData receivable, int index,double runningBalance) {


    // Remove the accumulation from here
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Text(
                        'INV AMT: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '₹${receivable.invAmt}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Text(
                        'ADJ AMT: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '₹${receivable.recdAmt+receivable.cnAmt}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'BAL: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '₹${receivable.balance}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'C.BAL: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '₹${runningBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTotalSection(List<ReceivableData> receivable) {


    double totalInvAmount = receivable.fold(0, (sum, invoice) => sum + double.parse(invoice.invAmt.toString()));
    double totalBalance = receivable.fold(0, (sum, invoice) => sum + double.parse(invoice.balance.toString()));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Text(
                  'Total Inv: ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Flexible(
                  child: Text(
                    '₹${totalInvAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Balance: ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Flexible(
                  child: Text(
                    '₹${totalBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  List<Map<String, dynamic>> deliveryOptions = [
    {"label": "DELIVERY", "value": "1691"},
    {"label": "URGENT", "value": "1692"},
    {"label": "PICK UP", "value": "1693"},
    {"label": "OUTSTATION", "value": "1694"},
    {"label": "MEDREP", "value": "1695"},
    {"label": "COD", "value": "1699"},
  ];

  Text getLabelFromValue(String value) {
    final option = deliveryOptions.firstWhere(
          (element) => element['value'] == value,
      orElse: () => {}, // Return an empty map if no match is found
    );

    if (option.isNotEmpty) {
      // Define a color based on the label
      Color labelColor;
      switch (option['label']) {
        case 'DELIVERY':
          labelColor = Colors.green;
          break;
        case 'URGENT':
          labelColor = Colors.red;
          break;
        case 'PICK UP':
          labelColor = Colors.orange;
          break;
        case 'OUTSTATION':
          labelColor = Colors.blue;
          break;
        case 'MEDREP':
          labelColor = Colors.purple;
          break;
        case 'COD':
          labelColor = Colors.brown;
          break;
        default:
          labelColor = Colors.black;
      }

      // Return the label with the corresponding color
      return Text(
        option['label'],
        style: TextStyle(color: labelColor, fontWeight: FontWeight.bold,fontSize: 16),
      );
    }

    // Return a default text if no label is found
    return Text(
      'Label not found',
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    );
  }

  String getLabelFromString(String value) {
    final option = deliveryOptions.firstWhere(
          (element) => element['value'] == value,
      orElse: () => {}, // Return an empty map if no match is found
    );

    if (option.isNotEmpty) {
      // Define a color based on the label
      Color labelColor;
      switch (option['label']) {
        case 'DELIVERY':
          labelColor = Colors.green;
          break;
        case 'URGENT':
          labelColor = Colors.red;
          break;
        case 'PICK UP':
          labelColor = Colors.orange;
          break;
        case 'OUTSTATION':
          labelColor = Colors.blue;
          break;
        case 'MEDREP':
          labelColor = Colors.purple;
          break;
        case 'COD':
          labelColor = Colors.brown;
          break;
        default:
          labelColor = Colors.black;
      }

      // Return the label with the corresponding color
      return  option['label'];
    }

    // Return a default text if no label is found
    return "Label not found";
  }



  String formatDateFromString(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: _isSearchVisible ? Colors.black : Colors.grey, // Change color based on visibility
          ),
          onPressed: () {
            setState(() {
              _isSearchVisible = !_isSearchVisible; // Toggle search visibility
            });
          },
        ),

      ],
    );
  }



  Widget _buildFilterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown for Store Selection
        Visibility(
          visible: _isDropdownVisible,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0), // Adjust vertical padding
            child: DropdownButtonFormField<Store>(
              decoration: InputDecoration(
                labelText: 'Select Store',
                border: OutlineInputBorder(),
              ),
              value: stores.isNotEmpty ? stores[0] : null, // Set the first item as the default
              items: stores.map((store) {
                return DropdownMenuItem<Store>(
                  value: store,
                  child: Text(store.companyName),
                );
              }).toList(),
              onChanged: (Store? selectedStore) {
                if (selectedStore != null) {
                  setState(() {
                    selectedRegCode = selectedStore.regCode; // Store regCode
                    selectedCompanyName = selectedStore.companyName; // Store companyName
                    selectedCompanyId = selectedStore.companyId; // Store companyId
                  });
                }
              },
            ),
          ),
        ),

        // Text Field for Order Search
        Visibility(
          visible: _isSearchVisible,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0), // Adjust vertical padding
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Orders',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear(); // Clears the text in the TextField
                  },
                ),
              ),
              onChanged: (value) {
               fetchOutStandingList();
              },

            ),
          ),
        ),

        // Date Range Picker
        Visibility(
          visible: _isDateRangeVisible,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0), // Adjust vertical padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Date Range:'),
                ElevatedButton(
                  onPressed: () async {
                    DateTimeRange? pickedRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (pickedRange != null) {
                      setState(() {
                        _selectedDateRange = pickedRange; // Update selected date range

                        // Format the start and end dates to YYYY-MM-DD
                        formattedStartDate = DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start);
                        formattedEndDate = DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end);

                        print("Start Date: $formattedStartDate");
                        print("End Date: $formattedEndDate");


                      });


                    }
                  },
                  child: Text('Pick Range'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildInfoRow2(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.teal), // Icon for visual cue
          SizedBox(width: 8), // Spacing between icon and text
          Container(
            width: 80,
            child: Text(
              value,
              style: TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void filterOrders(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredOrders = orders; // Reset to original if query is empty
      });
    } else {
      setState(() {
        // filteredOrders = orders.where((order) {
        //
        //   return order.partyName.toLowerCase().contains(query.toLowerCase()) ||
        //       order.partyCode.toLowerCase().contains(query.toLowerCase()) ||
        //       order.orderNo.toLowerCase().contains(query.toLowerCase()) ||
        //       (order.area ?? '').toLowerCase().contains(query.toLowerCase()) ||
        //       (order.city ?? '').toLowerCase().contains(query.toLowerCase()) ||
        //       (order.sman ?? '').toLowerCase().contains(query.toLowerCase()) ||
        //       (order.companyName ?? '').toLowerCase().contains(query.toLowerCase()) ||
        //       (getLabelFromString(order.dType) ?? '').toLowerCase().contains(query.toLowerCase()) ||
        //       (order.oAmt ?? '').toString().toLowerCase().contains(query.toLowerCase());
        // }).toList();
      });
    }
  }
}

class InvoiceData {
  final String disName;
  final String disPartyCode;
  final String? disArea;
  final String? disCity;
  final String? disMobile;
  final String? disEmail;

  late final String retName;
  final String retPartyCode;
  final String? retArea;
  final String? retCity;
  final String? retMobile;
  final String? retEmail;

  final List<Invoice> invoices;
  final double totalBalance;

  InvoiceData({
    required this.disName,
    required this.disPartyCode,
    this.disArea,
    this.disCity,
    this.disMobile,
    this.disEmail,
    required this.retName,
    required this.retPartyCode,
    this.retArea,
    this.retCity,
    this.retMobile,
    this.retEmail,
    required this.invoices,
    required this.totalBalance,
  });
}

class Invoice {
  final String prefix;
  final String invNo;
  final String invDate;
  final String dueDate;
  final String pm;  // Payment method
  final double invAmt;
  final double cnAmt;   // Credit note amount
  final double recvAmt; // Received amount
  final double balance; // Outstanding balance
  final String salesman;

  Invoice({
    required this.prefix,
    required this.invNo,
    required this.invDate,
    required this.dueDate,
    required this.pm,
    required this.invAmt,
    required this.cnAmt,
    required this.recvAmt,
    required this.balance,
    required this.salesman,
  });
}

