import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_svg/flutter_svg.dart' as svg;

import '../view/outStandingList.dart';

class PdfGenerator {


  static Future<Uint8List> generatePdf(List<InvoiceData> invoiceData) async {
    final logoBytes = await rootBundle.load('assets/images/logo.png');
    final logoData = logoBytes.buffer.asUint8List();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(await _loadFont('Roboto-Regular')),
        bold: pw.Font.ttf(await _loadFont('Roboto-Bold')),
        italic: pw.Font.ttf(await _loadFont('Roboto-Italic')),
        boldItalic: pw.Font.ttf(await _loadFont('Roboto-BoldItalic')),
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(30),
        build: (pw.Context context) => [
          _buildHeader(logoData),  // Logo data is already loaded
          pw.SizedBox(height: 15),
          _buildDateAndInvoiceNumber(invoiceData.first),
          pw.SizedBox(height: 15),
          _buildPartyDetailsSection(invoiceData.first),
          pw.SizedBox(height: 15),
          _buildInvoiceTable(invoiceData),

        ],
          footer: (context) {
            // Only show total section on the last page
            if (context.pageNumber == context.pagesCount) {
              return pw.Column(
                children: [
                  _buildTotalSection(invoiceData),
                  pw.SizedBox(height: 10),
                  _buildFooter(context),
                ],
              );
            }
            return _buildFooter(context);
          }
      ),
    );

    return await pdf.save();
  }



  static pw.Widget _buildHeader(Uint8List logoData) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Outstanding Details',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Statement of Outstanding Amounts',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          // Add some space between the logo and the divider
          pw.SizedBox(width: 10),  // You can adjust the width as needed
          pw.Container(
            height: 40,
            width: 40,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.ClipRRect(
              verticalRadius: 8,
              horizontalRadius: 8,
              child: pw.Image(
                pw.MemoryImage(logoData),
                fit: pw.BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDateAndInvoiceNumber(InvoiceData invoiceData) {
    print(invoiceData.invoices.first.invDate);
    print(invoiceData.invoices.first.invDate);
    print(invoiceData.invoices.first.invDate);

    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Statement Start Date: ${invoiceData.invoices.first.invDate}',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'Statement End Date: ${invoiceData.invoices.last.invDate}',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPartyDetailsSection(InvoiceData invoiceData) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _buildDistributorDetails(invoiceData),
        ),
        pw.SizedBox(width: 15),
        pw.Expanded(
          child: _buildRetailerDetails(invoiceData),
        ),
      ],
    );
  }

  static pw.Widget _buildDistributorDetails(InvoiceData invoiceData) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Distributor Details',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          _buildDetailRow('Company:', invoiceData.disName),
          _buildDetailRow('PartyCode:', invoiceData.disPartyCode),
          _buildDetailRow('Address:', invoiceData.disArea ?? ""),
          _buildDetailRow('City:', invoiceData.disCity ?? ""),
          _buildDetailRow('Phone:', invoiceData.disMobile ?? ""),
          _buildDetailRow('Email:', invoiceData.disEmail ?? ''),
        ],
      ),
    );
  }

  static pw.Widget _buildRetailerDetails(InvoiceData invoiceData) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Retailer Details',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          _buildDetailRow('Name:', invoiceData.retName),
          _buildDetailRow('PartyCode:', invoiceData.retPartyCode),
          _buildDetailRow('Area:', invoiceData.retArea ?? ''),
          _buildDetailRow('City:', invoiceData.retCity ?? ''),
          _buildDetailRow('Mobile:', invoiceData.retMobile ?? ''),
          _buildDetailRow('Email:', invoiceData.retEmail ?? ''),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }



  static pw.Widget _buildInvoiceTable(List<InvoiceData> invoiceData) {
    double cumulativeBalance = 0.0;

    return pw.Table.fromTextArray(
      headers: [
        'Invoice\nNo.',
        'Invoice\nDate',
        'Due\nDate',
        'PM',
        'Invoice\nAmount',
        'Adjust\nAmount',
        'Outstanding\nAmount',
        'Cumulative\nBalance',
        'Salesperson',
      ],
      data: invoiceData.expand((data) => data.invoices.map((invoice) {
        // Calculate the cumulative balance by adding the current outstanding amount
        cumulativeBalance += invoice.balance;

        return [
          '${invoice.prefix}/${invoice.invNo}',
          invoice.invDate,
          invoice.dueDate,
          invoice.pm,
          '${_formatAmount(invoice.invAmt)}',
          '${_formatAmount(invoice.cnAmt + invoice.recvAmt)}',
          '${_formatAmount(invoice.balance)}',
          '${_formatAmount(cumulativeBalance)}', // Display cumulative balance
          pw.Container(
            width: 70, // Set fixed width for Salesperson column
            child: pw.Text(
              invoice.salesman,
              maxLines: 1,
              overflow: pw.TextOverflow.clip, // Add ellipsis for long text
            ),
          ),
        ];
      })).toList(),
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.blue800,
      ),
      cellStyle: pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.center,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerRight,
        8: pw.Alignment.centerLeft,
      },
      cellPadding: pw.EdgeInsets.all(4),
    );
  }

  static pw.Widget _buildTotalSection(List<InvoiceData> invoiceData) {
    final totalInvoiceAmount = invoiceData.fold(
      0.0,
          (sum, data) => sum + data.invoices.fold(
        0.0,
            (sum, invoice) => sum + invoice.invAmt,
      ),
    );

    final totalAdjustedAmount = invoiceData.fold(
      0.0,
          (sum, data) => sum + data.invoices.fold(
        0.0,
            (sum, invoice) => sum + invoice.cnAmt + invoice.recvAmt,
      ),
    );

    final totalBalance = invoiceData.fold(
      0.0,
          (sum, data) => sum + data.totalBalance,
    );

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
          width: 0.5,
        ),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: [
          _buildTotalBox(
            'INV AMT',
            totalInvoiceAmount,
            PdfColors.blue50,
            isFirst: true,
          ),
          _buildTotalBox(
            'ADJ AMT',
            totalAdjustedAmount,
            PdfColors.grey50,
          ),
          _buildTotalBox(
            'OS AMT',
            totalBalance,
            PdfColors.blue50,
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border(
                  left: pw.BorderSide(
                    color: PdfColors.grey400,
                    width: 0.5,
                  ),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'for :- Sangali Medical',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Authorize/Competent Signature',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    width: 140,
                    height: 0.3,
                    color: PdfColors.grey600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalBox(
      String label,
      double amount,
      PdfColor backgroundColor, {
        bool isFirst = false,
      }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: pw.BoxDecoration(
          color: backgroundColor,
          border: !isFirst
              ? pw.Border(
            left: pw.BorderSide(
              color: PdfColors.grey400,
              width: 0.5,
            ),
          )
              : null,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey800,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '₹ ${_formatAmount(amount)}',
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey900,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  static pw.Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.blue800 : PdfColors.grey700,
            ),
          ),
          pw.Text(
            '₹${_formatAmount(amount)}',
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.blue800 : PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      padding: pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated on ${_formatDate(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  static String formatDateFromString(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';

    try {
      // Use DateTime.parse for ISO 8601 strings
      DateTime date = DateTime.parse(dateString);

      // Format to 'dd-MM-yyyy'
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  static String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  static Future<ByteData> _loadFont(String fontName) async {
    final fontData = await rootBundle.load('assets/fonts/$fontName.ttf');
    return fontData.buffer.asByteData();
  }
}