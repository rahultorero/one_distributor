import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:distributers_app/components/BottomSheetsViews/frequentlyPurchase.dart';
import 'package:distributers_app/components/LoadingIndicator.dart';
import 'package:distributers_app/dataModels/DraftListRes.dart';
import 'package:distributers_app/dataModels/FrequentlyPurchase.dart';
import 'package:distributers_app/dataModels/ReceivableListRes.dart';
import 'package:distributers_app/view/SalesOrders.dart';
import 'package:distributers_app/view/draftOrders.dart';
import 'package:distributers_app/view/slidingProductPanel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../components/OutStandingPdfCreator.dart';
import '../components/TutorialStep.dart';
import '../dataModels/CreateOrderModel.dart';
import '../dataModels/PartyProductModel.dart';
import '../dataModels/ProductListModel.dart';
import '../dataModels/StoreModel.dart';
import '../services/api_services.dart';
import 'invoiceDetailBottomSheet.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'outStandingList.dart';


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



class DraftSalesOrder extends StatefulWidget {
  final DraftOrderRes draftOrder;

  const DraftSalesOrder({
    Key? key,
    required this.draftOrder
  }) : super(key: key);
  
  @override
  _DraftSalesOrderState createState() => _DraftSalesOrderState();
}

class _DraftSalesOrderState extends State<DraftSalesOrder> with SingleTickerProviderStateMixin {
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
  int? _selectedCompanyId;
  TextEditingController? selectAdd;
  TextEditingController? selectArea;
  TextEditingController? selectCity;
  TextEditingController? selectTel;
  TextEditingController? selectMob;
  TextEditingController? selectOsAmt;
  TextEditingController? selectRemark;
  TextEditingController _remarkController = TextEditingController();
  late FocusNode searchFocusNode;
  late TextEditingController searchController;
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

  // Add GlobalKeys for each element you want to highlight in the tutorial
  final GlobalKey frequentlyPurchasedKey = GlobalKey(debugLabel: 'frequentlyPurchasedKey');
  final GlobalKey bouncedProductsKey = GlobalKey(debugLabel: 'bouncedProductsKey');
  final GlobalKey customerDropdownKey = GlobalKey(debugLabel: 'customerDropdownKey');
  final GlobalKey retailerSelectorKey = GlobalKey(debugLabel: 'retailerSelectorKey');
  final GlobalKey productSelectorKey = GlobalKey(debugLabel: 'productSelectorKey');
  final GlobalKey showMoreKey = GlobalKey(debugLabel: 'showMoreKey');
  final GlobalKey addButtonKey = GlobalKey(debugLabel: 'addButtonKey');
  final GlobalKey osAmountKey = GlobalKey(debugLabel: 'osAmountKey');
  bool _showTutorial = false; // Add this flag to control tutorial visibility

