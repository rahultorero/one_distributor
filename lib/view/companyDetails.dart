import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:distributers_app/components/LoadingIndicator.dart';
import 'package:distributers_app/dataModels/CompanyModel.dart';
import 'package:distributers_app/view/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/bottomshit.dart';
import '../components/controller/FormData.dart';
import '../dataModels/LocationModel.dart';
import '../dataModels/PharmaCategory.dart';
import '../dataModels/UpdateCompanyModel.dart';
import '../services/api_services.dart';
import 'mainScreen.dart';
import 'package:http/http.dart' as http; // Import http package

import 'package:http_parser/http_parser.dart';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart'; // For picking images and documents


class CompanyDetails extends StatefulWidget {
  const CompanyDetails({Key? key, required this.closeModal}) : super(key: key);

  // Close modal callback for any screen that uses this as a modal
  final VoidCallback closeModal;

  @override
  _CompanyDetailsState createState() => _CompanyDetailsState();
}

class _CompanyDetailsState extends State<CompanyDetails> {
  final GlobalKey<_BusinessDetailsScreenState> _businessDetailsKey = GlobalKey<_BusinessDetailsScreenState>();

  int _currentStep = 0;
  late List<StateModel> states = [];
  late List<CityModel> cities = [];
  late List<AreaModel> areas = [];
  List<PharmaCategory> pharma = []; // Properly typed
  List<PharmaCategory> fmcg = [];
  List<PharmaCategory> others = [];
  bool _isFormValid = false;
  bool _isLoading = false; // Variable to manage loading state
  CompanyModel? companyModels;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLocationData();
    fetchPharmaCategory();
    _checkUsername();

  }

  void _checkUsername() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedUsername = prefs.getString('username');


    if (savedUsername != null) {
      fetchCompanyDetails(savedUsername);

    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      final businessDetailsScreenState = _businessDetailsKey.currentState;
      if (businessDetailsScreenState != null) {
        print("Calling _validateForm");
        _isFormValid = businessDetailsScreenState._validateForm();
        print("Form is valid: $_isFormValid");

        if (_isFormValid) {
          final formData = context.read<FormDataProvider>().formData;

          // Check if any required field is empty or null
          bool hasInvalidField = false;
          String errorMessage = '';

          if (formData.businessName == null || formData.businessName.isEmpty) {
            errorMessage = 'Business Name is required';
            hasInvalidField = true;
          } else if (formData.address1 == null || formData.address1.isEmpty) {
            errorMessage = 'Address 1 is required';
            hasInvalidField = true;
          }  else if (formData.selectedCity == null) {
            errorMessage = 'City is required';
            hasInvalidField = true;
          } else if (formData.selectedState == null) {
            errorMessage = 'State is required';
            hasInvalidField = true;
          } else if (formData.pincode == null || formData.pincode.isEmpty) {
            errorMessage = 'Pincode is required';
            hasInvalidField = true;
          } else if (formData.email == null || formData.email.isEmpty) {
            errorMessage = 'Email is required';
            hasInvalidField = true;
          } else if (formData.personName == null || formData.personName.isEmpty) {
            errorMessage = 'Person Name is required';
            hasInvalidField = true;
          } else if (formData.panNo == null || formData.panNo.isEmpty) {
            errorMessage = 'PAN No is required';
            hasInvalidField = true;
          }

          if (hasInvalidField) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
            return; // Do not proceed to the next step
          }

          if (_currentStep < 2) {
            setState(() {
              _currentStep++;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please fill in all required fields'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }



  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<LocationResponse> fetchLocationData() async {
    final String apiUrl = ApiConfig.getLocationUrl(); // Get the full URL from ApiConfig

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final locationResponse = LocationResponse.fromJson(jsonResponse);
        print('Location Data: ${jsonResponse}'); // Print the response data
        setState(() {
          states = locationResponse.states;
          cities = locationResponse.cities;
          areas = locationResponse.areas;
        });
        return LocationResponse.fromJson(jsonResponse);
      } else {
        // Handle non-200 response codes
        throw Exception('Failed to load location data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<CategoryResponse> fetchPharmaCategory() async {
    final String apiUrl = ApiConfig.getCategoryUrl(); // Get the full URL from ApiConfig

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Raw Response Body: $responseBody'); // Print the raw response body for debugging

        final jsonResponse = json.decode(responseBody);
        final categoryResponse = CategoryResponse.fromJson(jsonResponse);

        // Ensure that this is inside a StatefulWidget
        setState(() {
          pharma = categoryResponse.pharma;
          fmcg = categoryResponse.fmcg;
          others = categoryResponse.others;
        });

        return categoryResponse; // Return parsed response directly
      } else {
        throw Exception('Failed to load category data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to fetch data: $e');
    }

  }

  Future<CompanyModel?> fetchCompanyDetails(String regCode) async {

    final String apiUrl = ApiConfig.getCompanyRequest();

    try {
      final Map<String, String> body = {
        'reg_code': regCode,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print("responsee is 200");
        final jsonResponse = json.decode(response.body);
        print("checking the responses ergergegrt $jsonResponse");
          companyModels = CompanyModel.fromJson(jsonResponse);
          print("checking the responses ${companyModels?.toJson()}");


        return companyModels;
      } else {
        throw Exception('Failed to load company data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null; // Return null if fetching fails
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _currentStep == 0
                    ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      floating: false,
                      pinned: true,
                      expandedHeight: 110.0,
                      flexibleSpace: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          var top = constraints.biggest.height;
                          return FlexibleSpaceBar(
                            title: top <= 100
                                ? Text(
                              'Edit Details',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            )
                                : Text(
                              'Business Details',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Inter",
                                fontSize: 20,
                              ),
                            ),
                            centerTitle: top > 100,
                            background: Container(
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          widget.closeModal();
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: companyModels != null
                          ? BusinessDetailsScreen(
                        key: _businessDetailsKey,
                        states: states,
                        cities: cities,
                        areas: areas,
                        companyModels: companyModels!,
                        onValidate: (isValid) {
                          setState(() {
                            _isFormValid = isValid;
                          });
                        },
                      )
                          : Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                )
                    : _currentStep == 1
                    ? CategoryScreen(
                  pharma: pharma,
                  fmcg: fmcg,
                  other: others,
                  businessDetail: companyModels!.data!.businessDetail!,
                )
                    : UploadDocumentScreen(),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          width: 11.0,
                          height: 11.0,
                          decoration: BoxDecoration(
                            color: _currentStep == index ? Color(0xFF199A8E) : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          ElevatedButton(
                            onPressed: _previousStep,
                            child: Text('Back'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                            ),
                          ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentStep < 2) {
                              _nextStep();
                            } else {
                              if (!_isLoading) {
                                setState(() {
                                  _isLoading = true; // Show the loader
                                });

                                updateModel().then((_) {
                                  setState(() {
                                    _isLoading = false; // Hide the loader after API request is done
                                  });
                                });
                              }
                            }
                          },
                          child: Text(_currentStep < 2 ? 'Next' : 'Update'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF199A8E),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54, // Semi-transparent background
              child: Center(
                child: LoadingIndicator(), // Centered loading indicator
              ),
            ),
        ],
      ),
    );
  }


  Future<void> updateModel() async {
    final formData = context.read<FormDataProvider>().formData;
    UpdateCompanyModel model = UpdateCompanyModel(
      regCode: companyModels?.data?.dCode,
      updateFields: UpdateFields(
        regName: formData.businessName,
        add1: formData.address1,
        add2: formData.address2,
        fxdidState: 60,
        pincode: formData.pincode,
        email: formData.email,
        mob: formData.contactNo,
        fixidBusstype: companyModels?.data?.fixidBusstype,
        cusrid: companyModels?.data?.cusrid,
      ),
      gst: [

      ],
    );

    sendUpdateRequest(model);
  }


  // Function to send a POST request
  Future<void> sendUpdateRequest(UpdateCompanyModel model) async {
    print("checking the modelData ${model.toJson()}");

    setState(() {
      _isLoading = true; // Show the loader
    });

    // The API endpoint URL
    final String apiUrl = ApiConfig.updateRequest();

    // Convert the model to a JSON string
    final Map<String, dynamic> requestData = model.toJson();

    try {
      // Sending the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json', // Set content-type to application/json
        },
        body: json.encode(requestData), // Convert the request data to JSON
      );

      // Checking if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        var responseData = json.decode(response.body);

        // Display the success dialog
        AwesomeDialog(
          context: context,
          animType: AnimType.leftSlide,
          headerAnimationLoop: false,
          dialogType: DialogType.success,
          showCloseIcon: false,
          title: 'Success',
          desc: 'Details are updated Successfully',
          btnOkOnPress: () {
            widget.closeModal(); // Close the modal
          },
          btnOkIcon: Icons.check_circle,
          onDismissCallback: (type) {
            debugPrint('Dialog dismissed: $type');
          },
        ).show();

        print('Request sent successfully: $responseData');
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending POST request: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide the loader
      });
    }
  }


}

