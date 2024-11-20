import 'dart:convert';

import 'package:distributers_app/components/LoadingIndicator.dart';
import 'package:distributers_app/services/api_services.dart';
import 'package:distributers_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dataModels/Invoice.dart';
import '../dataModels/StoreModel.dart'; // To format dates
import 'package:http/http.dart' as http;

class StatusConfig {
  final Color color;
  StatusConfig(this.color);
}


class SalesInvoiceScreen extends StatefulWidget {
  @override
  _SalesInvoiceScreenState createState() => _SalesInvoiceScreenState();
}

class _SalesInvoiceScreenState extends State<SalesInvoiceScreen> {
  List<Invoice> invoices = []; // This will hold the fetched invoices
  List<Invoice> filteredInvoices = []; // This will hold the fetched invoices

  String? selectedCompanyName;
  int? selectedCompanyId;
  String userSearch = '';
  String startDate = ''; // Default start date
  String endDate = ''; // Default end date
  bool _isDropdownVisible = false;
  bool _isSearchVisible = false;
  bool _isDateRangeVisible = false;
  // Text editing controllers for date fields
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  String? formattedStartDate;
  String? formattedEndDate;
  String? regCode;
  List<Store> stores = [];
  bool isLoading = true; // To manage loading state
  @override
  void initState() {
    super.initState();

    _fetchDivisionAndCompanies(); // Fetch data on init
    filteredInvoices = invoices;

    searchController.addListener(() {
      filterOrders(searchController.text);
    });
  }

