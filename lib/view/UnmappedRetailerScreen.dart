import 'dart:convert';

import 'package:distributers_app/components/LoadingIndicator.dart';
import 'package:distributers_app/dataModels/MatchProductRes.dart';
import 'package:distributers_app/dataModels/MatchingPartyRes.dart';
import 'package:distributers_app/dataModels/UnmatchedProductRes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dataModels/StoreModel.dart';
import '../dataModels/UnmatchingPartyRes.dart';
import '../services/api_services.dart';
import 'package:http/http.dart' as http;

class ProductCardState {
  String selectedValue;
  String selectedEmail;
  String selectedPhone;
  MatchParty? selectedMatchProduct;  // Add this to track selected match product
  MatchParty? selectedUnmatchProduct;  // Add this to track selected unmatch product

  ProductCardState({
    this.selectedValue = "",
    this.selectedEmail = "",
    this.selectedPhone = "",
    this.selectedMatchProduct,
    this.selectedUnmatchProduct,
  });
}

class UnmappedRetailerScreen extends StatefulWidget {
  const UnmappedRetailerScreen({Key? key}) : super(key: key);

  @override
  _UnmappedRetailerScreenState createState() => _UnmappedRetailerScreenState();
}

class _UnmappedRetailerScreenState extends State<UnmappedRetailerScreen> {
  List<MatchingParty> retailer = []; // This will hold the fetched invoices
  List<MatchingParty> filteredRetailer= []; // This will hold the fetched invoices
  int totalRequest = 0;
  List<UnmatchParty> unMatchedRetailer = []; // This will hold the fetched invoices

  final Map<int, ProductCardState> cardStates = {};

  // Example state variables
  bool _isDropdownVisible = false;
  bool _isSearchVisible = false;
  bool _isDateRangeVisible = false;
  List<Store> stores = [];
  String? regCode;
  TextEditingController searchController = TextEditingController();
  TextEditingController matchSearchController = TextEditingController();

  String? selectedCompanyName;
  String? selectRegCode;
  int? selectedCompanyId;
  bool isLoading = true; // To manage loading state

  MatchParty? _selectedProduct;

  int? companyId;
  String dmfg = "";
  String generic = "";
  int itemDetailId = 0;
  String packing = "";
  int pcode = 0;
  int leditParty = 0;
  String alCode = "";
  String regcode = "";
  String type = "";

  // Define variables with prefix 'other' for each field in the "o_product" section
  int? retailerId;
  int? retailerRgId;
  String retailerRegName = "";

  String retailerCode = "";

