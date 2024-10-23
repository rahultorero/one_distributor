import 'package:distributers_app/dataModels/ReceivableListRes.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceDetailSheet extends StatefulWidget {
  final ReceivableListRes receivable;

  const InvoiceDetailSheet({
    Key? key,
    required this.receivable,
  }) : super(key: key);

  @override
  _InvoiceDetailSheetState createState() => _InvoiceDetailSheetState();
}

class _InvoiceDetailSheetState extends State<InvoiceDetailSheet> {
  late List<Receivable> receivableList; // Store the invoice list here
  double previousAmount =  0.0 ;
  @override
  void initState() {
    super.initState();
    updateProductsList();



  }


  @override
  void didUpdateWidget(InvoiceDetailSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateProductsList();
  }

  void updateProductsList() {
    setState(() {
      receivableList = [];
      for (var item in widget.receivable.data!) {
        if (item != null) {
          receivableList.add(item);
        }
      }
    });
  }

  Widget _buildPairedInfo(String leftLabel, String leftValue, String rightLabel, String rightValue) {
    return Row(
      children: [
        // Left side with flexible content
        Expanded(
          child: Row(
            children: [
              Text(
                '$leftLabel: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Flexible(
                child: Text(
                  leftValue,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8), // Add some spacing between pairs
        // Right side with flexible content
        Expanded(
          child: Row(
            children: [
              Text(
                '$rightLabel: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Flexible(
                child: Text(
                  rightValue,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(Receivable receivable) {
    previousAmount += double.parse(receivable.balance!) ;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'CN: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '₹${receivable.cnamt}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'RECD: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '₹${receivable.recdamt}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Balance: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '₹${receivable.balance}', // Show the balance value
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'C.Bal: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '₹${previousAmount}', // Show sum of balance and previousBalance
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )

        ],
      ),
    );
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

  Widget _buildInvoiceItem(Receivable receivable) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPairedInfo('Type', receivable.invtype!, 'INV No', receivable.invno!.toString()),
          const SizedBox(height: 6),
          _buildPairedInfo('INV Date',formatDateFromString(receivable.invdate!) , 'Due Date',formatDateFromString(receivable.duedate!)),
          const SizedBox(height: 6),
          _buildPairedInfo('PM', receivable.pm!, 'Salesman', receivable.sman!),
          const Divider(height: 16),
          _buildAmountSection(receivable),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    double totalInvAmount = receivableList.fold(0, (sum, invoice) => sum + double.parse(invoice.invamt.toString()));
    double totalBalance = receivableList.fold(0, (sum, invoice) => sum + double.parse(invoice.balance.toString()));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Text(
                  'Total Inv: ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Flexible(
                  child: Text(
                    '₹${totalInvAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Balance: ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Flexible(
                  child: Text(
                    '₹${totalBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              itemCount: receivableList.length,
              itemBuilder: (context, index) => _buildInvoiceItem(receivableList[index]),
            ),
          ),
          _buildTotalSection(),
        ],
      ),
    );
  }
}
void showInvoiceDetails(BuildContext context, ReceivableListRes invoices) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => InvoiceDetailSheet(receivable: invoices),
  );
}