  void filterOrders(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredInvoices = invoices; // Reset to original if query is empty
      });
    } else {
      setState(() {
        filteredInvoices = invoices.where((order) {

          return order.partyname!.toLowerCase().contains(query.toLowerCase()) ||
              order.invno!.toString().toLowerCase().contains(query.toLowerCase()) ||
              order.prefix.toLowerCase().contains(query.toLowerCase()) ||
              (order.area ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (order.city ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (order.invdate ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (order.duedate ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (order.invamt ?? '').toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  Future<void> _fetchDivisionAndCompanies() async {
    try {
      // Fetch division
      regCode = await _getDivision();
      if (regCode != null) {
        // Fetch companies using the division value
        stores = await fetchCompanies(regCode!);
        selectedCompanyId = stores[0].companyId;
        await _fetchInvoices();
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



  Future<void> _fetchInvoices() async {
    String apiUrl = ApiConfig.reqInvoiceList(); // Replace with actual API URL
    DateTime today = DateTime.now();

    // Format dates as 'YYYY-MM-DD'
    String formatDate(DateTime date) {
      return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    // Use provided startDate and endDate or fall back to today's date if they are empty

    String? fromDate = (formattedStartDate != null ) ? formattedStartDate : formatDate(today);
    String? toDate = (formattedEndDate != null && formattedEndDate!.isNotEmpty) ? formattedEndDate : formatDate(today);

    final body = jsonEncode({
      "regcode": regCode?.substring(0, 7),
      "company_id": selectedCompanyId,
      "pagenum": 1,
      "pagesize": 20,
      "from": fromDate,  // Use the derived fromDate
      "to": toDate,      // Use the derived toDate
      "order_key": "AA.invno",
      "order_by": "ASC",
      "userInput": userSearch
    });

    print("check the bodies  $body");

    setState(() {
      isLoading = true; // Set loading to true when the request starts
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Print response status code and body for debugging
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Decode the JSON response
        final jsonData = jsonDecode(response.body);
        print("check the data $jsonData");

        // Extract invoices from the 'data' key
        final List<dynamic>? invoiceList = jsonData['data'];

        if (invoiceList != null && invoiceList.isNotEmpty) {
          setState(() {
            invoices = invoiceList.map((json) => Invoice.fromJson(json)).toList();
            filteredInvoices = invoices;
          });
        } else {
          invoices = [];
          print('No invoices found in the response');
          // Handle no data case, like showing a message in UI
        }
      } else {
        invoices = [];
        throw Exception('Failed to load invoices: ${response.body}');
      }
    } catch (e) {
      setState(() {
        filteredInvoices = [];
      });

      print('Error fetching invoices: $e');
      // Show an error message in the UI using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong! Please try again later..')),
      );
    } finally {
      setState(() {
        isLoading = false; // Set loading to false when the request completes
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sales Invoice',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? Center(child: LoadingIndicator())
          : Column(
        children: [
          // Action buttons and filter fields are always visible
          _buildActionButtons(),
          Visibility(
            visible: _isDropdownVisible || _isSearchVisible || _isDateRangeVisible,
            child: _buildFilterFields(),
          ),
          SizedBox(
            height: _isDropdownVisible || _isSearchVisible || _isDateRangeVisible ? 8 : 4,
          ),

          // Main content area
          Expanded(
            child: filteredInvoices.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 120),
                  Center(
                    child: Container(
                      child: Lottie.asset(
                        'assets/animations/empty_state.json',
                        width: 200,
                        height: 200,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No invoices found!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : SalesInvoiceGrid(invoices: filteredInvoices),
          ),
        ],
      ),
    );
  }



  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(
            Icons.store,
            color: _isDropdownVisible ? Colors.black : Colors.grey, // Change color based on visibility
          ),
          onPressed: () {
            setState(() {
              _isDropdownVisible = !_isDropdownVisible; // Toggle dropdown visibility
            });
          },
        ),
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
        IconButton(
          icon: Icon(
            Icons.date_range,
            color: _isDateRangeVisible ? Colors.black : Colors.grey, // Change color based on visibility
          ),
          onPressed: () {
            setState(() {
              _isDateRangeVisible = !_isDateRangeVisible; // Toggle date range visibility
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
                    regCode = selectedStore.regCode; // Store regCode
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

                        _fetchInvoices();
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



  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  // Division and company data loading logic
                  isLoading
                      ? Center(child: LoadingIndicator()) // Show loader while loading
                      : regCode == null
                      ? Text('No division found')
                      : stores.isEmpty
                      ? Text('No companies found')
                      : DropdownButtonFormField<Store>(
                    decoration: InputDecoration(
                      labelText: 'Select Store',
                      border: OutlineInputBorder(),
                    ),
                    items: stores.map((store) {
                      return DropdownMenuItem<Store>(
                        value: store,
                        child: Text(store.companyName),
                      );
                    }).toList(),
                    onChanged: (selectedStore) {
                      if (selectedStore != null) {
                        setState(() {
                          regCode = selectedStore.regCode; // Store regCode
                          selectedCompanyName = selectedStore.companyName; // Store companyName
                          selectedCompanyId = selectedStore.companyId; // Assuming Store has an id field
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Search field
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Invoice',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      userSearch = value; // Store user input for search
                    },
                  ),
                  SizedBox(height: 16),

                  // Date range selector
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          context,
                          label: "Start Date",
                          controller: startDateController,
                          onDateSelected: (date) {
                            setState(() {
                              startDate = date; // Store selected start date
                              startDateController.text = date; // Update text field
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          context,
                          label: "End Date",
                          controller: endDateController,
                          onDateSelected: (date) {
                            setState(() {
                              endDate = date; // Store selected end date
                              endDateController.text = date; // Update text field
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Sort Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle sort action here
                    },
                    icon: Icon(Icons.sort),
                    label: Text('Sort by Date'),
                  ),
                  SizedBox(height: 16),

                  // Apply Filters Button
                  ElevatedButton(
                    onPressed: () {
                      // Handle apply action here
                      print('Filters Applied:');
                      print('Reg Code: $regCode');
                      print('Company Name: $selectedCompanyName');
                      print('Company ID: $selectedCompanyId');
                      print('User Search: $userSearch');
                      print('Start Date: $startDate');
                      print('End Date: $endDate');

                      _fetchInvoices(); // Fetch invoices on init
                      Navigator.pop(context); // Close filter sheet
                    },
                    child: Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  Future<String?> _getDivision() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("check the value ${prefs.getString("reg_code")}");
    return prefs.getString("reg_code"); // Replace with your key
  }

  // Helper method for Date Picker

  Widget _buildDateField(BuildContext context, {
    required String label,
    required TextEditingController controller,
    required Function(String) onDateSelected,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate); // Format the date
          onDateSelected(formattedDate); // Pass the selected date back
        }
      },
    );
  }
}

class SalesInvoiceGrid extends StatelessWidget {
  final List<Invoice> invoices;

  const SalesInvoiceGrid({Key? key, required this.invoices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Adjust the tablet breakpoint to match your device
    final isTablet = screenWidth >= 533;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 2 : 1,
          // Adjusted aspect ratio for better height control
          childAspectRatio: isTablet ? 1.79 : 1.65,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return GestureDetector(
            onTap: () => _showInvoiceDetails(context, invoice),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              // Adding gradient background to the card
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        invoice.partyname ?? 'N/A',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 14 : 16,
                                          color: const Color(0xFF2D3748),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatusWidget(invoice.barcode)
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${invoice.add1},${invoice.add2}" ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 13,
                                    color: const Color(0xFF2D3748),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "${invoice.area},${invoice.city}" ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 13,
                                    color: const Color(0xFF2D3748),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 7),

                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final maxWidth = constraints.maxWidth;
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: maxWidth * 0.48,
                                              child: _buildInfoText('INV NO', '${invoice.prefix}/${invoice.invno ?? 'N/A'}', isTablet),
                                            ),
                                            const Spacer(),
                                            SizedBox(
                                              width: maxWidth * 0.48,
                                              child: _buildInfoText('DATE', formatDateFromString(invoice.invdate) ?? 'N/A', isTablet),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: maxWidth * 0.48,
                                              child: _buildInfoText('ORDER NO', invoice.orderno ?? 'N/A', isTablet),
                                            ),
                                            const Spacer(),
                                            SizedBox(
                                              width: maxWidth * 0.48,
                                              child: _buildInfoText('DATE', formatDateFromString(invoice.orderdate) ?? 'N/A', isTablet),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 6 : 8,
                                  vertical: isTablet ? 4 : 6
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.shade50,
                                    Colors.blue.shade100,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade100.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _buildAmountText('INV AMT', invoice.invamt, Colors.blue.shade700, isTablet),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 6 : 8,
                                  vertical: isTablet ? 4 : 6
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.green.shade50,
                                    Colors.green.shade100,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade100.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _buildRECDAmountText('ADJ AMT', invoice.recdamt+invoice.cnamt, Colors.green.shade700, isTablet),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 6 : 8,
                                  vertical: isTablet ? 4 : 6
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.red.shade50,
                                    Colors.red.shade100,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.shade100.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _buildBalanceText('BALANCE', invoice.balance, Colors.red.shade700, isTablet),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoText(String label, String value, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
              fontSize: isTablet ? 11 : 13,
              color: Colors.grey.shade800
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // Update the amount text builders to include isTablet parameter
  Widget _buildAmountText(String label, dynamic amount, Color color, bool isTablet) {
    String formattedAmount = _formatAmount(amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 11 : 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formattedAmount,
          style: TextStyle(
            fontSize: isTablet ? 13 : 15,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceText(String label, dynamic amount, Color color, bool isTablet) {
    String formattedAmount = _formatAmount(amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 11 : 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formattedAmount,
          style: TextStyle(
            fontSize: isTablet ? 13 : 15,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRECDAmountText(String label, dynamic amount, Color color, bool isTablet) {
    String formattedAmount = _formatAmount(amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 11 : 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formattedAmount,
          style: TextStyle(
            fontSize: isTablet ? 13 : 15,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return 'N/A';
    try {
      if (amount is String) {
        final numAmount = double.tryParse(amount);
        return numAmount != null ? '₹${numAmount.toStringAsFixed(2)}' : '₹$amount';
      } else if (amount is num) {
        return '₹${amount.toStringAsFixed(2)}';
      }
      return '₹$amount';
    } catch (e) {
      return '₹$amount';
    }
  }


  Widget _buildStatusWidget(String status) {

    return  Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getStatusIcon(status),
            size: 14,
            color: getStatusColor(status),
          ),
          SizedBox(width: 2),
          Text(
           status ?? 'N/A',
            style: TextStyle(
              fontSize: 11,
              color: getStatusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'CHKED':  // Checked
        return Colors.blue;
      case 'GDWIN':  // Goods In
        return Colors.green;
      case 'GDWOT':  // Goods Out
        return Colors.teal;
      case 'NOPRINT': // Not Printed
        return Colors.red;
      case 'DCONF':  // Delivery Confirmed
        return Colors.green;
      case 'DELIV':  // Delivered
        return Colors.green;
      case 'PACKD':  // Packed
        return Colors.blue;
      case 'PRNCF':  // Print Confirmed
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'PRINTED':
        return Colors.blue;
      case 'UPLOADED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'CHKED':
        return Icons.fact_check;
      case 'GDWIN':
        return Icons.inbox;
      case 'GDWOT':
        return Icons.outbox;
      case 'NOPRINT':
        return Icons.print_disabled;
      case 'DCONF':
        return Icons.local_shipping;
      case 'DELIV':
        return Icons.done_all;
      case 'PACKD':
        return Icons.inventory_2;
      case 'PRNCF':
        return Icons.print_outlined;
      case 'PENDING':
        return Icons.pending;
      case 'PRINTED':
        return Icons.print;
      case 'UPLOADED':
        return Icons.cloud_done;
      default:
        return Icons.help_outline;
    }
  }

  Color getUploadStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'UPLOADED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'NOPRINT': // Not Printed
        return Colors.red;

      case 'NOT UPLOADED':
        return Colors.grey;
      case 'FAILED':
        return Colors.red;
      case 'PRINTED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData getUploadStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'UPLOADED':
        return Icons.cloud_done;
      case 'PENDING':
        return Icons.cloud_upload;
      case 'NOPRINT':
      case 'NOT UPLOADED':
        return Icons.cloud_off;
      case 'FAILED':
        return Icons.error_outline;
      case 'PRINTED':
        return Icons.print_outlined;
      default:
        return Icons.cloud_upload;
    }
  }

// Optional: Helper function to get readable status text
  String getReadableStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'CHKED':
        return 'Checked';
      case 'GDWIN':
        return 'Goods In';
      case 'GDWOT':
        return 'Goods Out';
      case 'NOPRINT':
        return 'Not Printed';
      case 'DCONF':
        return 'Delivery Confirmed';
      case 'DELIV':
        return 'Delivered';
      case 'PACKD':
        return 'Packed';
      case 'PRNCF':
        return 'Print Confirmed';
      default:
        return status ?? 'N/A';
    }
  }

  String formatDateFromString(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A'; // Return 'N/A' for empty or null strings
    try {
      DateTime date = DateTime.parse(dateString); // Parse the string to DateTime
      return DateFormat('yyyy-MM-dd').format(date); // Format the date
    } catch (e) {
      return 'Invalid Date'; // Handle invalid date formats
    }
  }
}

void _showInvoiceDetails(BuildContext context, Invoice invoice) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => InvoiceDetailsBottomSheet(invoice: invoice),
  );
}


class InvoiceDetailsBottomSheet extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailsBottomSheet({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.2,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        invoice.partyname ?? 'N/A',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: invoice.details == null || invoice.details!.isEmpty
                    ? Center(
                  child: Text(
                    'No Invoice Details found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  controller: controller,
                  padding: EdgeInsets.all(10),
                  itemCount: invoice.details?.length,
                  itemBuilder: (context, index) {
                    final product = invoice.details?[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: RiveAppTheme.background,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${product?.pname} (${product?.packUnit}${product?.packageUnit})" ?? 'N/A',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildInfoColumn('QTY', product?.qty?.toString() ?? '0'),
                                    VerticalDivider(color: Colors.grey[300], thickness: 1),
                                    _buildInfoColumn('SCH QTY', product?.schqty.toString() ?? '0'),
                                    VerticalDivider(color: Colors.grey[300], thickness: 1),
                                    _buildInfoColumn('SCH %', '${product?.schPer.toStringAsFixed(2)}%'),
                                    VerticalDivider(color: Colors.grey[300], thickness: 1),
                                    _buildInfoColumn('DISC %', '${product?.cdPer.toStringAsFixed(2)}%'),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            // New pricing info container
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'MRP',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '₹${product?.mrp.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Rate',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '₹${product?.rate?.toStringAsFixed(2) ?? 'N/A'}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Amount',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '₹${(product?.qty ?? 0) * (product?.rate ?? 0)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
