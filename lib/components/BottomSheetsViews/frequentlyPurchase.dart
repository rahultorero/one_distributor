import 'package:distributers_app/dataModels/FrequentlyPurchase.dart';
import 'package:flutter/material.dart';
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



  @override
  void initState() {
    super.initState();
    updateProductsList();
  }

  void updateProductsList() {
    setState(() {
      frequentlyList = [];
      for (var item in widget.frequently.data!) {
        if (item != null) {
          frequentlyList.add(item);
          item.rate = double.parse(item.ptr!);
        }
      }
    });
  }



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Widget _buildList() {
    return ListView.builder(
      itemCount: frequentlyList.length,
      padding: EdgeInsets.symmetric(horizontal: 5),
      itemBuilder: (context, index) {
        return _buildProductCard(frequentlyList[index], index);
      },
    );
  }
  Widget _buildProductCard(FrequentlyItems product, int index) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.blue.shade50,  // Change this to the desired background color
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
                        product.pname != null ?  product.pname! : '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                product.totalStock != null ? product.totalStock! : '',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildInfoChip('QTY: ${product.qty}', Colors.green),
                SizedBox(width: 12),
                if (product.free! > 0) ...[
                  _buildInfoChip('Free: ${product.free}', Colors.orange),
                  SizedBox(width: 12),
                ],
                _buildInfoChip(
                  currencyFormat.format(product.total != null ? product.total : ''),
                  Colors.purple,
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
                          product.rate,
                              (newValue) {
                            // Add logic for rate change
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
                        child: _buildDetailItem('PTR', product.ptr!),
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
                        width: 180,
                        height: 50,
                        child: TextField(
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
                              product.remark = value;
                            });
                          },
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildQuantityControl(product),
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

  Widget _buildQuantityControl(FrequentlyItems product) {
    return Container(
      width: 30, // Set a fixed width for the entire quantity control (optional)
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ensures the Row doesn't expand unnecessarily
        children: [
          IconButton(
            icon: Icon(Icons.remove, size: 16),
            onPressed: () {
              setState(() {
                if (product.qty! > 0) product.qty--;
              });
            },
            color: Colors.red,
          ),
          // Set specific width for the TextField
          SizedBox(
            width: 30, // Adjust the width of the quantity input field
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              controller: TextEditingController(text: product.qty.toString()),
              onChanged: (value) {
                setState(() {
                  product.qty = int.tryParse(value) ?? 0;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, size: 16),
            onPressed: () {
              setState(() {
                product.qty++;
              });
            },
            color: Colors.green,
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
          print('Filtered frequentlySelectedList: $frequentlySelectedList');

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