class BusinessDetailsScreen extends StatefulWidget {
  final List<StateModel> states;
  final List<CityModel> cities;
  final List<AreaModel> areas;
  final Function(bool)? onValidate;
  final CompanyModel companyModels;

  BusinessDetailsScreen({
    required this.states,
    required this.cities,
    required this.areas,
    this.onValidate,
    required this.companyModels,
    Key? key,
  }) : super(key: key);

  @override
  _BusinessDetailsScreenState createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late FocusNode _areaFocusNode;
  late FocusNode _cityFocusNode;
  late FocusNode _stateFocusNode;

  // Error text variables
  String? _businessNameError;
  String? _address1Error;
  String? _address2Error;
  String? _areaError;
  String? _cityError;
  String? _stateError;
  String? _pincodeError;
  String? _contactNoError;
  String? _emailError;
  String? _personNameError;
  String? _gstNoError;
  String? _panNoError;
  String? _drugLicenceNoError;
  String? _fssaiNoError;
  String? _udyamNoError;

  // Selected values
  String? _selectedState;
  String? _selectedStateCode;
  String? _selectedCity;
  String? _selectedArea;

  late TextEditingController _businessNameTextController;
  late TextEditingController _address1TextController;
  late TextEditingController _address2TextController;
  late TextEditingController _areaTextController;
  late TextEditingController _cityTextController;
  late TextEditingController _stateTextController;
  late TextEditingController _pincodeTextController;
  late TextEditingController _contactNoTextController;
  late TextEditingController _emailTextController;
  late TextEditingController _personNameTextController;
  late TextEditingController _gstNoTextController;
  late TextEditingController _panNoTextController;
  late TextEditingController _drugLicenceNoTextController;
  late TextEditingController _fssaiNoTextController;
  late TextEditingController _udyamNoTextController;