  late MatchingParty retailerModelS;
  String selectSuggest = "Select...";
  int _counter = 1;
  final TextEditingController _pageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0.0;
  MatchParty unMatchProduct = MatchParty();
  List<MatchingParty> mappedProducts = [];


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_saveScrollPosition);
    _pageController.text = _counter.toString(); // Set initial text to counter value

    _fetchDivisionAndCompanies(); // Fetch data on init


    // Initialize any variables or state here
    // For example, set the default state for filter visibility
    _isDropdownVisible = false;
    _isSearchVisible = false;
    _isDateRangeVisible = false;

    for (var product in retailer) { // Assuming `products` is your product list
      final itemDetailId = product.ledidParty!;
      if (cardStates[itemDetailId]?.selectedValue.isNotEmpty == true &&
          cardStates[itemDetailId]!.selectedValue != "Select..." &&
          !mappedProducts.contains(product)) {
        mappedProducts.add(product);
      }
    }
  }

  void _saveScrollPosition() {
    _scrollPosition = _scrollController.position.pixels;
  }

  void _restoreScrollPosition() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollPosition);
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
        selectRegCode = stores[0].regCode;
        await _fetchMapRetailer("1");
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


  Future<void> _fetchMapRetailer(String page) async {
    String apiUrl = ApiConfig.reqMatchingParty();

    final body = jsonEncode({
      "reg_code": selectRegCode,
      "companyid": selectedCompanyId,
      "pagenum": page,
      "pagesize": 50,
      "userInput": matchSearchController.text,
    });

    print("Request body: $body");

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final List<dynamic>? retailerList = jsonData['data'];
        int request = jsonData['totalProduct'] ?? 0; // Safeguard against null

        if (retailerList != null && retailerList.isNotEmpty) {
          setState(() {
            retailer = retailerList.map((json) => MatchingParty.fromJson(json)).toList();
            filteredRetailer = retailer;
            totalRequest = request;
            print("Filtered retailer list: ${json.encode(filteredRetailer)}");
            retailerModelS = (filteredRetailer.isNotEmpty ? filteredRetailer[0] : null)!;
          });
        } else {
          print('No retailers found in the response');
        }
      } else {
        throw Exception('Failed to load data: ${response.body}');
      }
    } catch (e) {
      setState(() {
        filteredRetailer = [];
      });
      print('Error fetching retailers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong! Please try again later.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUnMapProduct() async {
    String apiUrl = ApiConfig.reqUnmatchedParty(); // Replace with actual API URL


    final body = jsonEncode({
      "reg_code": selectRegCode,
      "companyid": selectedCompanyId,
      "userInput": searchController.text,
      "pagenum":1
    });

    print("check the bodies  $body");


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
            unMatchedRetailer = invoiceList.map((json) => UnmatchParty.fromJson(json)).toList();
          });
        } else {
          unMatchedRetailer.clear();
          print('No invoices found in the response');
          // Handle no data case, like showing a message in UI
        }
      } else {
        unMatchedRetailer.clear();
        throw Exception('Failed to load invoices: ${response.body}');
      }
    } catch (e) {


      print('Error fetching productss: $e');
      // Show an error message in the UI using a SnackBar

    }
  }

  Future<void> _mappedRetailer() async {
    final prefs = await SharedPreferences.getInstance();
    String apiUrl = ApiConfig.reqMappingParty(); // Replace with actual API URL

    // Construct the request body
    final Map<String, dynamic> requestBody = {
      "id": 0,
      "party": {
        "Regcode": regcode,
        "Type": "CUST",
        "LedId_Party": leditParty ?? 0, // Safeguard against null values
        "CompanyId": companyId ?? 0,
        "ALCode": alCode ?? "",
      },
      "retailer": {
        "r_id": retailerId ?? 0,
        "reg_name": retailerRegName ?? "",
        "r_code": retailerCode ?? "",
        "rg_id": retailerRgId ?? 0,
      },
      "cusrid": prefs.getInt("u_id") ?? 0, // Safeguard against null
      "eusrid": 0,
    };

    print("Request body: $requestBody");

    setState(() {
      isLoading = true; // Set loading to true when the request starts
    });

    try {
      // Save scroll position before making the API call
      _saveScrollPosition();

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"}, // Set content-type header
        body: jsonEncode(requestBody), // Convert requestBody to JSON string
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print("Response data: $jsonData");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Party Mapped Successfully.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Fetch new data and restore the scroll position after completion
        await _fetchMapRetailer(_counter.toString());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _restoreScrollPosition();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to Map Product'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );

        throw Exception('Failed to map product: ${response.body}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong! Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      print("Error: $error");
    } finally {
      setState(() {
        isLoading = false; // Set loading to false when the request completes
      });
    }
  }

  void _onPageControllerValueChanged(String value) {

    final int newCounterValue = int.tryParse(value) ?? _counter;

      setState(() {
        _counter = newCounterValue; // Update _counter to match the text field's value
      });
    _fetchMapRetailer(_counter.toString()); // Call your function

  }


  void _increaseCounter() {
    setState(() {
      _counter++; // Increase the counter
      _pageController.text = _counter.toString(); // Update the TextField
    });
    _fetchMapRetailer(_counter.toString());
  }

  void _decreaseCounter() {
    setState(() {
      if (_counter > 1) {
        _counter--; // Decrease the counter, but not less than 1
        _pageController.text = _counter.toString(); // Update the TextField
      }
    });
    _fetchMapRetailer(_counter.toString());
  }

  void _updateCounterFromTextField(String value) {
    int? newValue = int.tryParse(value);
    if (newValue != null && newValue >= 1) {
      setState(() {
        _counter = newValue; // Update counter from TextField input
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'UNMAPPED RETAILER',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          if (mappedProducts.isNotEmpty)
      Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mapped Products: ${mappedProducts.length}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Call the _mappedProduct() function to handle the mapping process
              _mappedRetailer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreen[200], // Light green background color
              foregroundColor: Colors.black,     // White text color
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Map Selected'),
          ),

        ],
      ),
    ),
    // Total Requests Counter
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  children: [

                    Text(
                      'Total Requests: ',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    Text(
                      '${totalRequest}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _decreaseCounter,
                      child: Icon(Icons.keyboard_double_arrow_left, size: 25, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child:TextField(
                        controller: _pageController,
                        keyboardType: TextInputType.number,
                        onChanged: _updateCounterFromTextField,
                        onSubmitted: (value) => _onPageControllerValueChanged(value), // Passes the value to the function
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      )

                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _increaseCounter,
                      child: Icon(Icons.keyboard_double_arrow_right, size: 25, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          _buildActionButtons(),

          // Filter Fields Visibility
          Visibility(
            visible: _isDropdownVisible || _isSearchVisible || _isDateRangeVisible,
            child: Column(
              children: [
                _buildFilterFields(),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: isLoading
                ? Center(
              child: LoadingIndicator(),
            )
                : filteredRetailer.isEmpty
                ? Center(child: Text("No products available"))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredRetailer.length,
              itemBuilder: (context, index) {
                final product = filteredRetailer[index];
                return _buildProductCard(product);
              },
            ),
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
      ],
    );
  }

  Widget _buildProductCard(MatchingParty product) {
    // Initialize card state if not already done
    cardStates[product.ledidParty!] ??= ProductCardState();

    // Only set default values if no selection has been made
    if (cardStates[product.ledidParty!]!.selectedValue.isEmpty &&
        product.matchParty != null &&
        product.matchParty!.isNotEmpty) {
      final firstProduct = product.matchParty!.first;
      cardStates[product.ledidParty!] = ProductCardState(
        selectedValue: firstProduct.regName ?? "",
        selectedEmail: "",
        selectedPhone:  "",
        selectedMatchProduct: firstProduct,
      );
    }

    final bool hasSelectedValue = cardStates[product.ledidParty!]!.selectedValue.isNotEmpty &&
        cardStates[product.ledidParty!]!.selectedValue != "Select...";

    if (hasSelectedValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mappedProducts.any((mappedProduct) => mappedProduct.ledidParty == product.ledidParty)) {
          setState(() {
            mappedProducts.add(product);
          });
        }
      });
    }

    print("Mapped Products: ${mappedProducts.map((e) => e.partyname).toList()}");

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: BoxDecoration(
        color: hasSelectedValue ? Colors.lightGreen[100] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${product.partyname}" ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Email:', '${product.email ?? ''}'),
            const SizedBox(height: 4),
            _buildInfoRow('Phone:', '${product.mobileno ?? ''}'),
            const SizedBox(height: 4),
            _buildMappingDropdown(
              "Suggested Retailer",
              product.matchParty!,
              _getDefaultOrSelectedProduct(product, cardStates[product.ledidParty!]!),
                  (selectedProduct) {
                setState(() {
                  cardStates[product.ledidParty!] = ProductCardState(
                    selectedValue: selectedProduct.regName ?? "",
                    selectedEmail: selectedProduct.city ?? "",
                    selectedPhone: selectedProduct.area ?? "",
                    selectedMatchProduct: selectedProduct,
                    selectedUnmatchProduct: cardStates[product.ledidParty!]!.selectedUnmatchProduct,
                  );
                  _selectedProduct = selectedProduct;
                  _updateOtherFields(selectedProduct);
                });
              },
            ),
            const SizedBox(height: 12),
            _buildUnmatchedDropdown(
              'Search from all Retailer',
              cardStates[product.ledidParty!]!.selectedValue,
              product.ledidParty!,
              cardStates[product.ledidParty!]!.selectedUnmatchProduct,
                  (selectedProduct) {
                setState(() {
                  cardStates[product.ledidParty!] = ProductCardState(
                    selectedValue: selectedProduct.regName ?? "",
                    selectedEmail: selectedProduct.city ?? "",
                    selectedPhone: selectedProduct.area ?? "",
                    selectedMatchProduct: cardStates[product.ledidParty!]!.selectedMatchProduct,
                    selectedUnmatchProduct: selectedProduct,
                  );
                  unMatchProduct = selectedProduct;
                  _updateOtherFields(selectedProduct);
                });
              },
            ),
            const SizedBox(height: 12),
            _buildPreviewSection(product),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(MatchingParty product) {


    // Only show the preview section if there's a selected product
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Email:', cardStates[product.ledidParty!]!.selectedEmail),
                const SizedBox(height: 4),
                _buildInfoRow('Phone:', cardStates[product.ledidParty!]!.selectedPhone),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildMappingActions(product),
      ],
    );
  }

  Widget _buildMappingActions(MatchingParty product) {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.check_circle_outline,
          color: Colors.green[600]!,
          product: product,
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          icon: Icons.cancel_outlined,
          color: Colors.red[600]!,
          product: product,
        ),
      ],
    );
  }

  MatchParty _getDefaultOrSelectedProduct(MatchingParty product, ProductCardState state) {

    // First check if matchProduct list exists and is not empty
    if (product.matchParty == null || product.matchParty!.isEmpty) {
      // Return a default MatchProduct when no products are available
      return MatchParty(
        rId: -1,  // or any default id you prefer
        regName: "No products available",
        area: "",
        city: "",
      );
    }

    // If there's a selected product, try to find it in the matchProduct list
    if (state.selectedMatchProduct != null) {
      try {
        return product.matchParty!.firstWhere(
              (p) => p.rId == state.selectedMatchProduct!.rId,
          orElse: () => product.matchParty!.first,
        );
      } catch (e) {
        // If anything goes wrong, safely return the first product
        return product.matchParty!.first;
      }
    }

    // If no selection but we have products, return the first product
    return product.matchParty!.first;
  }

  Widget _buildMappingDropdown(
      String label,
      List<MatchParty> items,
      MatchParty selectedValue,
      ValueChanged<MatchParty> onChanged,
      ) {
    // Make sure items is not empty before trying to find matching value
    MatchParty matchingValue;
    try {
      matchingValue = items.firstWhere(
            (item) => item.rId == selectedValue.rId,
        orElse: () => items.first,
      );
    } catch (e) {
      // If anything goes wrong, check if 'items' has elements
      if (items.isNotEmpty) {
        matchingValue = items.first;
      } else {
        // Handle the empty case appropriately, maybe set a default value or handle the error
        matchingValue = MatchParty(
          rId: -1,  // or any default id you prefer
          area: "",
          city: "",
          state: "",
          rCode: "",
          regName: ""
        );
      }
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MatchParty>(
              isExpanded: true,
              value: matchingValue,
              hint: Text(
                "Select...",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey[600],
              ),
              items: items.map((MatchParty item) {
                return DropdownMenuItem<MatchParty>(
                  value: item,
                  child: Text(
                    item.regName ?? "",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (MatchParty? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnmatchedDropdown(
      String label,
      String displayValue,
      int productId,
      MatchParty? selectedValue,
      ValueChanged<MatchParty> onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _openDialog(productId),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedValue?.regName ?? displayValue,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  void _updateOtherFields(MatchParty selectedProduct) {
    retailerCode = selectedProduct.rCode!;
    retailerId = selectedProduct.rId;
    retailerRegName = selectedProduct.regName!;
    retailerRgId = 0;

  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              overflow: TextOverflow.ellipsis
            ),
          ),
        ),
      ],
    );
  }





  void _openDialog(int productId) {
    _showSelectionDialog((selectedValue, selectedEmail, selectedPhone) {
      setState(() {
        cardStates[productId] = ProductCardState(
          selectedValue: selectedValue,
          selectedEmail: selectedEmail,
          selectedPhone: selectedPhone,

        );
      });
    });
  }

  void _showSelectionDialog(void Function(String, String, String) onItemSelected) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 600,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Select an Option',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey.shade600),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Field
                        TextFormField(
                          controller: searchController,
                          onChanged: (value) {
                            if (value.length >= 3) {
                              _fetchUnMapProduct();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey.shade400),
                              onPressed: () {
                                searchController.clear();
                                // Optionally, you can call _fetchUnMapProduct() here if needed.
                              },
                            )
                                : null,
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        SizedBox(height: 12),

                        // Search Results
                        Container(
                          constraints: BoxConstraints(maxHeight: 450),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: unMatchedRetailer.length,
                              separatorBuilder: (context, index) => Divider(height: 1),
                              itemBuilder: (context, index) {
                                final retailer = unMatchedRetailer[index];
                                return ListTile(
                                  title: Text(
                                    "${retailer.regName  ?? ""}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${retailer.rCode ?? ''}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  onTap: () {
                                    // Pass selected values to parent callback and close the dialog
                                    onItemSelected(
                                      retailer.regName ?? "",
                                      retailer.email ?? "",
                                      retailer.mob ?? "",
                                    );

                                    retailerCode = retailer.rCode!;
                                    retailerId = retailer.rId;
                                    retailerRegName = retailer.regName!;
                                    retailerRgId = 0;
                                    searchController.clear();
                                    Navigator.pop(context);
                                  },
                                  tileColor: Colors.white,
                                  hoverColor: Colors.grey.shade50,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      // Clear the search field when the dialog is dismissed
      searchController.clear();
    });
  }
  Widget _buildActionButton({required IconData icon, required Color color,required MatchingParty product}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(icon, size: 24, color: color),
        onPressed: () {
          companyId = product.companyid;
          alCode = product.alcode ?? "";
          type = product.type ?? "";
          regcode = product.regcode ?? "";
          leditParty = product.ledidParty ?? 0;
          _mappedRetailer();
        },
      ),
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
                    selectRegCode = selectedStore.regCode;
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
              controller: matchSearchController,
              decoration: InputDecoration(
                labelText: 'Search Orders',
                border: OutlineInputBorder(), suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  searchController.clear(); // Clears the text in the TextField
                },
              ),

              ),
              onChanged: (value) {
                _fetchMapRetailer(_counter.toString());
              },
            ),
          ),
        ),

        ],
    );
  }


  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Select Company',
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search...',
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildDateRangeField() {
    return GestureDetector(
      onTap: () {
        // Handle date range selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Text(
              'Select Date Range',
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
            Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  }
}