  bool _isExpanded = false;
  @override
  void initState() {
    super.initState();
    searchFocusNode = FocusNode();
    searchController = TextEditingController();
    print("DraftSalesOrder State Initialized"); // Debug print
    _checkTutorialStatus(); // Add this method to check if tutorial should be shown


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


    selectAdd = TextEditingController(text: "${widget.draftOrder.add1},${widget.draftOrder.add2}");
    selectArea = TextEditingController(text:widget.draftOrder.area);
    selectCity = TextEditingController(text: widget.draftOrder.city);
    selectTel = TextEditingController(text: widget.draftOrder.teleno);
    selectMob = TextEditingController(text: widget.draftOrder.mobileNo);
    selectOsAmt = TextEditingController();
    selectRemark = TextEditingController(text: widget.draftOrder.oreMark);
    _quantityController.text = _quantity.toString(); // Set initial value

    _tabController = TabController(length: 2, vsync: this);
    fetchData();

    selectRemark?.addListener((){
      if(productListItem.isNotEmpty){
        setState(() {
          productListItem.first.remark = selectRemark?.text;
        });
      }

    });



    print("calinggggggggggggggggggg");
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
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Now the widget is built and you can access the keys
      if (frequentlyPurchasedKey.currentContext != null) {
        debugPrint('Add Button found');
      } else {
        debugPrint('Add Button is not found.');
      }
    });
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true; // Show loader
    });
    await _fetchDivisionAndCompanies(); // Call the first function and wait for it to complete
    print("check salesIdd ${smid}");
    print("check salesIdd ${_selectedCustomerId}");
    print("check salesIdd ${regCode}");
    product = (await fetchPartyProductData(companyId: _selectedCustomerId!,isWeekly: "false",regCode: regCode!,smanId: smid!))!; // Then call the second function
    checkAndFetchReceivable();
    addExisting();
    for (var store in product.data!) {
      // Loop through each party in the party list of the store

      retailerList = store.party!;
      productList = store.product!;
    }
  }

  Future<void> addExisting() async{

    List<int> d_companyId = [];
    List<ProductList> products = widget.draftOrder.details.map((selectedProduct) {
      print("company iddd checkkkk ${selectedProduct.companyId}");
      int? selectedCompanyId = selectedProduct.companyId;
      if (!d_companyId.contains(selectedCompanyId)) {
        d_companyId.add(selectedCompanyId!);
      }
      return ProductList(
        name: selectedProduct.pname,
        packing: selectedProduct.pcode.toString(),
        scheme: "",
        itemDetailid: selectedProduct.itemDetailId,
        ledidParty: _selectedRetailer?.ledidParty,
        qty: selectedProduct.qty ?? 0,
        rate: double.parse(selectedProduct.ptr ?? '0.0'),
        free: selectedProduct.free,
        mrp: selectedProduct.mrp,
        ptr: selectedProduct.ptr,
        remark: selectedProduct.remark,
        companyid: selectedProduct.companyId,
        stock: ""!,
        pid: selectedProduct.pid,
        odid: selectedProduct.odid,
      );
    }).toList();

    ProductListItem orderItem = ProductListItem(
      data: products,
      companyId: d_companyId,
      salesmanId: _selectedRetailer?.smanid ?? widget.draftOrder.smanId,
      cusrid: userId,
      userType: "Distributor",
      dType: _selectedDeliveryId,
      remark: widget.draftOrder.oreMark,
      grpCode: widget.draftOrder.grpCode ?? widget.draftOrder.regCode,
      ohid: widget.draftOrder.ohid,
      orderStatus: 1,
    );

    addProduct(orderItem);

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
        _selectGroupCode = stores[0].regCode;
        _selectedCompanyId = stores[0].companyId;

        // Optionally, set the default selected customer
        _selectedCustomer = customerList.isNotEmpty ? customerList[0] : null;
      }

    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching data: $e');
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
      // Fetch receivable data if _selectedRetailer is not null
      receivableList = await fetchReceivable();
      frequentlyList = await fetchFrequently();
      bouncedList = await fetchBounced();
      setState(() {
        selectOsAmt?.text = receivableList?.total.toString() ?? "";
      });

      print("check the receivavle $receivableList");

  }


  Future<ReceivableListRes> fetchReceivable() async {
    try {
      Map<String, dynamic> requestBody = {
        'reg_code': regCode?.substring(0, 7),
        'company_id': _selectedCustomerId,
        'ledid_party': _selectedRetailer?.ledidParty ?? widget.draftOrder.ledidParty,
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
        print("check the receivablesss ${data.toString()}"); // Log the response for debugging

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
        'ledid_party': _selectedRetailer?.ledidParty ?? widget.draftOrder.ledidParty,
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
        'ledid_party': _selectedRetailer?.ledidParty ??  widget.draftOrder.ledidParty,
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

  Future<PartyProductModel?> fetchPartyProductData({required int companyId, required String isWeekly, required String regCode, required int smanId}) async {


    final String apiUrl = ApiConfig.reqPartyProduct();; // Replace with your API URL

    // Define the request body
    Map<String, dynamic> requestBody = {
      'companyid': companyId,
      'isweekly': isWeekly,
      'reg_code': regCode,
      'smanid': smanId,
    };

    print("checl party body ${requestBody}");

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
        debugPrint("party Product list ${responseData.toString()}");
        return PartyProductModel.fromJson(responseData);
      } else {
        print("Failed to load data. Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }finally {
      setState(() {
        isLoading = false; // Hide loader
      });
    }
  }

  Widget _buildAnimatedField(
      String label, {
        bool readOnly = false,
        String? initialValue,
        Widget? suffix,
        TextEditingController? controller,
      }) {
    bool isPhoneField = label.toLowerCase() == 'mob' || label.toLowerCase() == 'tel';

    Future<void> onTapHandler() async {
      if (controller == null || controller.text.isEmpty) {
        return;
      }

      // Clean the phone number
      String phoneNumber = controller.text.replaceAll(RegExp(r'[^\d+]'), '');

      // Check phone call permission
      if (await Permission.phone.request().isGranted) {
        try {
          // For Android and iOS compatibility, use this URI format
          final Uri phoneUri = Uri.parse('tel:$phoneNumber');

          // Check if we can launch the URL
          if (await launcher.canLaunchUrl(phoneUri)) {
            await launcher.launchUrl(phoneUri);
          } else {
            debugPrint('Could not launch phone dialer');
          }
        } catch (e) {
          debugPrint('Error launching phone dialer: $e');
        }
      } else {
        debugPrint('Phone permission denied');
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          TextFormField(
            initialValue: initialValue,
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 14.0),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(fontSize: 14.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              // Only show phone icon for Mob or Tel fields
              suffixIcon: isPhoneField
                  ? Icon(Icons.phone,
                  color: readOnly ? Colors.blue : Colors.grey)
                  : suffix,
            ),
          ),
          if (readOnly && isPhoneField)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTapHandler,
                ),
              ),
            ),
        ],
      ),
    );
  }



  Widget _buildAnimatedFieldFree(
      String label, {
        bool readOnly = false,
        String? initialValue,
        Widget? suffix,
        TextEditingController? controller,
      }) {
    return GestureDetector(
      onTap: () {
        if (_selectedProduct == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select product first...'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: AbsorbPointer(
        absorbing: _selectedProduct == null, // Makes field unclickable if null
        child: AnimatedContainer(
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
            keyboardType: TextInputType.number,
            controller: controller,
            readOnly: readOnly,
            style: TextStyle(
              fontSize: 14.0,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 14.0,
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
  Future<bool> _onWillPop() async {
    final shouldPop = await showDeleteConfirmationSheet(context);
    return shouldPop ?? false;
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showTutorial = prefs.getBool('show_sales_tutorial') ?? true;
    });
  }


  @override
  Widget build(BuildContext context) {
    print("Building DraftSalesOrder, showTutorial: $_showTutorial"); // Debug print

    Widget mainContent =
    WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey.shade200, // Subtle background color
        body: isLoading
            ? Center(child: LoadingIndicator()):
        SlidingProductPanel(productListItem: productListItem,smId: _selectedRetailer?.smanid.toString() ?? widget.draftOrder.smanId.toString(),ledidParty: _selectedRetailer?.ledidParty.toString() ?? widget.draftOrder.ledidParty,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.indigo,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () async {
                    // Using the same _onWillPop method for consistency
                    final shouldPop = await _onWillPop();
                    if (shouldPop) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true, // Centers the title regardless of device size
                  titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Consistent padding
                  title: Text(
                    'New Sales Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20, // Fixed font size
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  background: Container(
                    constraints: BoxConstraints.expand(), // Ensures full expansion
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.indigo.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea( // Ensures content respects system UI
                      child: Center(
                        child: LayoutBuilder( // Responsive icon sizing
                          builder: (context, constraints) {
                            return Icon(
                              Icons.shopping_cart,
                              size: constraints.maxWidth > 600 ? 80 : 60, // Larger icon for tablets
                              color: Colors.white.withOpacity(0.7),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  collapseMode: CollapseMode.pin, // Keeps title pinned while scrolling
                ),
                actions: [
                  IconButton(
                    key: frequentlyPurchasedKey,
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
                              companyid: items.dCompanyid,
                              pid: items?.pid,
                              stock: items.totalStock,
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
                    key: bouncedProductsKey,
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
                              companyid: items.dCompanyid,
                              pid: items?.pid,
                              stock: items.totalStock,
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
                  IconButton(
                    icon: Icon(Icons.help,color: Colors.white70,),
                    tooltip: 'Help',
                    onPressed: () {
                      setState(() {
                        _showTutorial = true;
                      });
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
                                                _selectedCompanyId = newValue?.id;
                                                print("check grp code ${_selectGroupCode}");
                                                fetchApi();
                                              });
                                            },
                                          ),
                                          SizedBox(height: 10), // Add spacing between elements
                                          // Bottom Sheet for Retailer
                                          GestureDetector(
                                            key: retailerSelectorKey,
                                            onTap: () => _showRetailerBottomSheet(context),
                                            child: _buildBottomSheetTrigger(
                                              'Retailer',
                                              _selectedRetailer != null && _selectedRetailer!.partyname!.isNotEmpty
                                                  ? _selectedRetailer!.partyname! // Display party name if selected
                                                  : widget.draftOrder.partyName, // Default text when no retailer is selected
                                            ),
                                          ),
                                          SizedBox(height: 10), // Add spacing between elements

                                          // Bottom Sheet for Product
                                          GestureDetector(
                                            key: productSelectorKey,
                                            onTap: () => _showProductBottomSheet(
                                              context,
                                              onProductSelected: (product) {
                                                setState(() {
                                                  _selectedProduct = product;
                                                });
                                              },
                                            ),
                                            child: _buildBottomSheetTrigger('Product Name', _selectedProduct?.pname ?? ''),
                                          ),

                                          SizedBox(height: 16),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Center all children
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 8,bottom: 8,left: 4,right: 0), // Added padding for better spacing
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
                                                              if(_selectedProduct != null ){
                                                                setState(() {
                                                                  _quantity = (_quantity - 1).clamp(0, 100);
                                                                  _quantityController.text = _quantity.toString();
                                                                });
                                                              }else{
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text('Please select product first...'),
                                                                    backgroundColor: Colors.red, // Optional: Customize the color
                                                                    duration: Duration(seconds: 2), // Duration for the SnackBar
                                                                  ),
                                                                );
                                                              }

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
                                                              if(_selectedProduct != null ){
                                                                setState(() {
                                                                  _quantity = (_quantity + 1).clamp(0, 100);
                                                                  _quantityController.text = _quantity.toString();
                                                                });
                                                              }else{
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text('Please select product first...'),
                                                                    backgroundColor: Colors.red, // Optional: Customize the color
                                                                    duration: Duration(seconds: 2), // Duration for the SnackBar
                                                                  ),
                                                                );
                                                              }

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
                                                child: _buildAnimatedFieldFree(
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
                                              _selectedProduct != null
                                                  ? GestureDetector(
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
                                                  key: showMoreKey,
                                                ),
                                              )
                                                  : SizedBox.shrink(),

                                              Padding(padding: EdgeInsets.only(right: 10),
                                                child: ElevatedButton(
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
                                                          stock: _selectedProduct?.totalStock!
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
                                                  child: Text('Add', style: TextStyle(fontSize: 12, color: Colors.white),key: addButtonKey,),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue.shade700, // Change this color as per your theme
                                                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 13.0),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                  ),
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
                                                                print("Check outstanding: ${jsonEncode(receivableList)}");

                                                                if(receivableList!.data!.isEmpty){
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text('OutStanding Not Found'),
                                                                      backgroundColor: Colors.red, // Optional: Customize the color
                                                                      duration: Duration(seconds: 2), // Duration for the SnackBar
                                                                    ),
                                                                  );
                                                                }else{
                                                                  showInvoiceDetails(context, receivableList!);
                                                                }

                                                                // Add any action you want here
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(left: 12,right: 12,top: 5,bottom: 5), // Add padding for better tap area
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns the text and icon on opposite ends
                                                                  children: [
                                                                    Text(
                                                                      key: osAmountKey,
                                                                      selectOsAmt!.text.isNotEmpty && selectOsAmt!.text != '0'
                                                                          ? 'OS Amount: ₹${selectOsAmt!.text}'
                                                                          : 'OS Amount',
                                                                      style: TextStyle(
                                                                        color: (selectOsAmt!.text.isNotEmpty && selectOsAmt!.text != '0')
                                                                            ? Colors.green
                                                                            : Colors.black,
                                                                        fontSize: 15,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    IconButton(
                                                                      icon: Icon(Icons.share_sharp, color: Colors.blue), // Share icon with blue color
                                                                      onPressed: () {
                                                                        sharePdf(receivableList!.data!);

                                                                      },
                                                                    ),
                                                                  ],
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
                                                          if(productListItem.isNotEmpty){
                                                            productListItem.first.dType = int.parse(newValue!.value);
                                                          }
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


      ),
    );

    return
    _showTutorial
        ? SalesOrderTutorial(
      child: mainContent,
      onComplete: () async {
        print("Tutorial Completed"); // Debug print
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('show_sales_tutorial', false);
        setState(() {
          _showTutorial = false;
        });
      },
      frequentlyPurchasedKey: frequentlyPurchasedKey,
      bouncedProductsKey: bouncedProductsKey,
      customerDropdownKey: customerDropdownKey,
      retailerSelectorKey: retailerSelectorKey,
      productSelectorKey: productSelectorKey,
      showMoreKey: showMoreKey,
      addButtonKey: addButtonKey,
      osAmountKey: osAmountKey,

    ) : mainContent;
  }

  Future<void> fetchApi()async {
    product = (await fetchPartyProductData(companyId: _selectedCustomerId!,isWeekly: "false",regCode: regCode!,smanId: smid!))!; // Then call the second function

    for(var product in product.data!){
      setState(() {
        retailerList = product.party!;
        productList = product.product!;
      });
    }

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

  Future<void> sharePdf(List<Receivable> party) async {
    print("Starting PDF generation and sharing process...");

    try {
      // Generate the PDF data with party-specific details
      List<InvoiceData> invoiceDataList = [];

      // Create a list of Invoice items if needed
      List<Invoice> invoices = party.map((invoice) => Invoice(
        prefix: invoice.prefix!,
        invNo: invoice.invno.toString(),
        invDate: invoice.invdate!,
        dueDate: invoice.duedate!,
        pm: invoice.pm!,
        invAmt: double.parse(invoice.invamt!),
        cnAmt: double.parse(invoice.cnamt!),
        recvAmt: double.parse(invoice.recdamt!),
        balance: double.parse(invoice.balance!),
        salesman: invoice.sman!,
      )).toList();

      // Create an InvoiceData instance for each order
      InvoiceData invoiceData = InvoiceData(
        disName: _selectedRetailer!.partyname!,
        disPartyCode: _selectedRetailer!.partycode!,
        disArea: _selectedRetailer!.area,
        disCity: _selectedRetailer!.city,
        disMobile: _selectedRetailer!.mobileno,
        disEmail: _selectedRetailer!.email,
        retName:_selectedRetailer!.partyname!,
        retPartyCode: _selectedRetailer!.partycode!,
        retArea:  _selectedRetailer!.area,
        retCity:  _selectedRetailer!.city,
        retMobile:  _selectedRetailer!.mobileno,
        retEmail:  _selectedRetailer!.email,
        invoices: invoices,
        totalBalance: double.parse(selectOsAmt!.text) , // Assuming `totalBalance` is part of each order
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
        subject: 'Outstanding Distributor - ${_selectedRetailer!.partyname}',
        text: 'Check out the outstanding distributor details for ${_selectedRetailer!.partyname}!',
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


  // The delete confirmation sheet you provided
  Future<bool?> showDeleteConfirmationSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            "Do you really want to continue?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 0.5, color: Colors.grey),
                    SizedBox(height: 0.5),
                  ],
                ),
              ),

              // Delete Button Container
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        "Yes, I'm sure",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // Cancel Button Container
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF0A84FF),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> showAddConfirmationSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            "This product is already added!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 0.5, color: Colors.grey),
                    SizedBox(height: 0.5),
                  ],
                ),
              ),

              // Delete Button Container
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        "Yes, I'm sure",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // Cancel Button Container
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        'Remove',
                        style: TextStyle(
                          color: Color(0xFF0A84FF),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
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


  void addProduct(ProductListItem orderItem) async {
    // Check if the item already exists in the list
    final existingIndex = productListItem.indexWhere((item) => item.data?[0].pid == orderItem.data?[0].pid);

    // If it exists, show confirmation sheet
    if (existingIndex != -1) {
      final shouldOverride = await showAddConfirmationSheet(context);
      print("check the bool ${shouldOverride}");
      if (shouldOverride == true) {
        // Override the existing item
        setState(() {
          productListItem[existingIndex] = orderItem;
        });
      }
    } else {
      // If item doesn't exist, add it directly
      setState(() {
        productListItem.add(orderItem);
      });
    }
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
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear(); // Clears the text in the TextField
                            },
                          ),
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
          if(productListItem.isNotEmpty){
            setState(() {
              productListItem.first.salesmanId = _selectedRetailer?.smanid;

            });
          }
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

  void _showProductBottomSheet(BuildContext context, {Function(Product)? onProductSelected}) {


    final searchController = TextEditingController();
    final quantityController = TextEditingController();
    final remarkController = TextEditingController();
    List<Product> selectedProducts = [];
    bool isMultiSelectMode = false;

    List<Product> _filterRetailers(String query) {
      if (query.isEmpty) return productList;

      bool _matchesQuery(String? field, String query, {bool fullMatch = false}) {
        if (field == null) return false;
        return fullMatch
            ? field.toLowerCase().contains(query.toLowerCase())
            : field.toLowerCase().startsWith(query.toLowerCase());
      }

      String trimmedQuery = query.trim().toLowerCase();
      return productList.where((retailer) {
        return _matchesQuery(retailer.pname, trimmedQuery, fullMatch: query.startsWith(' ')) ||
            _matchesQuery(retailer.pcode.toString(), trimmedQuery, fullMatch: query.startsWith(' '));
      }).toList();
    }

    void _processSelectedProducts() {

      print("group code ${_selectGroupCode}");


      List<int> d_companyId = [];
      for(var id in selectedProducts){
        int selectedCompanyId = id!.dCompanyid!;

        if (!d_companyId.contains(selectedCompanyId)) {
          d_companyId.add(selectedCompanyId);
        }
      }

      for (var items in selectedProducts) {
        List<ProductList> products = [
          ProductList(
            name: items?.pname,
            packing: items!.pcode.toString(),
            scheme: items?.scheme,
            itemDetailid: items?.itemdetailid,
            ledidParty: _selectedRetailer?.ledidParty,
            qty:  0,
            free: 0,
            schPercentage: "",
            rate: double.parse(items!.ptr ?? '0.0'),
            mrp: items?.mrp,
            ptr: items?.ptr,
            amount: "0",
            remark: selectRemark?.text,
            companyid: items.dCompanyid,
            pid: items?.pid,
            stock: items.totalStock,
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

      Navigator.pop(context);

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
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.teal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Products Below",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          if (isMultiSelectMode) Row(
                            children: [
                              Text("${selectedProducts.length} selected", style: TextStyle(color: Colors.white)),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: selectedProducts.isEmpty ? null : _processSelectedProducts,
                                child: Text('Add'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.teal),
                              ),
                            ],
                          ),
                        ],
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
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear(); // Clears the text in the TextField
                            },
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => filteredRetailers = _filterRetailers(value));
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredRetailers.isEmpty
                          ? Center(child: Text('No products found'))
                          : ListView.builder(
                        controller: controller,
                        itemCount: filteredRetailers.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(
                            filteredRetailers[index],
                            searchController.text,
                            context,
                            isSelected: selectedProducts.contains(filteredRetailers[index]),
                            onTap: () {
                              if (isMultiSelectMode) {
                                setState(() {
                                  if (selectedProducts.contains(filteredRetailers[index])) {
                                    selectedProducts.remove(filteredRetailers[index]);
                                    if (selectedProducts.isEmpty) isMultiSelectMode = false;
                                  } else {
                                    selectedProducts.add(filteredRetailers[index]);
                                  }
                                });
                              } else {
                                // Single selection: call onProductSelected and close bottom sheet
                                onProductSelected?.call(filteredRetailers[index]);
                                Navigator.pop(context);
                              }
                            },
                            onLongPress: () {
                              setState(() {
                                if (!isMultiSelectMode) {
                                  isMultiSelectMode = true;
                                  selectedProducts.add(filteredRetailers[index]);
                                }
                              });
                            },
                          );
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



  Widget _buildProductCard( Product product,
  String searchQuery,
  BuildContext context, {
  required bool isSelected,
  required Function() onTap,
  required Function() onLongPress}) {
    Color cardColor;

    // Ensure product.totalStock is treated as an integer for comparison
    int stock = int.tryParse(product.totalStock?.toString() ?? '0') ?? 0;

    // Determine card color based on stock and scheme availability
    if (isSelected) {
      cardColor = Colors.teal.shade100; // Selected color
    } else if (stock > 0 && (product.scheme ?? '').isNotEmpty) {
      cardColor = Colors.lightBlue.shade100;
    } else if (stock > 0) {
      cardColor = Colors.lightGreen.shade100;
    } else {
      cardColor = Colors.red.shade100;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        color: cardColor,
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child:
        Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 230,
                      child: _highlightText("${product.pname}${product.packing}" ?? 'N/A', searchQuery) ,
                    ),
                    Spacer(),
                    _highlightText("(${product.pcode})" ?? 'N/A', searchQuery),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 210,
                      child:  Text("${product.dmfg}",style: TextStyle(fontSize: 12),),
                    ),

                    Container(
                      width: 100,
                      child: Text(
                        _selectedCompanyId == 0 ? product.companyname! : "" ?? "N/A",
                        style: TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1, // Limit to one line if needed
                      ),
                    ),


                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow3(Icons.currency_rupee, 'MRP:', '${product.mrp ?? 'N/A'}'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow3(Icons.currency_rupee, 'PTR:', '${product.ptr ?? 'N/A'}'),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow3(Icons.production_quantity_limits, 'Stock:', '${product.totalStock ?? 'N/A'}'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow3(Icons.schema, 'Scheme:', '${product.scheme ?? ''}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              right: 8,
              top: 8,
              child: Icon(Icons.check_circle, color: Colors.teal),
            ),
        ],),

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
        overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
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

    // Render using RichText, limited to two lines with overflow handling
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(color: Colors.black), // Default text color
        children: spans,
      ),
    );
  }

  Widget _highlightManText(String text, String query, {bool fullMatch = false}) {
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
            width: 280,
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
  final Function(List<ProductListItem>)? onProductListUpdated;
  final String ledidParty;
  final String smId;
  const ProductListWidget({
    Key? key,
    required this.productListItem,
    this.onProductListUpdated,
    required this.ledidParty,
    required this.smId
  }) : super(key: key);

  @override
  _ProductListWidgetState createState() => _ProductListWidgetState();
}