  // Animation Controllers
  late AnimationController _businessNameController;
  late AnimationController _address1Controller;
  late AnimationController _address2Controller;
  late AnimationController _areaController;
  late AnimationController _cityController;
  late AnimationController _stateController;
  late AnimationController _pincodeController;
  late AnimationController _contactNoController;
  late AnimationController _emailController;
  late AnimationController _personNameController;
  late AnimationController _gstNoController;
  late AnimationController _panNoController;
  late AnimationController _drugLicenceNoController;
  late AnimationController _fssaiNoController;
  late AnimationController _udyamNoController;

  // Local field values
  String? _businessName;
  String? _address1;
  String? _address2;
  String? _pincode;
  String? _contactNo;
  String? _email;
  String? _personName;
  String? _gstNo;
  String? _panNo;
  String? _drugLicenceNo;
  String? _fssaiNo;
  String? _udyamNo;

  @override
  void initState() {
    super.initState();

    final formData = Provider.of<FormDataProvider>(context, listen: false).formData;
    print('seeeeeee ${widget.companyModels.data?.email}');
    // Initialize local values with provider data
    _businessName = formData.businessName;
    _address1 = formData.address1;
    _address2 = formData.address2;
    _pincode = formData.pincode;
    _contactNo = formData.contactNo;
    _email = formData.email;
    _personName = formData.personName;
    _gstNo = formData.gstNo;
    _panNo = formData.panNo;
    _drugLicenceNo = formData.drugLicenceNo;
    _fssaiNo = formData.fssaiNo;
    _udyamNo = formData.udyamNo;
    _selectedState = formData.selectedState;
    _selectedCity = formData.selectedCity;
    _selectedArea = formData.selectedArea;

    print("print location   ${widget.companyModels.data?.grpidArea}");
    print("print location   ${widget.companyModels.data?.fxdidState}");

    // Initialize TextEditingControllers with initial values
    _businessNameTextController = TextEditingController(text: widget.companyModels.data?.regName);
    _address1TextController = TextEditingController(text: widget.companyModels.data?.add1);
    _address2TextController = TextEditingController(text: widget.companyModels.data?.add2);
    _pincodeTextController = TextEditingController(text: widget.companyModels.data?.pincode.toString());
    _contactNoTextController = TextEditingController(text: widget.companyModels.data?.mob);
    _emailTextController = TextEditingController(text: widget.companyModels.data?.email);
    _personNameTextController = TextEditingController(text: widget.companyModels.data?.businessDetail?.fxdname);
    _gstNoTextController = TextEditingController();
    _panNoTextController = TextEditingController();
    _drugLicenceNoTextController = TextEditingController();
    _fssaiNoTextController = TextEditingController();
    _udyamNoTextController = TextEditingController();



    _businessName = widget.companyModels.data?.regName;
    _address1 = widget.companyModels.data?.add1;
    _address2 = widget.companyModels.data?.add2;
    _pincode = widget.companyModels.data!.pincode.toString();
    _contactNo = widget.companyModels.data?.mob;
    _email = widget.companyModels.data?.email;
    _personName = widget.companyModels.data?.businessDetail?.fxdname;


    _selectedArea = widget.companyModels.data?.grpidArea;
    _selectedState = widget.companyModels.data?.fxdidState;
    _selectedCity = widget.companyModels.data?.grpidCity;

    // Initialize AnimationControllers
    _businessNameController = _createController();
    _address1Controller = _createController();
    _address2Controller = _createController();
    _areaController = _createController();
    _cityController = _createController();
    _stateController = _createController();
    _pincodeController = _createController();
    _contactNoController = _createController();
    _emailController = _createController();
    _personNameController = _createController();
    _gstNoController = _createController();
    _panNoController = _createController();
    _drugLicenceNoController = _createController();
    _fssaiNoController = _createController();
    _udyamNoController = _createController();



    _areaFocusNode = FocusNode();
    _cityFocusNode = FocusNode();
    _stateFocusNode = FocusNode();



  }

