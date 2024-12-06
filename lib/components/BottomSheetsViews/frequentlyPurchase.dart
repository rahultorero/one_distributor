import 'package:distributers_app/dataModels/FrequentlyPurchase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class FrequentPurchaseBottomSheet extends StatefulWidget {
  final FrequentlyPurchase frequently;
  final String name;

  const FrequentPurchaseBottomSheet({
    Key? key,
    required this.frequently,
    required this.name,
  }) : super(key: key);


  @override
  _FrequentPurchaseBottomSheetState createState() =>
      _FrequentPurchaseBottomSheetState();
}

class _FrequentPurchaseBottomSheetState extends State<FrequentPurchaseBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  late List<FrequentlyItems> frequentlyList; // Store the invoice list here
  List<FrequentlyItems> filteredList = [];
  late TextEditingController _remarkController;
  late TextEditingController _rateController;


  @override
  void initState() {
    super.initState();
    updateProductsList();
    filteredList = frequentlyList; // Initialize filtered list with all products
    _searchController.addListener(_filterProducts);
  }

  void updateProductsList() {
    setState(() {
      frequentlyList = [];
      for (var item in widget.frequently.data!) {
        if (item != null) {
          frequentlyList.add(item);
          item.rate = item.ptr;
        }
      }
    });
  }



  @override
  void dispose() {
    _rateController.dispose();
    _remarkController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  void _filterProducts() {
    setState(() {
      String query = _searchController.text.toLowerCase();

      filteredList = frequentlyList.where((product) {
        // Check if any of the fields match the search query
        bool matchesName = product.pname != null && product.pname!.toLowerCase().contains(query);
        bool matchesMRP = product.mrp != null && product.mrp.toString().toLowerCase().contains(query);
        bool matchesPTR = product.ptr != null && product.ptr.toString().toLowerCase().contains(query);
        bool matchesScheme = product.scheme != null && product.scheme!.toLowerCase().contains(query);

        // Return true if any field matches the query
        return matchesName || matchesMRP || matchesPTR || matchesScheme;
      }).toList();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          Divider(color: Colors.grey.shade300),
          Expanded(child: _buildList()),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          contentPadding: EdgeInsets.symmetric(vertical: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  // ListView that displays filtered products
  Widget _buildList() {
    return ListView.builder(
      itemCount: filteredList.length, // Use filtered list count
      padding: EdgeInsets.symmetric(horizontal: 5),
      itemBuilder: (context, index) {
        return _buildProductCard(filteredList[index], index);
      },
    );
  }


  Widget _buildProductCard(FrequentlyItems product, int index) {
    _rateController = TextEditingController(text: product.ptr.toString());
    _remarkController = TextEditingController(text: product.remark ?? "");


    return Card(
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
            // Customizing the ExpansionTile icon
            trailing: Icon(
              Icons.arrow_circle_down_sharp, // Customize the icon
              color: Colors.grey, // Change the color if needed
              size: 18, // Adjust the size
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
                          product.pname ?? "",
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEditableRate(
                                'Rate',
                                _rateController,
                                    (newValue) {
                                  // Your logic to handle changes
                                  print('New Rate: $newValue');
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDetailItem(
                                'Stock',
                                (product.stock == null || product.stock!.isEmpty) ? '--' : product.stock!,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDetailItem(
                                'Scheme',
                                (product.scheme == null || product.scheme!.isEmpty) ? '--' : product.scheme!,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center, // Aligns children to the end of the Row
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center, // Align text to the right
                            children: [
                              _buildDetailItems(
                                'T Qty',
                                (product.tqty == null || product.tqty == 0) ? '--' : product.tqty.toString(),
                                textStyle: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center, // Align text to the right
                            children: [
                              _buildDetailItems(
                                'PTime',
                                (product.ptime == null || product.ptime == 0) ? '--' : product.ptime.toString(),
                                textStyle: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 280, // Set your desired width here
                          height: 50, // Set your desired height here
                          child: TextField(
                            controller: _remarkController,
                            decoration: InputDecoration(
                              hintText: 'Add remark...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.blue, // Set your desired border color here
                                  width: 1, // Set the border width if needed
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey, // Color when the TextField is focused
                                  width: 1, // Optional: Different width when focused
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
                        SizedBox(width: 10), // Space between the TextField and any following widget
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

  Widget _buildDetailItems(String label, String value, {TextStyle? textStyle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: textStyle ?? TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal:10, vertical: 4),
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
              fontSize: 14,
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
            overflow: TextOverflow.ellipsis
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControl(FrequentlyItems product) {
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

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ElevatedButton(
        onPressed: () {
          final frequentlySelectedList = frequentlyList.where((item) => item.qty > 0).toList();

          // Debug: Print the filtered list before popping
          print('Filtered frequentlySelectedList: ${frequentlySelectedList}');

          // Use Future.delayed to ensure the pop happens before resetting
          Navigator.pop(context, frequentlySelectedList);

          // Reset all product quantities after the screen is popped
          Future.delayed(Duration(milliseconds: 100), () {
            setState(() {
              for (var item in frequentlyList) {
                item.qty = 0;
              }
            });

            // Debug: Print the list after resetting quantities
            print('After resetting quantities: $frequentlyList');
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade400,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Submit',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }




}

Future<List<FrequentlyItems>?> showPurchaseBottomSheet(
    BuildContext context, FrequentlyPurchase frequently,String name) async {
  // Show the modal bottom sheet and await the result
  final result = await showModalBottomSheet<List<FrequentlyItems>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FrequentPurchaseBottomSheet(frequently: frequently,name:name ,),
  );

  return result; // Return the result to the caller
}
