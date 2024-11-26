import 'dart:convert';

import 'package:distributers_app/dataModels/MappedProductRes.dart';
import 'package:distributers_app/dataModels/MatchProductRes.dart';
import 'package:distributers_app/dataModels/UnMappedProductRes.dart';
import 'package:distributers_app/dataModels/UnmappedRetailerList.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/LoadingIndicator.dart';
import '../dataModels/MappedRetailerList.dart';
import '../dataModels/StoreModel.dart';
import '../services/api_services.dart';
import 'package:http/http.dart' as http;

class MappedRetailerScreen extends StatefulWidget {
  @override
  _MappedRetailerScreenState createState() => _MappedRetailerScreenState();
}

class _MappedRetailerScreenState extends State<MappedRetailerScreen> {
  TextEditingController searchController = TextEditingController();
  String? selectedCompanyName;
  int? selectedCompanyId;
  String? regCode;
  List<Store> stores = [];
  bool _isDropdownVisible = false;
  bool _isSearchVisible = false;
  bool _isDateRangeVisible = false;
  bool isLoading = true; // To manage loading state
  late MappedRetailerList product = MappedRetailerList(data: []) ; // This will hold the fetched invoices
  late MappedRetailerList filterProduct = MappedRetailerList(data: []);


  String searchQuery = '';

  @override
  void initState() {
    filterProduct = product;
    _fetchDivisionAndCompanies(); // Fetch data on init
    super.initState();
  }

