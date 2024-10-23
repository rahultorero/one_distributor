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


class SalesInvoiceScreen extends StatefulWidget {
  @override
  _SalesInvoiceScreenState createState() => _SalesInvoiceScreenState();
}

class _SalesInvoiceScreenState extends State<SalesInvoiceScreen> {
  List<Invoice> invoices = []; // This will hold the fetched invoices
  String? selectedRegCode;
  String? selectedCompanyName;
  int? selectedCompanyId;
  String userSearch = '';
  String startDate = ''; // Default start date
  String endDate = ''; // Default end date

  // Text editing controllers for date fields
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  String? regCode;
  List<Store> stores = [];
  bool isLoading = true; // To manage loading state
  @override
  void initState() {
    super.initState();
    _fetchDivisionAndCompanies(); // Fetch data on init
  }

  Future<void> _fetchDivisionAndCompanies() async {
    try {
      // Fetch division
      regCode = await _getDivision();
      if (regCode != null) {
        // Fetch companies using the division value
        stores = await fetchCompanies(regCode!);
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
    final body = jsonEncode({
      "regcode": selectedRegCode,
      "company_id": selectedCompanyId,
      "pagenum": 1,
      "pagesize": 20,
      "from": startDate, // Ensure this format matches the API expectations
      "to": endDate, // Adjust the date format if necessary
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

      if (response.statusCode == 200) {
        // Decode the JSON response
        final jsonData = jsonDecode(response.body);
        print("check the data $jsonData");

        // Extract invoices from the 'data' key
        final List<dynamic>? invoiceList = jsonData['data'];

        if (invoiceList != null && invoiceList.isNotEmpty) {
          setState(() {
            invoices =
                invoiceList.map((json) => Invoice.fromJson(json)).toList();
          });
        } else {
          print('No invoices found in the response');
          // Handle no data case, like showing a message in UI
        }
      } else {
        throw Exception('Failed to load invoices: ${response.body}');
      }
    } catch (e) {
      print('Error fetching invoices: $e');
      // Show an error message in the UI using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching invoices: $e')),
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
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        title: Text(
          'Sales Invoice',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: LoadingIndicator())
      :invoices.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated SVG using Lottie
            Lottie.asset(
              'assets/animations/empty_state.json', // Path to your Lottie animation file
              width: 200, // You can adjust the size as per your need
              height: 200,
              fit: BoxFit.fill,
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
          : SalesInvoiceGrid(invoices: invoices), // Display invoices in a grid format
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
                          selectedRegCode = selectedStore.regCode; // Store regCode
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
                      print('Reg Code: $selectedRegCode');
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
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return GestureDetector(
            onTap: () => _showInvoiceDetails(context, invoice),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
                              Text(
                                invoice.partyname ?? 'N/A',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Invoice No: ${invoice.prefix}/${invoice.invno ?? 'N/A'}',style: TextStyle(fontSize: 15),),
                              Text('Invoice Date: ${formatDateFromString(invoice.invdate) ?? 'N/A'}',style: TextStyle(fontSize: 15)),
                              Text('Order No: ${  invoice.orderno ?? 'N/A'}',style: TextStyle(fontSize: 15)),
                              Text('Order Date: ${formatDateFromString(invoice.orderdate) ?? 'N/A'}',style: TextStyle(fontSize: 15)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            _buildStatusWidget(invoice.barcode), // Pass the status code her// Another status
                          ],
                        )

                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distributes content between left and right
                      children: [
                        // Left side (INV AMT and Balance)
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INV AMT: ₹${invoice.invamt ?? 'N/A'}',
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Balance: ₹${invoice.balance ?? 'N/A'}',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ),

                        // Right side (CN AMT and RECD AMT)
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'CN AMT: ₹${invoice.cnamt ?? 'N/A'}', // CN AMT field
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'RECD AMT: ₹${invoice.recdamt ?? 'N/A'}', // RECD AMT field
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'CHKED':
        return Icons.check_circle_outline; // Checked
      case 'GDWIN':
        return Icons.arrow_circle_down_outlined; // Godown IN
      case 'GDWOT':
        return Icons.arrow_circle_up_outlined; // Godown OUT
      case 'NOPRINT':
        return Icons.print_disabled; // No Print
      case 'DCONF':
        return Icons.verified_outlined; // Delivery Confirm
      case 'DELIV':
        return Icons.local_shipping_outlined; // Delivery Leave
      case 'PACKD':
        return Icons.inventory_outlined; // Packed the Delivery
      case 'PRICF':
        return Icons.print; // Print
      default:
        return Icons.help_outline; // Default icon for unknown status
    }
  }

  String _getTextForStatus(String status) {
    switch (status) {
      case 'CHKED':
        return 'CHKED';
      case 'GDWIN':
        return 'GDWIN';
      case 'GDWOT':
        return 'GDWOT';
      case 'NOPRINT':
        return 'NOPRINT';
      case 'DCONF':
        return 'DCONF';
      case 'DELIV':
        return 'DELIV';
      case 'PACKD':
        return 'PACKD';
      case 'PRICF':
        return 'PRICF';
      default:
        return 'Unknown';
    }
  }

  Widget _buildStatusWidget(String status) {
    return Column(
      children: [
        Icon(
          _getIconForStatus(status),
          color: Colors.green, // You can change this based on status
        ),
        SizedBox(height: 8), // Spacing between icon and text
        Text(
          _getTextForStatus(status),
          style: TextStyle(fontSize: 14), // Style the text if needed
        ),
      ],
    );
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
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Party Name with Ellipsis if it's too long
                    Expanded(
                      child: Text(
                        invoice.partyname ?? 'N/A',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis, // Show dots if text is too long
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                )

              ),
              Expanded(
                child: ListView.builder(
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
                      color: RiveAppTheme.background, // Change this to your desired color
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${product?.pname} (${product?.packUnit}${product?.packageUnit})" ?? 'N/A',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${product?.mrp.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Rate: ₹${product?.rate?.toStringAsFixed(2) ?? 'N/A'}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
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

