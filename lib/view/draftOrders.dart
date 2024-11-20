import 'package:distributers_app/components/LoadingIndicator.dart';
import 'package:distributers_app/dataModels/DraftListRes.dart';
import 'package:distributers_app/dataModels/OrderDetailsRes.dart';
import 'package:distributers_app/services/api_services.dart';
import 'package:distributers_app/view/draftSalesOrder.dart';
import 'package:distributers_app/view/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../dataModels/OrderListRes.dart';
import '../dataModels/StoreModel.dart';
import '../theme.dart';
import '../dataModels/StoreModel.dart';
import 'newSalesOrder.dart';

class DraftOrderList extends StatefulWidget {
  @override
  _DraftOrderListState createState() => _DraftOrderListState();
}

class _DraftOrderListState extends State<DraftOrderList> {
  List<DraftOrderRes> orders = [];
  List<DraftOrderRes> filteredOrders = []; // List to hold filtered orders
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  bool _isDropdownVisible = false;
  bool _isSearchVisible = false;
  bool _isDateRangeVisible = false;
  String? regCode;
  List<Store> stores = [];
  String? selectedRegCode;
  String? selectedCompanyName;
  int? selectedCompanyId;
  String? formattedStartDate;
  String? formattedEndDate;
  // Dummy data for the dropdown
  String? _selectedStore;

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
    setState(() {
      isLoading = true; // Assuming you have an isLoading boolean variable
    });
    await _fetchDivisionAndCompanies(); // Call the first function and wait for it to complete
    await fetchOrderList(); // Then call the second function
  }

  Future<void> _fetchDivisionAndCompanies() async {
    try {
      // Fetch division
      regCode = await _getDivision();
      if (regCode != null) {
        // Fetch companies using the division value
        stores = await fetchCompanies(regCode!);
        selectedCompanyId = stores[0].companyId;
      }
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching data: $e');
    }
  }

  Future<String?> _getDivision() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("check the value ${prefs.getString("reg_code")}");
    return prefs.getString("reg_code"); // Replace with your key
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


  Future<void> fetchOrderList() async {
    // Define the API endpoint URL
    final String url = ApiConfig.reqGetDraftOrder(); // Replace with your API URL


    DateTime today = DateTime.now();


// Format dates as 'YYYY-MM-DD'
    String formatDate(DateTime date) {
      return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    // Create the request body
    final Map<String, dynamic> body = {
      'companyid': selectedCompanyId,
      'from': formattedStartDate ?? formatDate(today),
      'reg_code': regCode?.substring(0, 7),
      'order_status' : 0,
      'to': formattedEndDate ?? formatDate(today), // Use today if null
    };

    // Set a loading state


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
        // If the server returns a 200 OK response, parse the response body
        final jsonResponse = jsonDecode(response.body);

        print('Response model data: $jsonResponse');

        // Assuming jsonResponse contains a list of orders
        if (jsonResponse['data'] is List) {
          final List<dynamic> orderListJson = jsonResponse['data'];

          setState(() {
            orders = orderListJson.map((orderJson) {
              // Add null checks for each field as necessary
              return DraftOrderRes.fromJson(orderJson);
            }).toList();
            filteredOrders = orders; // Initialize filtered orders
          });

          print('Order fetched successfully: ${orders.length} orders found.');
        } else {
          // Handle unexpected response formats
          print('Unexpected response format: ${jsonResponse['data']}');
        }
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
    // Adjust the tablet breakpoint to match your device
    final isTablet = screenWidth >= 533;
    return Scaffold(
      appBar: AppBar(
        title: Text('Draft Orders'),
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
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NewSalesOrder()),
              );
            },
          ),

        ],
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
            // Use Visibility to conditionally render filter fields
            Visibility(
              visible: _isDropdownVisible || _isSearchVisible || _isDateRangeVisible,
              child: _buildFilterFields(),
            ),
            SizedBox(height: _isDropdownVisible || _isSearchVisible || _isDateRangeVisible ? 8 : 4),
            Expanded(
              child:isLoading ?
              Center(child: LoadingIndicator(),)
                  :
              filteredOrders.isEmpty
                  ? Center(
                child: Container(
                  color: Colors.transparent, // Make the background transparent
                  child: Lottie.asset(
                    'assets/animations/empty_state2.json', // Path to your Lottie animation file
                    width: 200, // Adjust the size as per your need
                    height: 200,
                    fit: BoxFit.fill,
                  ),
                ),

              )
                  : GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 2 : 1,
                // Lower the childAspectRatio to increase the height of the card
                childAspectRatio: isTablet ? 2.16:1.87, // Adjust this value to make the card taller
                crossAxisSpacing: 1,
                mainAxisSpacing: 5,
              ),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => DraftSalesOrder(draftOrder: filteredOrders[index])),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 130,
                                      child: Text(
                                        "${order.partyName}",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      child: Text(
                                        "(${order.ohid})",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 10.0), // Add right padding here
                                  width: 100,
                                  child: Text(
                                    "${order.orderNo}",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildInfoRow(Icons.location_on, 'Area/City:', '${order.area ?? ''}, ${order.city ?? ''}'),
                                Spacer(),
                                _buildInfoRow2(Icons.date_range_sharp, 'Date:', '${formatDateFromString(order.createdAt) ?? ''}'),
                              ],
                            ),
                            Row(
                              children: [
                                _buildInfoRow(Icons.man, 'Salesman:', '${order.sman ?? ''}'),
                                Spacer(),
                                _buildInfoRow2(Icons.create_sharp, 'Created By:', '${order.userName ?? ''}'),
                              ],
                            ),
                            Row(
                              children: [
                                _buildInfoRow(Icons.add_business_outlined, 'Company Name', '${order.companyName ?? ''}'),
                                Spacer(),
                                _buildInfoRow2(Icons.comment_outlined, 'Created By:', '${order.oreMark ?? ''}'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.delivery_dining, size: 25, color: Colors.teal),
                                SizedBox(width: 8),
                                Container(
                                  width: 150,
                                  child: getLabelFromValue(order.dType),
                                ),
                                Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'Amt: ₹${order.oAmt ?? '0.00'}',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  void _showOrderDetails(BuildContext context, DraftOrderRes order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraftOrderBottomSheet(ocId: order.ohid!,orderId: order.orderNo,companyName: order.partyName,),
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

                        fetchOrderList();
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.teal), // Icon for visual cue
          SizedBox(width: 8), // Spacing between icon and text
          Container(
            width: 150,
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
        filteredOrders = orders.where((order) {

          return order.partyName.toLowerCase().contains(query.toLowerCase()) ||
              order.partyCode.toLowerCase().contains(query.toLowerCase()) ||
              order.orderNo.toLowerCase().contains(query.toLowerCase()) ||
              (order.area ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (order.city ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (order.sman ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (order.companyName ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (getLabelFromString(order.dType) ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (order.oAmt ?? '').toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }


}


class DraftOrderBottomSheet extends StatefulWidget {
  final int ocId;
  final String orderId;
  final String companyName;
  const DraftOrderBottomSheet({Key? key, required this.ocId, required this.orderId,required this.companyName}) : super(key: key);

  @override
  _OrderBottomSheetState createState() => _OrderBottomSheetState();
}
class _OrderBottomSheetState extends State<DraftOrderBottomSheet> {
  OrderDetailsRes? orderDetails; // Nullable to handle loading state

  @override
  void initState() {
    super.initState();
    // Call the API when the widget is initialized
    postOrderDetails();
  }

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
              // Top bar for dragging
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 4, // Slightly increased blur for a softer shadow
                      offset: Offset(0, 2), // Slightly adjusted offset for the shadow
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between title and close button
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0), // Add left margin here
                      child:
                      Row(
                        children: [
                          Container(
                            width:200,
                            child:  Text(
                              '${widget.companyName}', // Heading
                              style: TextStyle(
                                  fontSize: 15, // Font size for better visibility
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Change the color if needed
                                  overflow: TextOverflow.ellipsis                        ),
                            ),
                          ),

                          Text(
                            '(${widget.orderId})', // Heading
                            style: TextStyle(
                                fontSize: 14, // Font size for better visibility
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Change the color if needed
                                overflow: TextOverflow.ellipsis                        ),
                          ),
                        ],
                      ),

                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey), // Close button icon
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the bottom sheet
                      },
                    ),
                  ],
                ),

              ),

              Expanded(
                child: orderDetails == null
                    ? Center(child: LoadingIndicator()) // Show loading indicator
                    : ListView.builder(
                  controller: controller,
                  padding: EdgeInsets.all(10),
                  itemCount: orderDetails!.data.length, // Number of orders
                  itemBuilder: (context, index) {
                    final order = orderDetails!.data[index]; // Get each order
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
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
                                    "${order.productName} (${order.pcode}) -",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${order.packing}',
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

                                    _buildInfoColumn('QTY', order.qty.toString()),
                                    VerticalDivider(color: Colors.grey[300], thickness: 1),
                                    _buildInfoColumn('Free', order.free.toString()),
                                    VerticalDivider(color: Colors.grey[300], thickness: 1),
                                    _buildInfoColumn('Rate', order.rate.toString()),
                                    VerticalDivider(color: Colors.grey[300], thickness: 1),
                                    _buildInfoColumn('Mrp', order.mrp.toString()),
                                    VerticalDivider(color: Colors.grey[300], thickness: 1),
                                    _buildInfoColumn('Amt', order.amount.toString()),


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

  Future<void> postOrderDetails() async {
    String url = ApiConfig.reqOrderDetails(); // Replace with your API endpoint

    // Prepare the body including 'ohid' and 'reg_code'
    final body = {
      'ohid': widget.ocId, // Use ocId as 'ohid'
      'reg_code': 'D000004',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Parse the response
        final data = jsonDecode(response.body);
        setState(() {
          orderDetails = OrderDetailsRes.fromJson(data); // Update order details
        });
        print('Order details fetched successfully');
      } else {
        print('Failed to fetch order details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while fetching order details: $error');
    }
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


