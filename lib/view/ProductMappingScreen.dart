import 'dart:convert';

import 'package:distributers_app/components/LoadingIndicator.dart';
import 'package:distributers_app/dataModels/MatchProductRes.dart';
import 'package:distributers_app/dataModels/UnmatchedProductRes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dataModels/StoreModel.dart';
import '../services/api_services.dart';
import 'package:http/http.dart' as http;

class ProductCardState {
  String selectedValue;
  String selectedCode;
  String selectedGeneric;
  String selectedMfg;

  ProductCardState({
    this.selectedValue = 'Select...',
    this.selectedCode = '',
    this.selectedGeneric = '',
    this.selectedMfg = '',
  });
}

class ProductMappingScreen extends StatefulWidget {
  const ProductMappingScreen({Key? key}) : super(key: key);

  @override
  _ProductMappingScreenState createState() => _ProductMappingScreenState();
}

class _ProductMappingScreenState extends State<ProductMappingScreen> {
  List<MatchProductModel> products = []; // This will hold the fetched invoices
  List<MatchProductModel> filteredProducts= []; // This will hold the fetched invoices
  int totalRequest = 0;
  List<UnMatchProductModel> unMatchedProducts = []; // This will hold the fetched invoices
  final Map<int, ProductCardState> cardStates = {};

  // Example state variables
  bool _isDropdownVisible = false;
  bool _isSearchVisible = false;
  bool _isDateRangeVisible = false;
  List<Store> stores = [];
  String? regCode;
  TextEditingController searchController = TextEditingController();
  String? selectedCompanyName;
  String? selectRegCode;
  int? selectedCompanyId;
  bool isLoading = true; // To manage loading state

  MatchProduct? _selectedProduct;

  int? companyId;
  String dmfg = "";
  String generic = "";
  int itemDetailId = 0;
  String packing = "";
  int pcode = 0;
  String pmfg = "";
  String pname = "";
  String regcode = "";

  // Define variables with prefix 'other' for each field in the "o_product" section
  int? otherDmfgId;
  int? otherPmfgId;
  String otherPname = "";
  int otherPid = 0;
  String? otherACode ;
  String otherDmfgName = "";
  String otherPmfgName = "";
  String? otherPacking = "";
  String? otherGrpidGenName = "";
  late MatchProductModel productModelS;
  String selectSuggest = "Select...";
  int _counter = 1;
  final TextEditingController _pageController = TextEditingController();


  @override
  void initState() {
    super.initState();

    _pageController.text = _counter.toString(); // Set initial text to counter value

    _fetchDivisionAndCompanies(); // Fetch data on init


    searchController.addListener(() {

    });
    // Initialize any variables or state here
    // For example, set the default state for filter visibility
    _isDropdownVisible = false;
    _isSearchVisible = false;
    _isDateRangeVisible = false;
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
        await _fetchMapProduct("1");
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


  Future<void> _fetchMapProduct(String page) async {
    String apiUrl = ApiConfig.reqMapProduct(); // Replace with actual API URL


    final body = jsonEncode({
      "reg_code": selectRegCode,
      "companyid": selectedCompanyId,
      "pagenum":page,
      "pagesize":50
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
        int request = jsonData['totalProduct'];
        if (invoiceList != null && invoiceList.isNotEmpty) {
          setState(() {
            products = invoiceList.map((json) => MatchProductModel.fromJson(json)).toList();
            filteredProducts = products;
            totalRequest = request;

            productModelS = products[0];
          });
        } else {

          print('No invoices found in the response');
          // Handle no data case, like showing a message in UI
        }
      } else {

        throw Exception('Failed to load invoices: ${response.body}');
      }
    } catch (e) {
      setState(() {
        filteredProducts = [];
      });

      print('Error fetching productss: $e');
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

  Future<void> _fetchUnMapProduct() async {
    String apiUrl = ApiConfig.reqUnMapProduct(); // Replace with actual API URL


    final body = jsonEncode({
      "reg_code": selectRegCode,
      "companyid": selectedCompanyId,
      "userInput": searchController.text
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
            unMatchedProducts = invoiceList.map((json) => UnMatchProductModel.fromJson(json)).toList();
          });
        } else {

          print('No invoices found in the response');
          // Handle no data case, like showing a message in UI
        }
      } else {

        throw Exception('Failed to load invoices: ${response.body}');
      }
    } catch (e) {


      print('Error fetching productss: $e');
      // Show an error message in the UI using a SnackBar

    }
  }