class _ProductListWidgetState extends State<ProductListWidget> {
  final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  late List<ProductList> products = [];
  bool _isLoading = false; // Loading state
  late TextEditingController _remarkController;
  late TextEditingController _rateController;
  final ScrollController _scrollController = ScrollController();
  int _expandedIndex = -1;

  @override
  void initState() {
    _rateController = TextEditingController(text: "0.0");
    _remarkController = TextEditingController(text: "");

    updateProductsList();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _rateController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ProductListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("did anything chnagessss ${oldWidget.productListItem.length}");
    updateProductsList();
  }

  void updateProductsList() {
    setState(() {
      products = [];
      for (var item in widget.productListItem) {
        if (item.data != null) {
          products.addAll(item.data!);
        }
        print(item);
      }
    });
  }
  // Method to scroll to the expanded card
  void _scrollToExpandedCard(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if index is the last item in the list or if it's off-screen
      final double cardOffset = 200.0 * index; // Assuming each card height is approx. 200
      final double currentOffset = _scrollController.offset;
      final double screenHeight = MediaQuery.of(context).size.height;

      // Scroll to the card if it's hidden or partially off-screen
      if (cardOffset > currentOffset + screenHeight - 250) {
        _scrollController.animateTo(
          cardOffset - 150, // Adjust scroll position to bring the card fully into view
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }


  Future<bool?> showDeleteConfirmationSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            'Product will be deleted',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 0.5, color: Colors.grey),
                    SizedBox(height: 0.5),
                  ],
                ),
              ),

              // Delete Button Container
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // Cancel Button Container
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF0A84FF),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

