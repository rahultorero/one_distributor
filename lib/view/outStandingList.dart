import 'package:distributers_app/components/LoadingIndicator.dart';
import 'package:distributers_app/dataModels/DraftListRes.dart';
import 'package:distributers_app/dataModels/OrderDetailsRes.dart';
import 'package:distributers_app/services/api_services.dart';
import 'package:distributers_app/view/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../dataModels/OrderListRes.dart';
import '../dataModels/StoreModel.dart';
import '../dataModels/outStandingRes.dart';
import '../theme.dart';
import '../dataModels/StoreModel.dart';

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
      'regcode': regCode?.substring(0, 7),
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
                  : ListView.builder(
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
                        color: Colors.white,
                        elevation: 2, // Reduced elevation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Slightly rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0), // Reduced padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      order.partyName,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600), // Slightly smaller font
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    "(${order.partyCode})",
                                    style: TextStyle(fontSize: 14, color: Colors.black54), // Smaller font
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4), // Reduced spacing
                              _buildInfoRow(Icons.location_on, 'Location:', '${order.area ?? ''}, ${order.city ?? ''}'),
                              _buildInfoRow(Icons.phone, 'Phone:', order.mobile ?? 'N/A'),
                              _buildInfoRow(Icons.email, 'Email:', order.email ?? 'N/A'),
                              const SizedBox(height: 6), // Space before amount
                              Divider(color: Colors.grey, thickness: 0.5), // Subtle divider
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Amt: ₹${order.totalBalance?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal), // Smaller amount font
                                ),
                              ),
                            ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2), // Compact spacing
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.teal), // Slightly smaller icon
          SizedBox(width: 4), // Adjusted spacing
          Expanded(
            child: Text(
              '$value',
              style: TextStyle(fontSize: 13), // Smaller font size for compactness
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