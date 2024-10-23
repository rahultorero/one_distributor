import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormData {
  // Business Details
  String businessName = '';
  String address1 = '';
  String address2 = '';
  String? selectedArea;
  String? selectedCity;
  String? selectedState;
  String? selectedCode;
  String pincode = '';
  String contactNo = '';
  String email = '';
  String personName = '';
  String gstNo = '';
  String panNo = '';
  String drugLicenceNo = '';
  String fssaiNo = '';
  String udyamNo = '';

  // Category
  String? selectedIndustry;
  String? selectedCategory;

  // Document Upload
  Map<String, String?> uploadedDocuments = {
    'druglic': null,
    'fssai': null,
    'gstcer': null,
    'udyam': null,
  };
}

class FormDataProvider extends ChangeNotifier {
  final FormData _formData = FormData();

  FormData get formData => _formData;

  void updateBusinessDetails({
    String? businessName,
    String? address1,
    String? address2,
    String? selectedArea,
    String? selectedCity,
    String? selectedState,
    String? selectedCode,
    String? pincode,
    String? contactNo,
    String? email,
    String? personName,
    String? gstNo,
    String? panNo,
    String? drugLicenceNo,
    String? fssaiNo,
    String? udyamNo,
  }) {
    if (businessName != null) _formData.businessName = businessName;
    if (address1 != null) _formData.address1 = address1;
    if (address2 != null) _formData.address2 = address2;
    if (selectedArea != null) _formData.selectedArea = selectedArea;
    if (selectedCity != null) _formData.selectedCity = selectedCity;
    if (selectedState != null) _formData.selectedState = selectedState;
    if (selectedCode != null) _formData.selectedCode = selectedCode;
    if (pincode != null) _formData.pincode = pincode;
    if (contactNo != null) _formData.contactNo = contactNo;
    if (email != null) _formData.email = email;
    if (personName != null) _formData.personName = personName;
    if (gstNo != null) _formData.gstNo = gstNo;
    if (panNo != null) _formData.panNo = panNo;
    if (drugLicenceNo != null) _formData.drugLicenceNo = drugLicenceNo;
    if (fssaiNo != null) _formData.fssaiNo = fssaiNo;
    if (udyamNo != null) _formData.udyamNo = udyamNo;
    notifyListeners();
  }

  void updateCategory(String? industry, String? category) {
    _formData.selectedIndustry = industry;
    _formData.selectedCategory = category;
    notifyListeners();
  }

  void updateUploadedDocument(String documentType, String? filePath) {
    _formData.uploadedDocuments[documentType] = filePath;
    notifyListeners();
  }
}