// Modified removeProduct function that handles the actual deletion
  void removeProduct(ProductList product) {
    setState(() {
      // Remove from local products list
      products.remove(product);

      // Create a new list to hold updated items
      List<ProductListItem> updatedList = [];

      // Remove from source productListItem and build new list
      for (var item in widget.productListItem) {
        if (item.data != null) {
          item.data!.removeWhere((p) =>
          p.itemDetailid == product.itemDetailid &&
              p.pid == product.pid
          );

          // Only add items that still have products
          if (item.data!.isNotEmpty) {
            updatedList.add(item);
          }
        }
      }

      // Notify parent widget of the update
      widget.onProductListUpdated?.call(updatedList);
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
                controller: _scrollController,
                itemCount: products.length,
                padding: EdgeInsets.symmetric(horizontal: 5),
                itemBuilder: (context, index) {
                  final reversedItem = products.reversed.toList()[index];
                  return SingleChildScrollView(
                    child: _buildProductCard(reversedItem, index),
                  );
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
                        _submitDraftOrder(widget.productListItem[0], products);
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
        if (_isLoading) ...[
          ModalBarrier(
            dismissible: false, // Prevent dismissing the overlay by tapping
            color: Colors.black54, // Optional: semi-transparent background color
          ),
          Center(
            child: Lottie.asset(
              'assets/animations/order.json', // Path to your Lottie animation file
              width: 200, // You can adjust the size as per your need
              height: 200,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductCard(ProductList product, int index) {
    _rateController = TextEditingController(text: product.ptr ?? "");
    _remarkController = TextEditingController(text: product.remark ?? "");

    return

      Dismissible(
      key: Key(product.hashCode.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        final bool? shouldDelete = await showDeleteConfirmationSheet(context);
        if (shouldDelete == true) {
          removeProduct(product);
        }
        return false;
      },
      onDismissed: (direction) {
        removeProduct(product);
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: Key('expansion_tile_${index}'),
              onExpansionChanged: (expanded) {
                setState(() {
                  _expandedIndex = expanded ? index : -1;
                });
                if (expanded) {
                  _scrollToExpandedCard(index);
                }
              },
              initiallyExpanded: _expandedIndex == index,
              maintainState: false,
              trailing: Icon(
                _expandedIndex == index
                    ? Icons.arrow_circle_up_sharp
                    : Icons.arrow_circle_down_sharp,
                color: Colors.grey,
                size: 18,
              ),
              tilePadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              expandedAlignment: Alignment.centerLeft,
              childrenPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            product.name!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        _buildInfoChip(
                          currencyFormat.format(product.total),
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: _buildInfoChip('MRP: ${product.mrp}', Colors.green),
                    ),
                    if (product.free! > 0) ...[
                      Flexible(
                        flex: 1,
                        child: _buildInfoChip('Free: ${product.free}', Colors.orange),
                      ),
                      SizedBox(width: 12),
                    ],
                    Flexible(
                      flex: 3,
                      child: _buildInfoChip('PTR: ${product.ptr}', Colors.blueGrey),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: _buildQuantityControl(product),
                      ),
                    ),
                  ],
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableRate(
                              'Rate',
                              _rateController,
                                  (newValue) {
                                // Handle rate change
                                setState(() {

                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailItem(
                              'Stock',
                              (product.stock == null || product.stock!.isEmpty)
                                  ? '--'
                                  : product.stock!,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildDetailItem(
                              'Scheme',
                              (product.scheme == null || product.scheme!.isEmpty)
                                  ? '--'
                                  : product.scheme!,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: 300,
                            height: 50,
                            child: TextField(
                              controller: _remarkController,
                              decoration: InputDecoration(
                                hintText: 'Add remark...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              onChanged: (value) {
                                setState(() {
                                  product.remark = value;
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
      ),
    );
  }


  Future<void> _submitOrder(ProductListItem productItem, List<ProductList> product) async {
    final url = Uri.parse(ApiConfig.reqCreateOrder());
    final headers = {'Content-Type': 'application/json'};

    if(widget.ledidParty == ""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Select Retailer'),
          backgroundColor: Colors.red, // Optional: Customize the color
          duration: Duration(seconds: 2), // Duration for the SnackBar
        ),
      );
    }

    print(" check the jhhhj ${widget.ledidParty}");

    List<Orders> orders = [];
    for (var items in product) {
      print("odid valuess check ${items.odid}");
      orders.add(Orders(
        itemDetailid: items.itemDetailid!,
        ledidParty:int.parse(widget.ledidParty) ,
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
      remark: productItem.remark,
      grpCode: productItem.grpCode,
      ohid: productItem.ohid,
      companyId: productItem.companyId,
      salesmanId: int.parse(widget.smId) ,
      cusrid: productItem.cusrid,
      userType: productItem.userType,
      dType: productItem.dType,
      orderStatus: 1,
    );

    print("check the body ${orderModel.toJson()}");

    setState(() {
      _isLoading = true; // Show loader
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(orderModel),
      );

      // Ensure we are still mounted before modifying state
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loader
        });

        if (response.statusCode == 201) {
          final responseBody = jsonDecode(response.body);
          print('Order submitted successfully: $responseBody');


          // Navigate to another screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SalesOrderList()), // Your target screen
                (Route<dynamic> route) => route.isFirst, // Keep only the initial route in the stack
          );


        } else {
          print('Failed to submit order: ${response.statusCode}');
          print('Response: ${response.body}');

          // Show failure message dialog
          AwesomeDialog(
            context: context,
            animType: AnimType.topSlide,
            headerAnimationLoop: true,
            dialogType: DialogType.error,
            showCloseIcon: false,
            title: 'Failure',
            desc: 'Something went wrong. Try again later.',
            btnOkOnPress: () {
              debugPrint('Dialog button clicked');
            },
            btnOkIcon: Icons.error,
          ).show();
        }
      }
    } catch (e) {
      // Handle any errors
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loader
        });

        print('Error occurred while submitting order: $e');

        // Show error message dialog
        AwesomeDialog(
          context: context,
          animType: AnimType.topSlide,
          headerAnimationLoop: true,
          dialogType: DialogType.error,
          showCloseIcon: false,
          title: 'Failure',
          desc: 'Something went wrong. Try again later.',
          btnOkOnPress: () {
            debugPrint('Dialog button clicked');
          },
          btnOkIcon: Icons.error,
        ).show();
      }
    }
  }

  Future<void> _submitDraftOrder(ProductListItem productItem, List<ProductList> product) async {
    final url = Uri.parse(ApiConfig.reqCreateOrder());
    final headers = {'Content-Type': 'application/json'};
    if(widget.ledidParty == ""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Select Retailer'),
          backgroundColor: Colors.red, // Optional: Customize the color
          duration: Duration(seconds: 2), // Duration for the SnackBar
        ),
      );
    }
    List<Orders> orders = [];
    for (var items in product) {
      orders.add(Orders(
        itemDetailid: items.itemDetailid!,
        ledidParty: int.parse(widget.ledidParty) ,
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
      remark: productItem.remark,
      grpCode: productItem.grpCode,
      ohid: productItem.ohid,
      companyId: productItem.companyId,
      salesmanId: int.parse(widget.smId),
      cusrid: productItem.cusrid,
      userType: productItem.userType,
      dType: productItem.dType,
      orderStatus: 0,
    );

    print("check the body ${orderModel.toJson()}");

    setState(() {
      _isLoading = true; // Show loader
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(orderModel),
      );

      // Ensure we are still mounted before modifying state
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loader
        });

        if (response.statusCode == 201) {
          final responseBody = jsonDecode(response.body);
          print('Order submitted successfully: $responseBody');


          // Navigate to another screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DraftOrderList()), // Your target screen
                (Route<dynamic> route) => false, // This removes all previous routes
          );

        } else {
          print('Failed to submit order: ${response.statusCode}');
          print('Response: ${response.body}');

          // Show failure message dialog
          AwesomeDialog(
            context: context,
            animType: AnimType.topSlide,
            headerAnimationLoop: true,
            dialogType: DialogType.error,
            showCloseIcon: false,
            title: 'Failure',
            desc: 'Something went wrong. Try again later.',
            btnOkOnPress: () {
              debugPrint('Dialog button clicked');
            },
            btnOkIcon: Icons.error,
          ).show();
        }
      }
    } catch (e) {
      // Handle any errors
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loader
        });

        print('Error occurred while submitting order: $e');

        // Show error message dialog
        AwesomeDialog(
          context: context,
          animType: AnimType.topSlide,
          headerAnimationLoop: true,
          dialogType: DialogType.error,
          showCloseIcon: false,
          title: 'Failure',
          desc: 'Something went wrong. Try again later.',
          btnOkOnPress: () {
            debugPrint('Dialog button clicked');
          },
          btnOkIcon: Icons.error,
        ).show();
      }
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
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEditableRate(
      String label,
      TextEditingController controller,
      Function(double) onChanged,
      ) {
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
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixText: '₹ ',
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            onChanged: (value) {
              final newRate = double.tryParse(value);
              if (newRate != null) {
                onChanged(newRate);
              }
            },
            // Adding a focus node to handle keyboard display
            focusNode: FocusNode(),
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
        minHeight: 35,
        maxHeight: 35,
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
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: Icon(
                  Icons.remove,
                  size: 15,
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
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: Icon(
                  Icons.add,
                  size: 15,
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