  AnimationController _createController() {
    return AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // Dispose of AnimationControllers
    _businessNameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _contactNoController.dispose();
    _emailController.dispose();
    _personNameController.dispose();
    _gstNoController.dispose();
    _panNoController.dispose();
    _drugLicenceNoController.dispose();
    _fssaiNoController.dispose();
    _udyamNoController.dispose();

    _businessNameTextController.dispose();
    _address1TextController.dispose();
    _address2TextController.dispose();
    _pincodeTextController.dispose();
    _contactNoTextController.dispose();
    _emailTextController.dispose();
    _personNameTextController.dispose();
    _gstNoTextController.dispose();
    _panNoTextController.dispose();
    _drugLicenceNoTextController.dispose();
    _fssaiNoTextController.dispose();
    _udyamNoTextController.dispose();

    _areaFocusNode.dispose();
    _cityFocusNode.dispose();
    _stateFocusNode.dispose();

    super.dispose();
  }



  bool _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      Provider.of<FormDataProvider>(context, listen: false).updateBusinessDetails(
        businessName: _businessName,
        address1: _address1,
        address2: _address2,
        selectedArea: _selectedArea,
        selectedCity: _selectedCity,
        selectedState: _selectedState,
        selectedCode: _selectedStateCode,
        pincode: _pincode,
        contactNo: _contactNo,
        email: _email,
        personName: _personName,
        gstNo: _gstNo,
        panNo: _panNo,
        drugLicenceNo: _drugLicenceNo,
        fssaiNo: _fssaiNo,
        udyamNo: _udyamNo,
      );
    }
    widget.onValidate?.call(isValid);
    return isValid;
  }

  void _validateField(String fieldLabel, String value, AnimationController controller) {
    setState(() {
      switch (fieldLabel) {
        case 'Business Name*':
          _businessName = value;
          _businessNameError = value.isEmpty ? 'Business name is required' : null;
          if (_businessNameError != null) controller.forward(from: 0);
          break;
        case 'Address 1*':
          _address1 = value;
          _address1Error = value.isEmpty ? 'Address 1 is required' : null;
          if (_address1Error != null) controller.forward(from: 0);
          break;
        case 'Address 2':
          _address2 = value;
          break;
        case 'City*':
          _cityError = value.isEmpty ? 'City is required' : null;
          if (_cityError != null) controller.forward(from: 0);
          break;
        case 'State*':
          _stateError = value.isEmpty ? 'State is required' : null;
          if (_stateError != null) controller.forward(from: 0);
          break;
        case 'Pincode*':
          _pincode = value;
          _pincodeError = value.isEmpty ? 'Pincode is required' : null;
          if (_pincodeError != null) controller.forward(from: 0);
          break;
        case 'Contact No*':
          _contactNo = value;
          _contactNoError = value.isEmpty ? 'Contact No is required' : null;
          if (_contactNoError != null) controller.forward(from: 0);
          break;
        case 'Email*':
          _email = value;
          _emailError = value.isEmpty
              ? 'Email is required'
              : (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
              ? 'Enter a valid email'
              : null;
          if (_emailError != null) controller.forward(from: 0);
          break;
        case 'Person Name*':
          _personName = value;
          _personNameError = value.isEmpty ? 'Person name is required' : null;
          if (_personNameError != null) controller.forward(from: 0);
          break;
        case 'PAN No*':
          _panNo = value;
          _panNoError = value.isEmpty ? 'PAN No is required' : null;
          if (_panNoError != null) controller.forward(from: 0);
          break;
        case 'GST No':
          _gstNo = value;
          _gstNoError = (!RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$', caseSensitive: false).hasMatch(value))
              ? 'Enter a valid GST No'
              : null;
          if (_gstNoError != null) controller.forward(from: 0); // Trigger shake animation if error
          break;

        case 'Drug Licence No':
          _drugLicenceNo = value;
          break;
        case 'FSSAI No':
          _fssaiNo = value;
          break;
        case 'Udyam No':
          _udyamNo = value;
          break;
      // Add cases for other fields as needed
      }
    });
  }

  void _showBottomSheet(
      String title,
      List<String> code,
      List<String> items,
      ValueChanged<String> onItemSelected,
      ValueChanged<String> onCodeSelected,
      ) {
    CustomBottomSheet.show(
      context,
      title,
      items,
          (selectedItem) {
        setState(() {
          onItemSelected(selectedItem);

          // Find the index of the selected item in the items list
          int selectedIndex = items.indexOf(selectedItem);
          if (selectedIndex != -1 && selectedIndex < code.length) {
            // Safely access the code list
            String selectedCode = code[selectedIndex];
            onCodeSelected(selectedCode); // Call onCodeSelected with the code
          } else {
            // Handle invalid index
            print('Error: Selected index out of bounds or code list is empty');
          }
        });

        // Close the keyboard after selection
        FocusScope.of(context).unfocus();
      },
      onCodeSelected, // Pass this parameter correctly
    );
  }







  @override
  Widget build(BuildContext context) {
    if (widget.states.isEmpty || widget.cities.isEmpty || widget.areas.isEmpty) {
      return Center(child:LoadingIndicator()); // Display a loader or fallback UI
    }
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 15),
              _buildShakableTextFormField('Business Name*', _businessNameError, _businessNameController,textController: _businessNameTextController),
              SizedBox(height: 20),
              _buildShakableTextFormField('Address 1*', _address1Error, _address1Controller,textController: _address1TextController),
              SizedBox(height: 20),
              _buildShakableTextFormField('Address 2', _address2Error, _address2Controller,textController: _address2TextController),
              SizedBox(height: 20),
              _buildSelectableField(
                'Area',
                _selectedArea,
                [], // Pass an empty list for the "code"
                widget.areas.map((area) => area.grpname).toList(),
                    (selectedArea) => _selectedArea = selectedArea,
                    (selectedArea) => _selectedArea = selectedArea,
                _areaFocusNode,
              ),
              SizedBox(height: 20),
              _buildSelectableField(
                'City*',
                _selectedCity,
                [], // Pass an empty list for the "code"
                widget.cities.map((city) => city.grpname).toList(),
                    (selectedCity) => _selectedCity = selectedCity,
                    (selectedCity) => _selectedCity = selectedCity,
                _cityFocusNode,
              ),
              SizedBox(height: 20),
              _buildSelectableField(
                'State*',
                _selectedState,
                widget.states.map((state) => state.statecode).toList(), // List of codes
                widget.states.map((state) => state.fxdname).toList(), // List of items
                    (selectedState) => _selectedState = selectedState, // Updates selected state
                    (selectedStateCode) => _selectedStateCode = selectedStateCode, // Updates selected code
                _stateFocusNode, // FocusNode
              ),

              SizedBox(height: 20),
              _buildShakableTextFormField(
                  'Pincode*',
                  _pincodeError,
                  _pincodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textController: _pincodeTextController
              ),

              SizedBox(height: 20),

              _buildShakableTextFormField(
                  'Contact No*',
                  _contactNoError,
                  _contactNoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textController: _contactNoTextController
              ),

              SizedBox(height: 20),
              _buildShakableTextFormField('Email*', _emailError, _emailController,textController: _emailTextController),
              SizedBox(height: 20),
              _buildShakableTextFormField('Person Name*', _personNameError, _personNameController,textController: _personNameTextController),
              SizedBox(height: 20),
              _buildShakableTextFormField('GST No', _gstNoError, _gstNoController,
                  textController: _gstNoTextController, inputFormatters: [UpperCaseTextFormatter()]),
              SizedBox(height: 20),
              _buildShakableTextFormField('PAN No*', _panNoError, _panNoController,textController: _panNoTextController, inputFormatters: [UpperCaseTextFormatter()]),
              SizedBox(height: 20),
              _buildShakableTextFormField(
                'Drug Licence No',
                _drugLicenceNoError,
                _drugLicenceNoController,  // AnimationController
                textController: _drugLicenceNoTextController, // TextEditingController
              ),
              SizedBox(height: 20),
              _buildShakableTextFormField('FSSAI No', _fssaiNoError, _fssaiNoController,textController: _fssaiNoTextController),
              SizedBox(height: 20),
              _buildShakableTextFormField('Udyam No', _udyamNoError, _udyamNoController,textController: _udyamNoTextController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShakableTextFormField(
      String labelText,
      String? errorText,
      AnimationController controller, {
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        required TextEditingController textController, // Add this parameter
      }) {
    return ShakeAnimation(
      controller: controller,
      child: Center(
        child: SizedBox(
          width: 330,
          child: TextFormField(
            controller: textController, // Use the TextEditingController
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(color: Color(0xFFA1A8B0)),
              errorText: errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : Color(0xFFE5E7EB),
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : Color(0xFFE5E7EB),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : Color(0xFFE5E7EB),
                  width: 1.0,
                ),
              ),
              filled: true,
              fillColor: Color(0xFFF9FAFB),
              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            onChanged: (value) {
              _validateField(labelText, value, controller);
            },
          ),
        ),
      ),
    );
  }



  Widget _buildSelectableField(
      String labelText,
      String? selectedValue,
      List<String>? code, // The code list
      List<String> items, // The items list
      ValueChanged<String> onItemSelected,
      ValueChanged<String> onCodeSelected, // Added to handle code selection
      FocusNode focusNode, // FocusNode for controlling the field
      ) {
    final TextEditingController controller = TextEditingController(text: selectedValue);

    return GestureDetector(
      onTap: () {
        _showBottomSheet(
            labelText,
            code!,
            items,
                (selectedItem) {
              setState(() {
                // Update the selected item and text controller
                onItemSelected(selectedItem);
                controller.text = selectedItem;

                // Find the index of the selected item in the items list
                int selectedIndex = items.indexOf(selectedItem);
                if (selectedIndex != -1) {
                  // Safely access the code list and update the selected code
                  try{
                    String selectedCode = code[selectedIndex];
                    onCodeSelected(selectedCode); // Update the code selection
                    FocusScope.of(context).unfocus();
                  }catch(e){
                    // Close the keyboard after selection
                    FocusScope.of(context).unfocus();
                  }

                }
              });



            },
            onCodeSelected // Pass the code selection callback
        );
      }
      ,
      child: AbsorbPointer(
        child: Center(
          child: SizedBox(
            width: 330,
            child: TextFormField(
              focusNode: focusNode,
              controller: controller, // Use the controller
              style: TextStyle(color: Colors.black, fontSize: 15),
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: TextStyle(color: Color(0xFFA1A8B0)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                ),
                filled: true,
                fillColor: Color(0xFFF9FAFB),
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              ),
              readOnly: true, // Make the field read-only
              onChanged: (value) {
                // This will not be triggered as the field is read-only
              },
            ),
          ),
        ),
      ),
    );
  }


}