  Future<void> _mappedProduct() async {
    final prefs = await SharedPreferences.getInstance();
    String apiUrl = ApiConfig.postMapProduct(); // Replace with actual API URL

    final Map<String, dynamic> requestBody = {
      "m_product": {
        "pname": pname,
        "regcode": regcode,
        "packing": packing,
        "itemdetailid": itemDetailId,
        "companyid": companyId,
        "dmfg": dmfg,
        "pmfg": pmfg,
        "generic": generic,
        "pcode": pcode,
      },
      "o_product": {
        "dmfgid": otherDmfgId,
        "pmfgid": otherPmfgId,
        "pname": otherPname,
        "pid": otherPid,
        "a_code": otherACode,
        "dmfg_name": otherDmfgName,
        "pmfg_name": otherPmfgName,
        "packing": otherPacking,
        "grpid_gen_name": otherGrpidGenName,
      },
      "id": 0,
      "cusrid": prefs.getInt("u_id"),
      "eusrid": 0,
    };

    print("Request body: $requestBody");

    setState(() {
      isLoading = true; // Set loading to true when the request starts
    });

    try {
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
            content: Text('Product Mapped..'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        print("check the pagess ${_counter}");
        _fetchMapProduct(_counter.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed TO Create Profile'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );


        throw Exception('Failed to load invoices: ${response.body}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong'),
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
      _fetchMapProduct(_counter.toString()); // Call your function

  }


  void _increaseCounter() {
    setState(() {
      _counter++; // Increase the counter
      _pageController.text = _counter.toString(); // Update the TextField
    });
    _fetchMapProduct(_counter.toString());
  }

  void _decreaseCounter() {
    setState(() {
      if (_counter > 1) {
        _counter--; // Decrease the counter, but not less than 1
        _pageController.text = _counter.toString(); // Update the TextField
      }
    });
    _fetchMapProduct(_counter.toString());
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
          'MAPPING PRODUCTS',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [

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
                : filteredProducts.isEmpty
                ? Center(child: Text("No products available"))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
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

  Widget _buildProductCard(MatchProductModel product) {
    // Ensure the card state is initialized for this product
    cardStates[product.itemdetailid!] ??= ProductCardState();

    // If no product is selected, assign the first item by default
    // Check if matchProduct has any items before trying to access the first element
    if (productModelS.matchProduct != null && productModelS.matchProduct!.isNotEmpty) {
      final firstProduct = productModelS.matchProduct!.first;

      print("first producttttt${firstProduct.toJson()}");
      // Initialize the preview with the first product's details
      cardStates[product.itemdetailid!] = ProductCardState(
        selectedValue: firstProduct.pname ?? "",
        selectedCode: firstProduct.pid.toString() ?? "",
        selectedGeneric: firstProduct.grpidGenName ?? "",
        selectedMfg: firstProduct.pmfgName ?? "",
      );

      // Optionally, assign other fields as needed
      otherDmfgId = firstProduct.dmfgid;
      otherPmfgId = firstProduct.pmfgid;
      otherPname = firstProduct.pname!;
      otherPid = firstProduct.pid!;
      otherACode = firstProduct.aCode;
      otherDmfgName = firstProduct.dmfgName!;
      otherPmfgName = firstProduct.pmfgName!;
      otherPacking = firstProduct.packing ?? '';
      otherGrpidGenName = firstProduct.grpidGenName;
    } else {
      print("first producttttt empty");
      // Handle the case where matchProduct is empty
      cardStates[product.itemdetailid!] = ProductCardState(
        selectedValue: "Select...",
        selectedCode: "",
        selectedGeneric: "",
        selectedMfg: "",
      );

      // Clear or set default values for other fields as needed
      otherDmfgId = null;
      otherPmfgId = null;
      otherPname = "";
      otherPid = 0;
      otherACode = "";
      otherDmfgName = "";
      otherPmfgName = "";
      otherPacking = "";
      otherGrpidGenName = "";
    }

    // Check if the product card's state has a selected value (i.e., is non-empty)
    print("check the valueis${cardStates[product.itemdetailid!]!.selectedValue}");
    final bool hasSelectedValue = cardStates[product.itemdetailid!]!.selectedValue.isNotEmpty &&
        cardStates[product.itemdetailid!]!.selectedValue != "Select...";

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: BoxDecoration(
        color: hasSelectedValue ? Colors.lightGreen[100] : Colors.white, // Change color if selectedValue is non-empty
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
              "${product.pname} ${product.packing}" ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('MFG:', '${product.pmfg ?? ''}'),
            const SizedBox(height: 4),
            _buildInfoRow('Code:', '${product.pcode ?? ''}'),
            const SizedBox(height: 4),
            _buildInfoRow('Generic:', '${product.generic ?? ''} '),
            const SizedBox(height: 12),
          _buildMappingDropdown(
            "Suggested Products",
            product.matchProduct!,
                (selectedProduct) {
              setState(() {
                // If no product is selected, assign the first item by default
                _selectedProduct ??= product.matchProduct!.isNotEmpty ? product.matchProduct!.first : null;

                // Set the selected product based on the dropdown selection
                _selectedProduct = selectedProduct;

                // Update card state for this specific product
                cardStates[product.itemdetailid!] = ProductCardState(
                  selectedValue: selectedProduct.pname ?? "",
                  selectedCode: selectedProduct.pid.toString() ?? "",
                  selectedGeneric: selectedProduct.grpidGenName ?? "",
                  selectedMfg: selectedProduct.pmfgName ?? "",
                );

                // Assign additional fields as needed
                otherDmfgId = selectedProduct.dmfgid;
                otherPmfgId = selectedProduct.pmfgid;
                otherPname = selectedProduct.pname!;
                otherPid = selectedProduct.pid!;
                otherACode = selectedProduct.aCode;
                otherDmfgName = selectedProduct.dmfgName!;
                otherPmfgName = selectedProduct.pmfgName!;
                otherPacking = selectedProduct.packing ?? '';
                otherGrpidGenName = selectedProduct.grpidGenName;
              });
            },
          ),

          const SizedBox(height: 12),
            _buildUnmatchedDropdown(
              'Search from all Products',
              cardStates[product.itemdetailid]!.selectedValue,
              product.itemdetailid!,
            ),
            const SizedBox(height: 12),
            Row(
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
                        _buildInfoRow('MFG:', cardStates[product.itemdetailid]!.selectedMfg),
                        const SizedBox(height: 4),
                        _buildInfoRow('Code:', cardStates[product.itemdetailid]!.selectedCode),
                        const SizedBox(height: 4),
                        _buildInfoRow('Generic:', cardStates[product.itemdetailid]!.selectedGeneric),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  Widget _buildMappingDropdown(
      String label,
      List<MatchProduct> items,
      ValueChanged<MatchProduct> onChanged,
      ) {
    // Set the initial value to the first item in the list if it's not empty
    MatchProduct? initialValue = items.isNotEmpty ? items.first : null;

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
          height: 40, // Set height of the dropdown container
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MatchProduct>(
              isExpanded: true,
              value: initialValue,
              hint: Text(
                "Select...", // Display "Select..." when no item is selected
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey[600],
              ),
              items: items.map((MatchProduct item) {
                return DropdownMenuItem<MatchProduct>(
                  value: item,
                  child: Text(
                    item.pname ?? "",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (MatchProduct? newValue) {
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



  Widget _buildUnmatchedDropdown(String label, String value, int productId) {
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
          onTap: () => _openBottomSheet(productId),
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
                    value,
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

  void _openBottomSheet(int productId) {
    _showBottomSheet((selectedValue, selectedCode, selectedGeneric, selectedMfg) {
      setState(() {
        cardStates[productId] = ProductCardState(
          selectedValue: selectedValue,
          selectedCode: selectedCode,
          selectedGeneric: selectedGeneric,
          selectedMfg: selectedMfg,
        );
      });
    });
  }

  void _showBottomSheet(void Function(String, String, String, String) onItemSelected) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Select an Option',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      if (value.length >= 3) {
                        _fetchUnMapProduct();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          // Optionally, you can call _fetchUnMapProduct() here if needed.
                        },
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: unMatchedProducts.length,
                    itemBuilder: (context, index) {
                      final product = unMatchedProducts[index];
                      return ListTile(
                        title: Text("${product.pname!}${product.packing ?? ''}"),
                        subtitle: Text(
                          "${product.dmfgName ?? ''}",
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          // Pass selected values to parent callback and close the sheet
                          onItemSelected(
                            product.pname ?? "",
                            product.pid.toString() ?? "",
                            product.grpidGenName ?? "",
                            product.pmfgName ?? "",
                          );

                          otherDmfgId = product.dmfgid;
                          otherPmfgId = product.pmfgid;
                          otherPname = product.pname!;
                          otherPid = product.pid!;
                          otherACode = product.aCode;
                          otherDmfgName = product.dmfgName!;
                          otherPmfgName = product.pmfgName!;
                          otherPacking = product.packing ?? '';
                          otherGrpidGenName = product.grpidGenName;
                          searchController.clear();
                          Navigator.pop(context);
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
    ).whenComplete(() {
      // Clear the search field when the bottom sheet is dismissed
      searchController.clear();
    });
  }


  Widget _buildActionButton({required IconData icon, required Color color,required MatchProductModel product}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(icon, size: 24, color: color),
        onPressed: () {
          companyId = product.companyid;
          dmfg = product.dmfg!;
          generic = product.generic ?? "";
          itemDetailId = product.itemdetailid!;
          packing = product.packing ?? "";
          pcode = product.pcode!;
          pmfg = product.pmfg ?? "";
          pname = product.pname ?? "";
          regcode = product.regcode!;

          _mappedProduct();
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
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Orders',
                border: OutlineInputBorder(),
              ),
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
