import 'package:flutter/services.dart';

class ApiConfig {
  static const String baseUrl = 'http://182.70.116.222:8000'; // Replace with your base URL
  static const String header = "Content-Type': 'application/json";
  static const String authCode = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJNMDAwMDJEMDFNMDEiLCJwd2QiOiJvbmVAMTIzIiwiaWF0IjoxNzE5MjE2MTc5LCJleHAiOjE3MTkzMDI1Nzl9.WYXJHspTDphkjCuZuReZGJ0sBsn1_ExPhNSn9mzJOIU';
  static const String getLocationEndpoint = '/getLocation'; // Endpoint for fetching location data
  static const String getPharmaCategory = "/getpharma";
  static const String registerUser = "/register";
  static const String loginUser = "/login";
  static const String forgotPassword = "/forget_password";
  static const String verifyOtp = "/verify_otp";
  static const String resetPass = "/verify_password";
  static const String getCompany = "/get_set_up_by_id";
  static const String uploadImages = "/uploadimages";
  static const String updateCompany = "/update_setup_user";
  static const String getProfile = "/get_profile";
  static const String updateProfile = "/update_all_type_user";
  static const String changePassword = "/verify_password";
  static const String dropDownInvoice = "/dist_dropdown";
  static const String getInvoiceList = "/get_inv_header";
  static const String getSalesMan = "/get_sales_man";
  static const String getAdminList = "/get_admin_user_profile";
  static const String addUser = "/o_user_d";
  static const String getOrder = "/get_order";
  static const String getDraftOrder = "/get_draft_list";
  static const String getOrderDetails = "/get_product_by_ohid";
  static const String getOutStandingList = "/get_party_wise_receivable_total";
  static const String getPartyProduct = "/get_dist_party_product1";
  static const String getReceivable = "/get_receiable";
  static const String getFrequently = "/dist_freq_prod";
  static const String getBounced = "/sale_loss";
  static const String createOrder = "/create_order";
  static const String getMappedProduct = "/matching_product";
  static const String getUnMappedProduct = "/get_unmatched_product";
  static const String MappedProduct = "/mapping_product";
  static const String get_map_product = "/get_map_product";
  static const String get_unmatched_product = "/get_unmatched_product";
  static const String post_mapped_product = "/mapping_product";
  static const String delete_mapped_product = "/deleteProductMapping";
  static const String matching_party = "/matching_party";
  static const String unmatched_party = "/unmatched_party";
  static const String mapping_party = "/mapping_party";
  static const String get_mapping_retailer = "/get_mapping_retailer";
  static const String deleteMappingRetailer = "/deleteMappingRetailer";
  static const String receivablePayable = "/receivablePayable";
  static const String countOrder = "/countOrder";
  static const String get_top_10_salesmen = "/get_top_10_salesmen";


  static String getHeader(){
    return '$header';
  }

  static String getLocationUrl() {
    return '$baseUrl$getLocationEndpoint';
  }
  static String getCategoryUrl() {
    return '$baseUrl$getPharmaCategory';
  }
  static String postRegister() {
    return '$baseUrl$registerUser';
  }
  static String postLogin() {
    return '$baseUrl$loginUser';
  }
  static String postForgotPassword(){
    return '$baseUrl$forgotPassword';
  }
  static String postVerifyOtp(){
    return '$baseUrl$verifyOtp';
  }
  static String resetPassword(){
    return '$baseUrl$resetPass';
  }
  static String getCompanyRequest(){
    return '$baseUrl$getCompany';
  }
  static String uploadImg(){
    return '$baseUrl$uploadImages';
  }
  static String updateRequest(){
    return '$baseUrl$updateCompany';
  }
  static String getAdminProfile(){
    return '$baseUrl$getProfile';
  }
  static String requestUpdateProfile(){
    return '$baseUrl$updateProfile';
  }
  static String reqChangePassword(){
    return '$baseUrl$changePassword';
  }

  static String reqInvoiceDropDown(){
    return '$baseUrl$dropDownInvoice';
  }

  static String reqInvoiceList(){
    return '$baseUrl$getInvoiceList';
  }

  static String reqSalesManList(){
    return '$baseUrl$getSalesMan';
  }

  static String reqAdminList(){
    return '$baseUrl$getAdminList';
  }

  static String postAddUser(){
    return '$baseUrl$addUser';
  }

  static String reqGetOrder(){
    return '$baseUrl$getOrder';
  }

  static String reqOrderDetails(){
    return '$baseUrl$getOrderDetails';
  }

  static String reqGetDraftOrder(){
    return '$baseUrl$getDraftOrder';
  }


  static String reqGetOutStanding(){
    return '$baseUrl$getOutStandingList';
  }

  static String reqPartyProduct(){
    return '$baseUrl$getPartyProduct';
  }

  static String reqReceivableList(){
    return '$baseUrl$getReceivable';
  }

  static String reqFrequentlyList(){
    return '$baseUrl$getFrequently';
  }

  static String reqBouncedList(){
    return '$baseUrl$getBounced';
  }

  static String reqCreateOrder(){
    return '$baseUrl$createOrder';
  }

  static String reqMapProduct(){
    return '$baseUrl$getMappedProduct';
  }

  static String reqUnMapProduct(){
    return '$baseUrl$getUnMappedProduct';
  }

  static String postMapProduct(){
    return '$baseUrl$MappedProduct';
  }

  static String reqMappedProduct(){
    return '$baseUrl$get_map_product';
  }
  static String reqUnmappedProduct(){
    return '$baseUrl$getUnMappedProduct';
  }
  static String reqEditMapProduct(){
    return '$baseUrl$post_mapped_product';
  }
  static String reqDeleteMapProduct(){
    return '$baseUrl$delete_mapped_product';
  }

  static String reqMatchingParty(){
    return '$baseUrl$matching_party';
  }

  static String reqUnmatchedParty(){
    return '$baseUrl$unmatched_party';
  }

  static String reqMappingParty(){
    return '$baseUrl$mapping_party';
  }

  static String reqget_mapping_retailer(){
    return '$baseUrl$get_mapping_retailer';
  }
  static String reqDeleteRetailer(){
    return '$baseUrl$deleteMappingRetailer';
  }

  static String reqDashboardReceivablePayable(){
    return '$baseUrl$receivablePayable';
  }

  static String reqDashboardcountOrder(){
    return '$baseUrl$countOrder';
  }

  static String reqGet_top_10_salesmen(){
    return'$baseUrl$get_top_10_salesmen';
  }

}