class ShakeAnimation extends StatefulWidget {
  final AnimationController controller;
  final Widget child;

  ShakeAnimation({required this.controller, required this.child});

  @override
  _ShakeAnimationState createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        double offset = 10.0 * (1 - widget.controller.value); // Increased shake intensity
        return Transform.translate(
          offset: Offset(offset * sin(widget.controller.value * 6 * pi), 0), // Shake multiple times (6 * pi)
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class CategoryScreen extends StatefulWidget {
  final List<PharmaCategory> pharma;
  final List<PharmaCategory> fmcg;
  final List<PharmaCategory> other;
  final BusinessDetail businessDetail;

  CategoryScreen({
    required this.pharma,
    required this.fmcg,
    required this.other,
    required this.businessDetail
  });

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<String> industries = ['PHARMA', 'FMCG', 'OTHERS'];
  String? _selectedCheckboxIndustry; // Stores the currently selected checkbox industry
  PharmaCategory? _selectedIndustry; // Stores the currently selected dropdown industry category
  List<PharmaCategory> _currentDropdownItems = []; // To hold the dropdown items

  @override
  void initState() {
    super.initState();
    final formData = Provider.of<FormDataProvider>(context, listen: false).formData;
    _selectedCheckboxIndustry = widget.businessDetail.fxdname;
    _updateDropdownItems();
    formData.selectedCategory = widget.businessDetail.fxdsubname;
    if (formData.selectedCategory != null && _currentDropdownItems.isNotEmpty) {
      print("check category values: ${_currentDropdownItems.first}");

      // Provide a fallback that ensures non-null value
      _selectedIndustry = _currentDropdownItems.firstWhere(
            (category) => category.fxdsubname == widget.businessDetail.fxdsubname,
        orElse: () => _currentDropdownItems.first,
      );
    } else {
      print("No categories available or selected category is null.");
      // Optionally, set _selectedIndustry to a default value if needed.
    }


  }

  // Update the dropdown items based on the selected industry checkbox
  void _updateDropdownItems() {
    setState(() {
      if (_selectedCheckboxIndustry == 'PHARMA') {
        _currentDropdownItems = widget.pharma;
      } else if (_selectedCheckboxIndustry == 'FMCG') {
        _currentDropdownItems = widget.fmcg;
      } else if (_selectedCheckboxIndustry == 'OTHERS') {
        _currentDropdownItems = widget.other;
      } else {
        _currentDropdownItems = [];
      }
      _selectedIndustry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // Horizontal padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 70),
          Text(
            'Category',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Selected Industry (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Column(
            children: industries.map((industry) {
              return CheckboxListTile(
                title: Text(industry),
                value: _selectedCheckboxIndustry == industry,
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedCheckboxIndustry = industry;
                    } else {
                      _selectedCheckboxIndustry = null;
                    }
                    _updateDropdownItems(); // Update dropdown items based on checkbox selection
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Text(
            'Industry Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),

          // Only show the dropdown if there are items in _currentDropdownItems
          _currentDropdownItems.isNotEmpty
              ? DropdownButtonFormField<PharmaCategory>(
            value: _selectedIndustry,
            hint: Text('Select Category'),
            onChanged: (PharmaCategory? newValue) {
              setState(() {
                _selectedIndustry = newValue;
                Provider.of<FormDataProvider>(context, listen: false).updateCategory(
                  _selectedCheckboxIndustry,
                  newValue?.fxdsubname,
                );
              });
            },
            items: _currentDropdownItems.map((category) {
              return DropdownMenuItem<PharmaCategory>(
                value: category,
                child: Text(
                  category.fxdsubname, // Display the subcategory name
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xFFE8F0F2), // Light background color
              prefixIcon: Icon(Icons.category, color: Color(0xFF199A8E)), // Icon for the dropdown
            ),
          )
              : Center(
            child: Text(
              'No categories available. Please select an industry.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}







class UploadDocumentScreen extends StatefulWidget {
  @override
  _UploadDocumentScreenState createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  // Map to store selected file names and paths for each document type
  Map<String, XFile?> _selectedFiles = {
    'Drug License': null,
    'Food License': null,
    'GST Certificate': null,
    'Udyam Certificate': null,
  };

  @override
  void initState() {
    super.initState();
    final formData = Provider.of<FormDataProvider>(context, listen: false).formData;
    // Load saved document paths
    formData.uploadedDocuments.forEach((key, value) {
      if (value != null) {
        _selectedFiles[key] = XFile(value);
      }
    });
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFile(String documentType) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedFiles[documentType] = file;
      Provider.of<FormDataProvider>(context, listen: false).updateUploadedDocument(
        documentType,
        file?.path,
      );
    });
  }

  void _showFileDialog(String documentType) {
    final file = _selectedFiles[documentType];
    if (file == null) return; // No file selected

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54, // Background overlay color
      transitionDuration: Duration(milliseconds: 300), // Animation duration
      pageBuilder: (context, anim1, anim2) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF199A8E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Text(
                  'Selected $documentType',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              file!.path.endsWith('.png') || file.path.endsWith('.jpg') || file.path.endsWith('.jpeg')
                  ? Container(
                padding: EdgeInsets.all(8.0),
                constraints: BoxConstraints(
                  maxHeight: 300,
                  maxWidth: double.infinity,
                ),
                child: Image.file(
                  File(file.path),
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                padding: EdgeInsets.all(16.0),
                constraints: BoxConstraints(
                  maxWidth: double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File Path:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      file.path,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF199A8E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeInOutBack.transform(anim1.value);
        return Transform.translate(
          offset: Offset(0, (1 - curvedValue) * 400), // Bottom to top animation
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Padding around the screen
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 60), // Add some space at the top
          Text(
            'Upload Document',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10), // Space between heading and the list
          Text(
            'Please upload the following documents:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10), // Space between instructions and the list
          Expanded(
            child: ListView(
              children: [
                _buildUploadRow('Drug License'),
                SizedBox(height: 16), // Space between rows
                _buildUploadRow('Food License'),
                SizedBox(height: 16),
                _buildUploadRow('GST Certificate'),
                SizedBox(height: 16),
                _buildUploadRow('Udyam Certificate'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadRow(String documentType) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                documentType,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Click below to upload your $documentType.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              if (_selectedFiles[documentType] != null)
                GestureDetector(
                  onTap: () => _showFileDialog(documentType),
                  child: Text(
                    'Selected file: ${_selectedFiles[documentType]!.name}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _pickFile(documentType),
          icon: Icon(Icons.upload_file, color: Colors.white),
          label: Text('Upload'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF199A8E), // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 13.0),
          ),
        ),
      ],
    );
  }
}

