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
}