import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class CustomBottomSheet {
  static void show(
      BuildContext context,
      String title,
      List<String> items,
      ValueChanged<String> onItemSelected,
      ValueChanged<String> onCodeSelected // This should be a ValueChanged<String> callback
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _BottomSheetContent(
            title: title,
            items: items,
            onItemSelected: onItemSelected,
            onCodeSelected: onCodeSelected, // Pass this parameter
          ),
        );
      },
    );
  }
}



class _BottomSheetContent extends StatefulWidget {
  final String title;
  final List<String> items;
  final ValueChanged<String> onItemSelected;
  final ValueChanged<String> onCodeSelected; // Add this parameter

  const _BottomSheetContent({
    required this.title,
    required this.items,
    required this.onItemSelected,
    required this.onCodeSelected, // Add this parameter
  });

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  late List<String> filteredItems;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = widget.items;
      } else {
        filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: searchController,
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: filteredItems.isEmpty
                  ? Center(child: Text('No items found'))
                  : ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      widget.onItemSelected(item);
                      widget.onCodeSelected(item); // Call this method
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



