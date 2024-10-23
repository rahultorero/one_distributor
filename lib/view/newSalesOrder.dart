import 'dart:convert';

import 'package:distributers_app/components/BottomSheetsViews/frequentlyPurchase.dart';
import 'package:distributers_app/components/LoadingIndicator.dart';
import 'package:distributers_app/dataModels/FrequentlyPurchase.dart';
import 'package:distributers_app/dataModels/ReceivableListRes.dart';
import 'package:distributers_app/view/SalesOrders.dart';
import 'package:distributers_app/view/slidingProductPanel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dataModels/CreateOrderModel.dart';
import '../dataModels/PartyProductModel.dart';
import '../dataModels/ProductListModel.dart';
import '../dataModels/StoreModel.dart';
import '../services/api_services.dart';
import 'invoiceDetailBottomSheet.dart';

class Customer {
  final int id;
  final String regCode;
  final String name;

  Customer({required this.id,required this.regCode, required this.name});
}



class DeliveryOption {
  String label;
  String value;

  DeliveryOption({required this.label, required this.value});
}



class NewSalesOrder extends StatefulWidget {
  @override
  _NewSalesOrderState createState() => _NewSalesOrderState();
}

class _NewSalesOrderState extends State<NewSalesOrder> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  Customer? _selectedCustomer;
  Party? _selectedRetailer;
  Product? _selectedProduct;
  DeliveryOption? _selectedDelivery;
  int _quantity = 0;
  String _freeQuantity = '0';
  String? regCode;
  int? smid;
  int? userId;
  List<Store> stores = [];
  late PartyProductModel product;
  int? _selectedCustomerId;
  String? _selectGroupCode;
  TextEditingController? selectAdd;
  TextEditingController? selectArea;
  TextEditingController? selectCity;
  TextEditingController? selectTel;
  TextEditingController? selectMob;
  TextEditingController? selectOsAmt;
  TextEditingController? selectRemark;
  TextEditingController _remarkController = TextEditingController();

  int? _selectedDeliveryId;
  final TextEditingController _quantityController = TextEditingController();
  List<ProductListItem> productListItem = [];
  bool isLoading = false;
  List<Customer> customerList = [];
  List<Party> retailerList = [];
  List<Product> productList = [];
  List<DeliveryOption> deliveryOptions = [];
  ReceivableListRes? receivableList;
  FrequentlyPurchase? frequentlyList;
  FrequentlyPurchase? bouncedList;

  bool _isExpanded = false;
  @override
  void initState() {
    super.initState();
    // The data to populate the list
    List<Map<String, dynamic>> deliveryOptionsData = [
      {"label": "DELIVERY", "value": "1691"},
      {"label": "URGENT", "value": "1692"},
      {"label": "PICK UP", "value": "1693"},
      {"label": "OUTSTATION", "value": "1694"},
      {"label": "MEDREP", "value": "1695"},
      {"label": "COD", "value": "1699"},
    ];

// Mapping the list of maps to DeliveryOption objects
    deliveryOptions = deliveryOptionsData
        .map((option) => DeliveryOption(
      label: option['label'] as String,
      value: option['value'].toString(), // Convert value to String if necessary
    ))
        .toList();

    DeliveryOption? defaultDeliveryOption = deliveryOptions.isNotEmpty ? deliveryOptions.first : null;

// Example usage in a dropdown or similar widget
    _selectedDelivery = defaultDeliveryOption;
    _selectedDeliveryId = int.parse(_selectedDelivery!.value);


    selectAdd = TextEditingController();
    selectArea = TextEditingController();
    selectCity = TextEditingController();
    selectTel = TextEditingController();
    selectMob = TextEditingController();
    selectOsAmt = TextEditingController();
    selectRemark = TextEditingController();
    _quantityController.text = _quantity.toString(); // Set initial value

    _tabController = TabController(length: 2, vsync: this);
    fetchData();

  }

  @override
  void dispose() {
    selectAdd?.dispose();
    selectArea?.dispose();
    selectCity?.dispose();
    selectTel?.dispose();
    selectMob?.dispose();
    selectOsAmt?.dispose();
    _tabController.dispose();
    selectRemark?.dispose();
    _quantityController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    await _fetchDivisionAndCompanies(); // Call the first function and wait for it to complete
    product = (await fetchPartyProductData(companyId: _selectedCustomerId!,isWeekly: "false",regCode: regCode!,smanId: smid!))!; // Then call the second function

    for (var store in product.data!) {
      // Loop through each party in the party list of the store

      retailerList = store.party!;
      productList = store.product!;
    }
  }

  Future<void> _fetchDivisionAndCompanies() async {
    try {
      // Fetch division
      regCode = await _getDivision();
      smid = await _getsmid();
      userId = await _getUserId();
      if (regCode != null) {
        // Fetch companies using the division value
        stores = await fetchCompanies(regCode!);

        // Map stores to customerList
        customerList = stores.map((store) {
          return Customer(id: store.companyId, regCode: store.regCode,name: store.companyName);
        }).toList();

        // Set selected company ID to the first one in the list
        _selectedCustomerId = stores[0].companyId;

        // Optionally, set the default selected customer
        _selectedCustomer = customerList.isNotEmpty ? customerList[0] : null;
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

  Future<void> checkAndFetchReceivable() async {
    if (_selectedRetailer != null) {
      // Fetch receivable data if _selectedRetailer is not null
      receivableList = await fetchReceivable();
      frequentlyList = await fetchFrequently();
      bouncedList = await fetchBounced();
      setState(() {
        selectOsAmt?.text = receivableList!.total.toString();
      });

      print("check the receivavle $receivableList");
    } else {
      // Handle the case where _selectedRetailer is null
      print("Retailer is not selected");
    }
  }


  Future<ReceivableListRes> fetchReceivable() async {
    try {
      Map<String, dynamic> requestBody = {
        'reg_code': regCode?.substring(0, 7),
        'company_id': _selectedCustomerId,
        'ledid_party': _selectedRetailer?.ledidParty,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.reqReceivableList()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print(requestBody); // Log the request body for debugging
      if (response.statusCode == 200) {
        // Decode the response as a map
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(response.body); // Log the response for debugging

        // Parse the response into a ReceivableListRes object
        ReceivableListRes receivableListRes = ReceivableListRes.fromJson(data);

        // Return the list of Receivable objects
        return receivableListRes ; // Return an empty list if data is null
      } else {
        // Log error for non-200 status code
        throw Exception('Failed to load receivable list: Status Code ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      // Log the exception details and stack trace
      print('Error occurred: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error occurred while fetching receivables: $e');
    }
  }

  Future<FrequentlyPurchase> fetchFrequently() async {
    try {
      Map<String, dynamic> requestBody = {
        'regcode': regCode?.substring(0, 7),
        'company_id': _selectedCustomerId,
        'ledid_party': _selectedRetailer?.ledidParty,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.reqFrequentlyList()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print(requestBody); // Log the request body for debugging
      if (response.statusCode == 200) {
        // Decode the response as a map
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(response.body); // Log the response for debugging

        // Parse the response into a ReceivableListRes object
        FrequentlyPurchase receivableListRes = FrequentlyPurchase.fromJson(data);

        // Return the list of Receivable objects
        return receivableListRes ; // Return an empty list if data is null
      } else {
        // Log error for non-200 status code
        throw Exception('Failed to load receivable list: Status Code ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      // Log the exception details and stack trace
      print('Error occurred: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error occurred while fetching receivables: $e');
    }
  }

  Future<FrequentlyPurchase> fetchBounced() async {
    try {
      Map<String, dynamic> requestBody = {
        'regcode': regCode?.substring(0, 7),
        'company_id': _selectedCustomerId,
        'ledid_party': _selectedRetailer?.ledidParty,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.reqBouncedList()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print(requestBody); // Log the request body for debugging
      if (response.statusCode == 200) {
        // Decode the response as a map
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(response.body); // Log the response for debugging

        // Parse the response into a ReceivableListRes object
        FrequentlyPurchase receivableListRes = FrequentlyPurchase.fromJson(data);

        // Return the list of Receivable objects
        return receivableListRes ; // Return an empty list if data is null
      } else {
        // Log error for non-200 status code
        throw Exception('Failed to load receivable list: Status Code ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      // Log the exception details and stack trace
      print('Error occurred: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error occurred while fetching receivables: $e');
    }
  }




  Future<String?> _getDivision() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("check the value ${prefs.getString("reg_code")}");
    return prefs.getString("reg_code"); // Replace with your key
  }

  Future<int?> _getsmid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("smid"); // Replace with your key
  }

  Future<int?> _getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("u_id"); // Replace with your key
  }

  Future<PartyProductModel?> fetchPartyProductData(
      {required int companyId,
        required String isWeekly,
        required String regCode,
        required int smanId}) async {
    final String apiUrl = ApiConfig.reqPartyProduct();; // Replace with your API URL

    // Define the request body
    Map<String, dynamic> requestBody = {
      'companyid': companyId,
      'isweekly': isWeekly,
      'reg_code': regCode,
      'smanid': smanId,
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Parse the response body into your model class
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("party Product list ${responseData.toString()}");
        return PartyProductModel.fromJson(responseData);
      } else {
        print("Failed to load data. Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  Widget _buildAnimatedField(String label, {bool readOnly = false, String? initialValue, Widget? suffix, TextEditingController? controller}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        controller: controller,
        readOnly: readOnly,
        style: TextStyle(
          fontSize: 14.0, // Set font size for input text
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14.0, // Set font size for the label
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          suffixIcon: suffix,
        ),
      ),
    );
  }


  Widget _buildAnimatedDropdown<T>(
      String label,
      T? value,
      List<T> items,
      String Function(T) displayValue, // For getting display name
      int Function(T) getId, // For getting ID
      Function(T?) onChanged, // Callback for when item is selected
          {bool enabled = true}
      ) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(displayValue(item)), // Display the item's name
          );
        }).toList(),
        onChanged: enabled
            ? (T? selectedItem) {
          if (selectedItem != null) {
            // Get the ID of the selected item and store it
            int selectedId = getId(selectedItem);
            // Do something with the selectedId (e.g., save it to a state variable)
            print('Selected ID: $selectedId');
          }
          // Trigger the onChanged callback
          onChanged(selectedItem);
        }
            : null,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200, // Subtle background color
      body:
      SlidingProductPanel(productListItem: productListItem,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.indigo, // Collapsed color
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'New Sales Order',
                    style: TextStyle(color: Colors.white),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.indigo.shade800], // Expanded color
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.shopping_cart,
                        size: 60,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.history, color:  Colors.white70,),
                    tooltip: 'Frequently Purchased',
                    onPressed: () async {
                      // Get the selected frequently purchased items list
                      List<FrequentlyItems>? frequentlySelectedList = await showPurchaseBottomSheet(context, frequentlyList!,"Frequently Purchased");

                      if (frequentlySelectedList != null && frequentlySelectedList.isNotEmpty) {
                        // Do something with the selected list
                        print('Selected Items: $frequentlySelectedList');

                        List<int> d_companyId = [];
                        for(var id in frequentlySelectedList){
                          int selectedCompanyId = id!.dCompanyid!;

                          if (!d_companyId.contains(selectedCompanyId)) {
                            d_companyId.add(selectedCompanyId);
                          }
                        }

                        for (var items in frequentlySelectedList) {
                          List<ProductList> products = [
                            ProductList(
                              name: items?.pname,
                              packing: items!.pcode.toString(),
                              scheme: items?.scheme,
                              itemDetailid: items?.itemdetailid,
                              ledidParty: _selectedRetailer?.ledidParty,
                              qty: items.qty ?? 0,
                              free: items.free,
                              schPercentage: "",
                              rate: double.parse(items!.ptr ?? '0.0'),
                              mrp: items?.mrp,
                              ptr: items?.ptr,
                              amount: "0",
                              remark: items.remark,
                              companyid: _selectedProduct?.dCompanyid,
                              pid: items?.pid,
                              odid: 0,
                            ),
                          ];

                          // Example data for ProductListItem
                          ProductListItem orderItem = ProductListItem(
                            data: products,
                            remark: selectRemark?.text,
                            grpCode: _selectGroupCode,
                            ohid: 0,
                            companyId: d_companyId,
                            salesmanId: _selectedRetailer?.smanid,
                            cusrid: userId,
                            userType: "Distributor",
                            dType: _selectedDeliveryId,
                            orderStatus: 1,
                          );

                          // Add the product to the order
                          addProduct(orderItem);
                        }

                        // After processing, clear the frequentlyList
                        setState(() {
                          frequentlySelectedList.clear();
                        });

                        print('Frequently List cleared ${frequentlySelectedList.length}');
                      } else {
                        print('No items selected or list is empty.');
                      }
                    },

                  ),

                  IconButton(
                    icon: Icon(Icons.assignment_return,color: Colors.white70,),
                    tooltip: 'Bounced Products',
                    onPressed: () async {
                      // Get the selected frequently purchased items list
                      List<FrequentlyItems>? frequentlySelectedList = await showPurchaseBottomSheet(context, bouncedList!,"Bounced Products");

                      if (frequentlySelectedList != null && frequentlySelectedList.isNotEmpty) {
                        // Do something with the selected list
                        print('Selected Items: $frequentlySelectedList');

                        List<int> d_companyId = [];
                        for(var id in frequentlySelectedList){
                          int selectedCompanyId = id!.dCompanyid!;

                          if (!d_companyId.contains(selectedCompanyId)) {
                            d_companyId.add(selectedCompanyId);
                          }
                        }

                        for (var items in frequentlySelectedList) {
                          List<ProductList> products = [
                            ProductList(
                              name: items?.pname,
                              packing: items!.pcode.toString(),
                              scheme: items?.scheme,
                              itemDetailid: items?.itemdetailid,
                              ledidParty: _selectedRetailer?.ledidParty,
                              qty: items.qty ?? 0,
                              free: items.free,
                              schPercentage: "",
                              rate: double.parse(items!.ptr ?? '0.0'),
                              mrp: items?.mrp,
                              ptr: items?.ptr,
                              amount: "0",
                              remark: items.remark,
                              companyid: _selectedProduct?.dCompanyid,
                              pid: items?.pid,
                              odid: 0,
                            ),
                          ];

                          // Example data for ProductListItem
                          ProductListItem orderItem = ProductListItem(
                            data: products,
                            remark: selectRemark?.text,
                            grpCode: _selectGroupCode,
                            ohid: 0,
                            companyId: d_companyId,
                            salesmanId: _selectedRetailer?.smanid,
                            cusrid: userId,
                            userType: "Distributor",
                            dType: _selectedDeliveryId,
                            orderStatus: 1,
                          );

                          // Add the product to the order
                          addProduct(orderItem);
                        }

                        // After processing, clear the frequentlyList
                        setState(() {
                          frequentlySelectedList.clear();
                        });

                        print('Frequently List cleared ${frequentlySelectedList.length}');
                      } else {
                        print('No items selected or list is empty.');
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.category,color: Colors.white70,),
                    tooltip: 'MFG-wise Product',
                    onPressed: () {
                      // Your onPressed action here
                    },
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Container(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.0),
                        child:
                         Card(
                            elevation: 10,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [

                                      Card(
                                        elevation: 10,
                                        color: Colors.white, // Professional color
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16.0,horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                                            children: [
                                              _buildAnimatedDropdown<Customer>(
                                                'Customer Name',
                                                _selectedCustomer,
                                                customerList,
                                                    (customer) => customer.name, // Extract customer name
                                                    (customer) => customer.id,    // Extract customer ID
                                                    (newValue) {
                                                  setState(() {
                                                    _selectedCustomer = newValue;
                                                    _selectedCustomerId = newValue?.id; // Store the selected ID
                                                    _selectGroupCode = newValue?.regCode;
                                                    print("check grp code ${_selectGroupCode}");
                                                  });
                                                },
                                              ),
                                              SizedBox(height: 10), // Add spacing between elements

                                              // Bottom Sheet for Retailer
                                              GestureDetector(
                                                onTap: () => _showRetailerBottomSheet(context),
                                                child: _buildBottomSheetTrigger(
                                                  'Retailer',
                                                  _selectedRetailer != null && _selectedRetailer!.partyname!.isNotEmpty
                                                      ? _selectedRetailer!.partyname! // Display party name if selected
                                                      : 'Select Retailer', // Default text when no retailer is selected
                                                ),
                                              ),
                                              SizedBox(height: 10), // Add spacing between elements

                                              // Bottom Sheet for Product
                                              GestureDetector(
                                                onTap: () => _showProductBottomSheet(context),
                                                child: _buildBottomSheetTrigger('Product Name', _selectedProduct?.pname ?? ''),
                                              ),
                                              SizedBox(height: 16),

                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Center all children
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0), // Added padding for better spacing
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'QTY',
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              fontWeight: FontWeight.normal,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(Icons.remove, size: 16.0, color: Colors.red),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    _quantity = (_quantity - 1).clamp(0, 100);
                                                                    _quantityController.text = _quantity.toString();
                                                                  });
                                                                },
                                                              ),
                                                              // Column for the TextField and its label
                                                              SizedBox(
                                                                width: 60,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    SizedBox(height: 4.0),
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.grey.shade200,
                                                                        borderRadius: BorderRadius.circular(8),
                                                                        border: Border.all(color: Colors.grey.shade400),
                                                                      ),
                                                                      child: TextField(
                                                                        keyboardType: TextInputType.number,
                                                                        textAlign: TextAlign.center,
                                                                        style: TextStyle(fontSize: 16.0),
                                                                        decoration: InputDecoration(
                                                                          border: InputBorder.none,
                                                                          hintText: '0',
                                                                          hintStyle: TextStyle(color: Colors.grey.shade600),
                                                                          contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                                                                        ),
                                                                        controller: _quantityController,
                                                                        onChanged: (value) {
                                                                          final newValue = int.tryParse(value);
                                                                          if (newValue != null && newValue >= 0 && newValue <= 100) {
                                                                            setState(() {
                                                                              _quantity = newValue;

                                                                            });
                                                                          }
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: Icon(Icons.add, size: 16.0, color: Colors.green),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    _quantity = (_quantity + 1).clamp(0, 100);
                                                                    _quantityController.text = _quantity.toString();
                                                                  });
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: _buildAnimatedField(
                                                      'Free',
                                                      controller: TextEditingController(text: _freeQuantity),
                                                      suffix: Icon(Icons.card_giftcard, color: Colors.orange),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(height: 12), // Space before the Show More and Add button row

                                              // Row for Show More text and Add button
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _isExpanded = !_isExpanded; // Toggle expansion
                                                      });
                                                    },
                                                    child: Text(
                                                      _isExpanded ? 'Show Less' : 'Show More',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.blue.shade700, // Change color to indicate it's clickable
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {

                                                      List<int> d_companyId = [];

                                                      int selectedCompanyId = _selectedProduct!.dCompanyid!;

                                                      if (!d_companyId.contains(selectedCompanyId)) {
                                                        d_companyId.add(selectedCompanyId);
                                                      }

                                                      List<ProductList> products = [
                                                        ProductList(
                                                          name: _selectedProduct?.pname,
                                                          packing: _selectedProduct!.pcode.toString(),
                                                          scheme: _selectedProduct?.scheme,
                                                          itemDetailid: _selectedProduct?.itemdetailid,
                                                          ledidParty: _selectedRetailer?.ledidParty,
                                                          qty: int.parse(_quantityController.text) ?? 0,
                                                          free: 0,
                                                          schPercentage: "",
                                                          rate: double.parse(_selectedProduct!.ptr ?? '0.0'),
                                                          mrp: _selectedProduct?.mrp,
                                                          ptr: _selectedProduct?.ptr,
                                                          amount: "0",
                                                          remark: _remarkController.text,
                                                          companyid: _selectedProduct?.dCompanyid,
                                                          pid: _selectedProduct?.pid,
                                                          odid: 0,
                                                        ),

                                                      ];

                                                      // Example data for ProductListItem
                                                      ProductListItem orderItem = ProductListItem(
                                                        data: products,
                                                        remark: selectRemark?.text,
                                                        grpCode: _selectGroupCode,
                                                        ohid: 0,
                                                        companyId: d_companyId,
                                                        salesmanId: _selectedRetailer?.smanid,
                                                        cusrid: userId,
                                                        userType: "Distributor",
                                                        dType: _selectedDeliveryId,
                                                        orderStatus: 1,
                                                      );

                                                      print(_remarkController.text);
                                                      addProduct(orderItem);

                                                      Future.delayed(Duration(milliseconds: 100), () {

                                                        setState(() {
                                                          _quantityController.text = "0";
                                                          _quantity = 0;
                                                          _selectedProduct = null;
                                                        });
                                                        // Debug: Print the list after resetting quantities
                                                        print('After resetting quantities: $frequentlyList');
                                                      });

                                                    },
                                                    child: Text('Add', style: TextStyle(fontSize: 12, color: Colors.white)),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.blue.shade700, // Change this color as per your theme
                                                      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 13.0),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // Expansion for MRP, PTR, Stock, Scheme in row format
                                              if (_isExpanded)
                                                Padding(
                                                    padding: const EdgeInsets.only(top: 5.0),
                                                    child: Container(
                                                      margin: const EdgeInsets.symmetric( vertical: 2),
                                                      child: _buildProductDetailsRow(),
                                                    )

                                                ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 5),
                                      Card(
                                        elevation: 10,
                                        color: Colors.white, // Professional color
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16)),
                                        child: Column(
                                          children: [
                                            TabBar(
                                              controller: _tabController,
                                              tabs: [

                                                Tab(text: 'Delivery'),
                                                Tab(text: 'Details'),
                                              ],
                                              labelColor: Colors.blue.shade700,
                                              unselectedLabelColor: Colors.grey,
                                              indicatorColor: Colors.blue.shade700,
                                            ),
                                            Container(
                                              height: 320,
                                              child: TabBarView(
                                                controller: _tabController,
                                                children: [

                                                  Padding(
                                                    padding: EdgeInsets.all(16),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(12),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.blue.withOpacity(0.1),
                                                                      blurRadius: 8,
                                                                      offset: Offset(0, 4),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    // Handle the onPressed event here


                                                                    showInvoiceDetails(context, receivableList!);
                                                                    // Add any action you want here
                                                                  },
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(12), // Add padding for better tap area
                                                                    child: Text(
                                                                      selectOsAmt!.text.isNotEmpty ? 'OS Amount :- ${selectOsAmt?.text}' : 'OS Amount',
                                                                      style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold), // You can customize the text style
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                            ),
                                                          ],
                                                        ),

                                                        SizedBox(height: 10,),
                                                        _buildAnimatedDropdown<DeliveryOption>(
                                                          'Delivery Option',
                                                          _selectedDelivery,
                                                          deliveryOptions,
                                                              (product) => product.label,
                                                              (product) => int.parse(product.value),
                                                              (newValue) {
                                                            setState(() {
                                                              _selectedDelivery = newValue;
                                                              _selectedDeliveryId =
                                                                  int.parse(newValue!.value);
                                                            });
                                                          },
                                                        ),
                                                        _buildAnimatedField('Remark',
                                                            suffix: Icon(Icons.edit),controller: selectRemark),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(16),
                                                    child: Column(
                                                      children: [
                                                        _buildAnimatedField('Address',
                                                            readOnly: true,
                                                            controller: selectAdd),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                child: _buildAnimatedField('Area',
                                                                    readOnly: true,controller: selectArea)),
                                                            SizedBox(width: 16),
                                                            Expanded(
                                                                child: _buildAnimatedField('City',
                                                                    readOnly: true,controller:selectCity)),
                                                          ],
                                                        ),
                                                        _buildAnimatedField('Tel',
                                                            readOnly: true,controller:selectTel),
                                                        _buildAnimatedField('Mob',
                                                            readOnly: true,controller: selectMob),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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
                ),
              ),
            ],
          ),),


    );
  }

  Widget _buildProductDetailsRow() {
    const TextStyle labelStyle = TextStyle(
      fontSize: 11,
      color: Colors.grey,
      fontWeight: FontWeight.w500,
    );

    const TextStyle valueStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    Widget _buildDetailItem(String label, String value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: labelStyle,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: valueStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                // MRP and Stock
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(
                        'MRP',
                        '₹${_selectedProduct?.mrp ?? "-"}',
                      ),
                      const SizedBox(height: 10),
                      _buildDetailItem(
                        'Stock',
                        _selectedProduct?.totalStock?.toString() ?? "-",
                      ),
                    ],
                  ),
                ),
                // Vertical Divider
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  width: 1,
                  color: Colors.grey[300],
                ),
                // PTR and Scheme
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(
                        'PTR',
                        '₹${_selectedProduct?.ptr ?? "-"}',
                      ),
                      const SizedBox(height: 10),
                      _buildDetailItem(
                        'Scheme',
                        _selectedProduct?.scheme?.toString() ?? "-",
                      ),
                    ],
                  ),
                ),
                // Vertical Divider
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 1,
                  color: Colors.grey[300],
                ),
                // Box
                SizedBox(
                  width: 50,
                  child: _buildDetailItem(
                    'Box',
                    _selectedProduct?.box?.toString() ?? "-",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10), // Space between product details and remark field
          // Add Remark TextField
          TextFormField(
            controller: _remarkController,
            maxLines: 2, // Allow multiple lines for remarks
            decoration: InputDecoration(
              hintText: 'Add Remark',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void addProduct(ProductListItem orderItem) {
    setState(() {
      productListItem.add(orderItem);

    });
  }


  void _showRetailerBottomSheet(BuildContext context) {
    final searchController = TextEditingController();

    List<Party> _filterRetailers(String query) {
      if (query.isEmpty) {
        return retailerList;
      }

      bool _matchesQuery(String? field, String query, {bool fullMatch = false}) {
        if (field == null) return false;
        if (fullMatch) {
          return field.toLowerCase().contains(query.toLowerCase());
        } else {
          return field.toLowerCase().startsWith(query.toLowerCase());
        }
      }

      if (query.startsWith(' ') && !query.startsWith('  ')) {
        // One space: search in entire party name and party code
        String trimmedQuery = query.trim().toLowerCase();
        return retailerList.where((retailer) =>
        _matchesQuery(retailer.partyname, trimmedQuery, fullMatch: true) ||
            _matchesQuery(retailer.partycode, trimmedQuery, fullMatch: true)
        ).toList();
      } else if (query.startsWith('  ')) {
        // Two spaces: search in all fields
        String trimmedQuery = query.trim().toLowerCase();
        return retailerList.where((retailer) {
          return _matchesQuery(retailer.partyname, trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.partycode, trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.add1, trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.add2, trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.area, trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.city, trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.teleno, trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.mobileno, trimmedQuery, fullMatch: true);
        }).toList();
      } else {
        // Direct search: filter by first character of party name or party code
        return retailerList.where((retailer) =>
        _matchesQuery(retailer.partyname, query) ||
            _matchesQuery(retailer.partycode, query)
        ).toList();
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<Party> filteredRetailers = _filterRetailers(searchController.text);

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    Container(
                      width: double.infinity, // Full width background
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                      ),
                      child: Text(
                        "Select Retailer Below",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search retailers...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredRetailers = _filterRetailers(value);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredRetailers.isEmpty
                          ? Center(child: Text('No retailers found'))
                          : ListView.builder(
                        controller: controller,
                        itemCount: filteredRetailers.length,
                        itemBuilder: (context, index) {
                          return _buildRetailerCard(filteredRetailers[index], searchController.text, context);
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }


  void _showProductBottomSheet(BuildContext context) {
    final searchController = TextEditingController();

    List<Product> _filterRetailers(String query) {
      if (query.isEmpty) {
        return productList;
      }

      bool _matchesQuery(String? field, String query, {bool fullMatch = false}) {
        if (field == null) return false;
        if (fullMatch) {
          return field.toLowerCase().contains(query.toLowerCase());
        } else {
          return field.toLowerCase().startsWith(query.toLowerCase());
        }
      }

      if (query.startsWith(' ') && !query.startsWith('  ')) {
        // One space: search in entire party name and party code
        String trimmedQuery = query.trim().toLowerCase();
        return productList.where((retailer) =>
        _matchesQuery(retailer.pname, trimmedQuery, fullMatch: true) ||
            _matchesQuery(retailer.pcode.toString(), trimmedQuery, fullMatch: true)
        ).toList();
      } else if (query.startsWith('  ')) {
        // Two spaces: search in all fields
        String trimmedQuery = query.trim().toLowerCase();
        return productList.where((retailer) {
          return _matchesQuery(retailer.pname, trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.pcode.toString(), trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.mrp, trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.ptr, trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.totalStock, trimmedQuery, fullMatch: true) ||
              _matchesQuery(retailer.scheme, trimmedQuery, fullMatch: true) ;

        }).toList();
      } else {
        // Direct search: filter by first character of party name or party code
        return productList.where((retailer) =>
        _matchesQuery(retailer.pname, query) ||
            _matchesQuery(retailer.pcode.toString(), query)
        ).toList();
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<Product> filteredRetailers = _filterRetailers(searchController.text);

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    Container(
                      width: double.infinity, // Full width background
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                      ),
                      child: Text(
                        "Select Product Below",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredRetailers = _filterRetailers(value);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredRetailers.isEmpty
                          ? Center(child: Text('No retailers found'))
                          : ListView.builder(
                        controller: controller,
                        itemCount: filteredRetailers.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(filteredRetailers[index], searchController.text, context);
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }



  Widget _buildRetailerCard(Party retailer, String searchQuery, BuildContext context) {
    bool fullMatch = searchQuery.startsWith(' ');
    return GestureDetector(
      onTap: () {

        // Update the selected retailer and close the bottom sheet
        setState(() {
          _selectedRetailer = retailer;
          selectAdd?.text = "${_selectedRetailer!.add1!},${_selectedRetailer!.add2!}";
          selectArea?.text = _selectedRetailer!.area!;
          selectCity?.text = _selectedRetailer!.city!;
          selectTel?.text = _selectedRetailer!.teleno!;
          selectMob?.text = _selectedRetailer!.mobileno!;

          checkAndFetchReceivable();

        });



        Navigator.pop(context);
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _highlightText(retailer.partyname ?? 'N/A', searchQuery),
              SizedBox(height: 4),
              _highlightText("${retailer.partycode ?? 'N/A'}", searchQuery),
              SizedBox(height: 8),
              _buildInfoRow(Icons.location_city, 'Add:', '${retailer.add1 ?? ''}, ${retailer.add2 ?? ''}'),
              SizedBox(height: 8),
              _buildInfoRow(Icons.location_on, 'Area/City:', '${retailer.area ?? ''}, ${retailer.city ?? ''}'),
              SizedBox(height: 8),
              _buildInfoRow(Icons.phone, 'TEL:', retailer.teleno ?? 'N/A'),
              SizedBox(height: 8),
              _buildInfoRow(Icons.phone_android, 'Created By:', retailer.mobileno ?? 'N/A'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, String searchQuery, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Update the selected product and close the bottom sheet
        setState(() {
          _selectedProduct = product;

        });
        Navigator.pop(context);
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name
              _highlightText(product.pname ?? 'N/A', searchQuery),
              SizedBox(height: 4),
              // Product code
              _highlightText("Product Code: ${product.pcode ?? 'N/A'}", searchQuery),
              SizedBox(height: 8),
              // MRP and PTR row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow3(Icons.currency_rupee, 'MRP:', '${product.mrp ?? 'N/A'}'),
                  ),
                  SizedBox(width: 16), // Add some space between the two info rows
                  Expanded(
                    child: _buildInfoRow3(Icons.currency_rupee, 'PTR:', '${product.ptr ?? 'N/A'}'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Stock and Scheme row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow3(Icons.production_quantity_limits, 'Stock:', '${product.totalStock ?? 'N/A'}'),
                  ),
                  SizedBox(width: 16), // Add some space between the two info rows
                  Expanded(
                    child: _buildInfoRow3(Icons.schema, 'Scheme:', '${product.scheme ?? ''}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow3(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 4),
        Expanded( // Wrap value in Expanded
          child: Text(
            value,
            overflow: TextOverflow.ellipsis, // Prevent overflow and add ellipsis if needed
            maxLines: 1, // Ensure text stays in one line
          ),
        ),
      ],
    );
  }
  Widget _highlightText(String text, String query, {bool fullMatch = false}) {
    // Treat queries consisting only of spaces as empty
    if (query.trim().isEmpty) {
      return Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold), // Make the entire text bold if no query
      );
    }

    final spans = <TextSpan>[];
    final lowercaseText = text.toLowerCase();
    final lowercaseQuery = query.trim().toLowerCase(); // Trim query to avoid space-only searches

    int start = 0;
    while (start < text.length) {
      final index = lowercaseText.indexOf(lowercaseQuery, start);

      if (index == -1) {
        // Add remaining text if no more matches found
        spans.add(TextSpan(
          text: text.substring(start),
          style: TextStyle(fontWeight: FontWeight.bold), // Make unhighlighted text bold
        ));
        break;
      }

      // Add unhighlighted text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(fontWeight: FontWeight.bold), // Make unhighlighted text bold
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + lowercaseQuery.length),
        style: TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold, // Highlighted text remains bold
        ),
      ));

      start = index + lowercaseQuery.length; // Move start to continue search
    }

    // Render using RichText only if necessary
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black), // Default text color
        children: spans,
      ),
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
            width: 300,
            child: Column( // Use Column to allow for multi-line text
              crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the start
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // Allows the value text to take up two lines
                ),
              ],
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





// Widget for bottom sheet trigger with underline effect
  Widget _buildBottomSheetTrigger(String label, String selectedValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          padding: EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Use Flexible to avoid overflow issues
              Flexible(
                child: Text(
                  selectedValue.isNotEmpty ? selectedValue : 'Select $label',
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }
}




class ProductListWidget extends StatefulWidget {
  final List<ProductListItem> productListItem;
  const ProductListWidget({Key? key, required this.productListItem}) : super(key: key);
  @override
  _ProductListWidgetState createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  late List<ProductList> products = [];
  bool _isLoading = false; // Loading state
  late TextEditingController _remarkController;
  @override
  void initState() {

    updateProductsList();

    super.initState();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ProductListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("did anything chnagessss ${oldWidget.productListItem.length}");
    updateProductsList();
  }

  void removeProduct(ProductList product) {
    setState(() {
      // Remove from local products list
      products.remove(product);

      // Remove from source productListItem
      for (var item in widget.productListItem) {
        if (item.data != null) {
          item.data!.removeWhere((p) =>
          p.itemDetailid == product.itemDetailid &&
              p.pid == product.pid
          );
        }
      }

      // Remove empty ProductListItems
      widget.productListItem.removeWhere((item) =>
      item.data == null || item.data!.isEmpty
      );
    });
  }

  void updateProductsList() {
    setState(() {
      products = [];
      for (var item in widget.productListItem) {
        if (item.data != null) {
          products.addAll(item.data!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Summary Card
            Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem(
                      'Total Items',
                      '${products.length}',
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                    _buildSummaryItem(
                      'Total Quantity',
                      '${products.fold(0, (sum, item) => sum + item.qty!)}',
                      Icons.shopping_cart,
                      Colors.green,
                    ),
                    _buildSummaryItem(
                      'Total Amount',
                      currencyFormat.format(
                          products.fold(0.0, (sum, item) => sum + item.total!)),
                      Icons.payment,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ),

            // Product List
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                padding: EdgeInsets.symmetric(horizontal: 5),
                itemBuilder: (context, index) {
                  return _buildProductCard(products[index], index);
                },
              ),
            ),

            // Buttons at the bottom
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Draft Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Draft logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade500, // Button color
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Reduced padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Smaller border radius
                        ),
                      ),
                      child: Text(
                        'Draft',
                        style: TextStyle(
                          fontSize: 14, // Smaller font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8), // Reduced space between the buttons

                  // Confirm Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _submitOrder(widget.productListItem[0], products);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade500, // Button color
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Reduced padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Smaller border radius
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 14, // Smaller font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Loader Overlay
        if (_isLoading)
          ModalBarrier(
            dismissible: false, // Prevent dismissing the overlay by tapping
            color: Colors.black54, // Optional: semi-transparent background color
          ),
        if (_isLoading)
          Center(
            child: LoadingIndicator(), // Show loader
          ),
      ],
    );
  }


  Future<void> _submitOrder(ProductListItem productItem, List<ProductList> product) async {
    final url = Uri.parse(ApiConfig.reqCreateOrder()); // Replace with your actual API endpoint
    final headers = {'Content-Type': 'application/json'};

    List<Orders> orders = [];
    for (var items in product) {
      orders.add(Orders(
        itemDetailid: items.itemDetailid!,
        ledidParty: items.ledidParty!,
        qty: items.qty,
        free: items.free!,
        schPercentage: 0,
        rate: items.rate.toString(),
        mrp: items.mrp.toString(),
        ptr: items.ptr!,
        amount: items.total.toString(),
        remark: items.remark,
        companyid: items.companyid,
        pid: items.pid,
        odid: items.odid,
      ));
    }

    final orderModel = CreateOrderModel(
      data: orders,
      remark: productItem.remark, // Add your remark here
      grpCode: productItem.grpCode,
      ohid: productItem.ohid,
      companyId: productItem.companyId,
      salesmanId: productItem.salesmanId,
      cusrid: productItem.cusrid,
      userType: productItem.userType,
      dType: productItem.dType,
      orderStatus: 1, // For confirm
    );

    print("check the body ${orderModel.toJson()}");

    setState(() {
      _isLoading = true; // Show loader
    });

    try {
      // Make the POST request
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(orderModel),
      );

      setState(() {
        _isLoading = false; // Hide loader
      });

      if (response.statusCode == 201) {
        // Handle success
        final responseBody = jsonDecode(response.body);
        print('Order submitted successfully: $responseBody');

        // Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order Created Successfully'),
            backgroundColor: Colors.green, // Set the background color of the SnackBar
          ),
        );


        // Navigate to another screen (replace 'AnotherScreen' with your target screen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SalesOrderList()), // Replace with your target screen
        );
      } else {
        // Handle failure
        print('Failed to submit order: ${response.statusCode}');
        print('Response: ${response.body}');

        // Show failure Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong. Try again later.'),
            backgroundColor: Colors.red,) // Set the background color of the SnackBar),
        );
      }
    } catch (e) {
      // Handle any errors
      setState(() {
        _isLoading = false; // Hide loader
      });
      print('Error occurred while submitting order: $e');

      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. Try again later.'),
          backgroundColor: Colors.red,) // Set the background color of the SnackBar),
      );
    }
  }


  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductList product, int index) {
    _remarkController = TextEditingController(text: product.remark ?? "");
    return Dismissible(
      key: Key(product.hashCode.toString()),
      direction: DismissDirection.endToStart,  // Only allow right to left swipe
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        removeProduct(product); // Use the new removal method
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ExpansionTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          product.name!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        product.packing!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),

              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.symmetric(vertical: 2),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildInfoChip('MRP: ${product.mrp}', Colors.green),
                  SizedBox(width: 12),
                  if (product.free! > 0) ...[
                    _buildInfoChip('Free: ${product.free}', Colors.orange),
                    SizedBox(width: 12),
                  ],
                  _buildInfoChip(
                    currencyFormat.format(product.total),
                    Colors.purple,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildQuantityControl(product),
                  ),
                ],
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildEditableRate(
                            'Rate',
                            product.rate!,
                                (newValue) {
                              setState(() {
                                // Update rate logic here
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDetailItem('MRP', product.mrp!),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem('PTR',product.ptr!),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDetailItem(
                            'Scheme',
                            (product.scheme == null || product.scheme!.isEmpty) ? '--' : product.scheme!,
                          ),

                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 140,
                          height: 50,
                          child: TextField(
                            controller: _remarkController, // Set the controller
                            decoration: InputDecoration(
                              hintText: 'Add remark...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            onChanged: (value) {
                              setState(() {
                                product.remark = value; // Update product remark on change
                              });
                            },
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 10),

                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildEditableRate(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller: TextEditingController(text: value.toString()),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixText: '₹ ',
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            onChanged: (value) {
              final newRate = double.tryParse(value);
              if (newRate != null) {
                onChanged(newRate);
              }
            },
          ),
        ),
      ],
    );
  }


  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControl(ProductList product) {
    // Create a stateful text editing controller
    final TextEditingController _controller = TextEditingController(text: product.qty?.toString() ?? '0');

    return Container(
      constraints: BoxConstraints(
        minWidth: 120,
        maxWidth: 120,
        minHeight: 36,
        maxHeight: 36,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(7)),
              onTap: () {
                if (product.qty != null && product.qty! > 0) {
                  setState(() {
                    product.qty = product.qty! - 1;
                    _controller.text = product.qty.toString();
                  });
                }
              },
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ),

          // Quantity input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  border: InputBorder.none,
                  counterText: '',
                ),
                maxLength: 4,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  setState(() {
                    product.qty = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
          ),

          // Increase button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(7)),
              onTap: () {
                setState(() {
                  product.qty = (product.qty ?? 0) + 1;
                  _controller.text = product.qty.toString();
                });
              },
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