  Future<void> _fetchDivisionAndCompanies() async {
    try {
      // Fetch division
      regCode = await _getDivision();
      if (regCode != null) {
        // Fetch companies using the division value
        stores = await fetchCompanies(regCode!);
        selectedCompanyId = stores[0].companyId;
        await _fetchMappedRetailer();
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

  Future<void> _fetchMappedRetailer() async {
    String apiUrl = ApiConfig.reqget_mapping_retailer(); // Replace with actual API URL
    DateTime today = DateTime.now();

    // Format dates as 'YYYY-MM-DD'
    String formatDate(DateTime date) {
      return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    final body = jsonEncode({
      "reg_code": regCode?.substring(0, 7),
      "companyid": selectedCompanyId,
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
            product.data = invoiceList.map((json) => RetailerMapped.fromJson(json)).toList();
            filterProduct = product;
          });
        } else {
          product.data = [];
          print('No invoices found in the response');
          // Handle no data case, like showing a message in UI
        }
      } else {
        product.data = [];
        throw Exception('Failed to load invoices: ${response.body}');
      }
    } catch (e) {
      setState(() {
        product.data = [];
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
      backgroundColor: Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body:
      filterProduct.data!.isEmpty
          ? Center(child: LoadingIndicator()):
      Column(
        children: [
          _buildActionButtons(),
          Visibility(
            visible: _isDropdownVisible || _isSearchVisible || _isDateRangeVisible,
            child: _buildFilterFields(),
          ),
          SizedBox(
            height: _isDropdownVisible || _isSearchVisible || _isDateRangeVisible ? 8 : 4,
          ),
          Expanded(
            child:
            _buildProductList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'MAPPED REATILERS',
        style: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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
              onChanged: (value) {
                _fetchMappedRetailer();
              },
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildProductList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filterProduct.data?.length,
      itemBuilder: (context, index) {
        final mapping = filterProduct.data
        ![index];
        return _buildProductCard(mapping);
      },
    );
  }

  Widget _buildProductCard(RetailerMapped mapping) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF64748B).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProductSection(mapping, "Retailer Details"),
          Divider(height: 1, color: Color(0xFFE2E8F0)),
          _buildMappedProductSection(mapping, "Mapped Retailer Details"),
          _buildCardActions(mapping),
        ],
      ),
    );
  }

  Widget _buildProductSection(RetailerMapped product, String label) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.rId.toString() ?? "",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "${product.partyname}" ?? "",
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.business, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 4),
              Container(
                width: 130,
                child: Text(
                  product.partyAdd1 ?? "",
                  style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis
                  ),
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.science, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 4),
              Container(
                width:115,
                child: Text(
                  product.partyEmail ?? "",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    overflow: TextOverflow.ellipsis
                  ),
                ),
              )

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMappedProductSection(RetailerMapped product, String label) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.rId.toString() ?? "",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "${product.retaName} " ?? "",
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.business, size: 14, color: Color(0xFF64748B)),
              SizedBox(width: 4),
              Container(
                width: 130,
                child: Text(
                  product.retaAdd1 ?? "",
                  style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis
                  ),
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.science, size: 14, color: Color(0xFF64748B)),
              SizedBox(width: 4),
              Container(
                width: 110,
                child: Text(
                  product.retaEmail ?? "",
                  style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis
                  ),
                ),

              )

            ],
          ),
        ],
      ),
    );
  }


  Widget _buildCardActions(RetailerMapped mapping) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            icon: Icon(Icons.edit, size: 18),
            label: Text('Edit'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF3B82F6), textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () => _showMappingDialog(mapping),
          ),
          SizedBox(width: 16),
          TextButton.icon(
            icon: Icon(Icons.delete, size: 18),
            label: Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFFEF4444), textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () => _confirmDelete(product.data!.indexOf(mapping),mapping),
          ),
        ],
      ),
    );
  }

  Future<void> _showMappingDialog(RetailerMapped mapping) async {
    String searchQuery = '';
    TextEditingController searchController = TextEditingController();
    RetailerUnmapped? selectedProduct;
    List<RetailerUnmapped> searchResults = [];
    bool isLoading = false;

    // Helper function to safely convert dynamic list to UnmappedProduct list
    List<RetailerUnmapped> parseProducts(List<dynamic> data) {
      return data.map((json) {
        try {
          return RetailerUnmapped.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing product: $e');
          return null;
        }
      }).whereType<RetailerUnmapped>().toList();
    }

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 480,
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
                        'Search Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey.shade600),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 24,
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selected Product Details
                        if (selectedProduct != null)
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Manufacturer
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        'Name',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        selectedProduct?.regName ?? '-',
                                        style: TextStyle(
                                          color: Colors.grey.shade900,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Product Code
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        'Code',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        selectedProduct?.rCode.toString() ?? '-',
                                        style: TextStyle(
                                          color: Colors.grey.shade900,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Generic Name
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        selectedProduct?.email ?? '-',
                                        style: TextStyle(
                                          color: Colors.grey.shade900,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 20),

                        // Search Field
                        TextFormField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey.shade400),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  searchResults = [];
                                  searchQuery = '';
                                  isLoading = false;
                                });
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
                          onChanged: (value) async {
                            searchQuery = value;
                            if (value.length >= 2) {
                              setState(() => isLoading = true);

                              try {
                                final response = await http.post(
                                  Uri.parse(ApiConfig.reqUnmatchedParty()),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    "reg_code": regCode?.substring(0, 7),
                                    "companyid": selectedCompanyId,
                                    "userInput": searchQuery,
                                    "pagenum":1
                                  }),
                                );



                                if (response.statusCode == 200) {
                                  final responseData = json.decode(response.body);
                                  final List<dynamic> productList = responseData['data'] ?? [];
                                  print("check the responseeee ${responseData}");
                                  setState(() {
                                    searchResults = parseProducts(productList);
                                    isLoading = false;
                                  });
                                } else {
                                  print('API Error: ${response.statusCode}');
                                  setState(() {
                                    searchResults = [];
                                    isLoading = false;
                                  });
                                }
                              } catch (e) {
                                print('Error searching products: $e');
                                setState(() {
                                  searchResults = [];
                                  isLoading = false;
                                });
                              }
                            } else {
                              setState(() => searchResults = []);
                            }
                          },
                        ),


                        // Search Results
                        if (searchQuery.length >= 2)
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            constraints: BoxConstraints(maxHeight: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: isLoading
                                  ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                                  ),
                                ),
                              )
                                  : searchResults.isEmpty
                                  ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'No products found',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                                  : ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: searchResults.length,
                                separatorBuilder: (context, index) => Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final product = searchResults[index];
                                  return ListTile(
                                    title: Text(
                                      "${product.regName}" ?? "",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      product.add1 ?? "",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedProduct = product;
                                        searchController.text = product.regName ?? "";
                                        searchResults = [];
                                      });
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

                // Footer
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: selectedProduct != null
                            ? () => EditMappedProduct(selectedProduct!,mapping)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade500,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

  Future<int?> _getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("u_id"); // Replace with your key
  }

  Future<void> EditMappedProduct(RetailerUnmapped unmapped, RetailerMapped mapped) async {
    int? cusrid = await _getUserId();

    final url = Uri.parse(ApiConfig.reqMappingParty()); // Replace with the actual endpoint
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "id": mapped.id, // Assuming this value comes from the mapped object
      "party": {
        "Regcode": mapped.regDcode ?? "", // Use the appropriate property from unmapped
        "LedId_Party": mapped.rLedid, // Assuming these fields exist in RetailerUnmapped
        "CompanyId": mapped.companyId ?? 0,
        "ALCode":  ""
      },
      "retailer": {
        "r_id": unmapped.rId, // Assuming mapped object contains these fields
        "reg_name": unmapped.regName ?? "",
        "r_code": unmapped.rCode ?? "",
        "rg_id": 0
      },
      "cusrid": cusrid,
      "eusrid": 1 // Assuming 1 is a placeholder, replace if needed
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print("check whats the body$body");

      if (response.statusCode == 200) {
        // Successful request
        print('Update Successful: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mapped Successfully'),
            backgroundColor: Colors.green, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
        Navigator.pop(context);
        _fetchMappedRetailer();
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // Handle connection error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red, // Optional: Customize the color
          duration: Duration(seconds: 2), // Duration for the SnackBar
        ),
      );
      print('Exception: $e');
    }
  }

  Future<void> deleteMappedRetailer(RetailerMapped mapped) async {
    int? cusrid = await _getUserId();

    final url = Uri.parse(ApiConfig.reqDeleteRetailer()); // Replace with the actual endpoint
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "id": mapped.id, // Assuming this value comes from the mapped object
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print("check whats the body$body");

      if (response.statusCode == 200) {
        // Successful request
        print('Update Successful: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete Successfully'),
            backgroundColor: Colors.green, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
        Navigator.pop(context);
        _fetchMappedRetailer();
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // Handle connection error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red, // Optional: Customize the color
          duration: Duration(seconds: 2), // Duration for the SnackBar
        ),
      );
      print('Exception: $e');
    }
  }


  Future<void> deleteMappedProduct(MappedProduct mapped) async {

    final url = Uri.parse(ApiConfig.reqDeleteMapProduct()); // Replace with the actual endpoint
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "id": mapped.id,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print(body);

      if (response.statusCode == 200) {
        // Successful request
        print('Update Successful: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted Successfully'),
            backgroundColor: Colors.green, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
        Navigator.pop(context);
        _fetchMappedRetailer();
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // Handle connection error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red, // Optional: Customize the color
          duration: Duration(seconds: 2), // Duration for the SnackBar
        ),
      );
      print('Exception: $e');
    }
  }



  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Select product...',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(int index,RetailerMapped mapped) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Mapping',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this product mapping? This action cannot be undone.',
          style: TextStyle(
            color: Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF64748B),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.delete, size: 18),
            label: Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEF4444),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              deleteMappedRetailer(mapped);
              setState(() {
                product.data!.removeAt(index);
              });

            },
          ),
        ],
      ),
    );
  }
}

class Product {
  final String name;
  final String manufacturer;
  final String code;
  final String generic;
  final String imageUrl;

  Product({
    required this.name,
    required this.manufacturer,
    required this.code,
    required this.generic,
    required this.imageUrl,
  });
}

class ProductMapping {
  final Product sourceProduct;
  final Product mappedProduct;

  ProductMapping({
    required this.sourceProduct,
    required this.mappedProduct,
  });
}