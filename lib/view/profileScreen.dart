import 'dart:convert';
import 'dart:io';

import 'package:distributers_app/dataModels/ProfileModel.dart';
import 'package:distributers_app/services/api_services.dart';
import 'package:distributers_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/LoadingIndicator.dart'; // Import http package



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _welcomeNoteController = TextEditingController();
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Form key for validation
  late ProfileModel profileModel;
  String _selectedDOB = 'Select Date';
  String _selectedMarriageDate = 'Select Date';
  String username = "";
  String companyName = "";
  String userCode = "";
  String businessTpe = "";
  bool _isEmailEditable = false;
  bool _isContactEditable = false;
  bool _isWelcomeNoteEditable = false;
  File? _profileImage; // Store the selected image file
  bool _isLoading = false; // Add a loading state flag
  String profilePic = "";
  int u_id = 0;

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndFetchProfile(); // Call the async function

  }

  Future<void> _loadPreferencesAndFetchProfile() async {
    final prefs = await SharedPreferences.getInstance(); // Await the Future to resolve
    companyName = prefs.getString("division") ?? ''; // Now you can safely use getString
    u_id = prefs.getInt("u_id") ?? 0;

    _fetchProfile(); // Fetch profile data after loading preferences
  }

  Future<void> _fetchProfile() async {
    try {
      // Fetch the profile model asynchronously
      profileModel = await getProfile();

      // Assign fetched data to controllers and variables, providing fallback values if null
      _emailController.text = profileModel.data?.email ?? ''; // Safely handle null
      _contactController.text = profileModel.data?.mobile ?? ''; // Safely handle null
      _welcomeNoteController.text = profileModel.data?.wnote ?? ''; // Safely handle null

      // Assign values from profile model and preferences
      username = profileModel!.data?.userName ?? 'Unknown'; // Use default if null
      userCode = profileModel!.data?.duNo ?? 'N/A'; // Use default if null
      businessTpe = profileModel!.data?.businessType ?? 'Unknown'; // Use default if null
      profilePic = profileModel!.data?.urlPhoto ?? ''; // Safely handle null

      // Safely handle optional fields like DOB and wedding date
      _selectedDOB = profileModel!.data?.dob != null
          ? formatDateFromIso(profileModel!.data!.dob!)
          : 'Not Provided'; // Default message if null

      _selectedMarriageDate = profileModel!.data?.wad != null
          ? formatDateFromIso(profileModel!.data!.wad!)
          : 'Not Provided'; // Default message if null

      // Now update the state synchronously
      setState(() {});
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<String?> uploadImage(File image) async {
    final url = ApiConfig.uploadImg(); // Replace with your image upload endpoint

    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Attach the image file
      request.files.add(await http.MultipartFile.fromPath('images', image.path));

      // Send the request and wait for the response
      var response = await request.send();

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Convert response to string and then parse it as JSON
        final responseString = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseString); // Parse the response

        if (decodedResponse['url'] != null && decodedResponse['url'].isNotEmpty) {
          String imageUrl = decodedResponse['url'][0]; // Get the first image URL from the response
          print("Image uploaded successfully: $imageUrl");
          return imageUrl; // Return the image URL
        } else {
          print("No image URL found in response");
          return null;
        }
      } else {
        print("Failed to upload image: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> postProfileData(String imageUrl) async {
    final url = ApiConfig.requestUpdateProfile(); // Your profile update endpoint

    // Create the JSON body
    final Map<String, dynamic> body = {
      "u_id": u_id,
      "code": userCode,
      "mobile": _contactController.text,
      "email": _emailController.text,
      "dob":_selectedDOB,
      "wad": _selectedMarriageDate,
      "url_photo": imageUrl,
      "isactive":true,
      "wnote": _welcomeNoteController.text
    };

    print("checking modelss ${body}");

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        print("Response data: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile Updated Successfully'),
            backgroundColor: Colors.green, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );

        Navigator.of(context).pop();
      } else {
        print("Failed to post data: ${response.statusCode}");
        print("Response body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.red, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red, // Optional: Customize the color
          duration: Duration(seconds: 2), // Duration for the SnackBar
        ),
      );
      print('Error posting data: $e');
    }
  }

  Future<void> postProfileDataWithoutProfile() async {
    final url = ApiConfig.requestUpdateProfile(); // Your profile update endpoint

    // Create the JSON body
    final Map<String, dynamic> body = {
      "u_id": u_id,
      "code": userCode,
      "mobile": _contactController.text,
      "email": _emailController.text,
      "dob": "2022-05-22",
      "wad": "2024-05-22",
      "isactive":true,
      "wnote": _welcomeNoteController.text
    };

    print("checking modelss ${body}");

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        print("Response data: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile Updated Successfully'),
            backgroundColor: Colors.green, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );

        Navigator.of(context).pop();
      } else {
        print("Failed to post data: ${response.statusCode}");
        print("Response body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.red, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
      }
    } catch (e) {
      print('Error posting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red, // Optional: Customize the color
          duration: Duration(seconds: 2), // Duration for the SnackBar
        ),
      );
    }
  }

  Future<void> uploadAndPostProfile() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Step 1: Upload the image
      File? imageFile = _profileImage;
      String? imageUrl = await uploadImage(imageFile!);

      if (imageUrl != null) {
        // Step 2: Post the profile data with the uploaded image URL
        await postProfileData(imageUrl);
      } else {
        print("Image upload failed, skipping profile update.");
      }
    } catch (e) {
      postProfileDataWithoutProfile();
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return ""; // Return empty if dateStr is null or empty
    }

    try {
      // Parse the date from the given format (e.g., "M/d/yyyy")
      DateTime parsedDate = DateFormat('M/d/yyyy').parse(dateStr);

      // Format the date as "d-M-yyyy"
      String formattedDate = DateFormat('d-M-yyyy').format(parsedDate);

      return formattedDate;
    } catch (e) {
      print('Error parsing date: $e');
      return ""; // Return empty if parsing fails
    }
  }

  String formatDateFromIso(String isoDateStr) {
    // Parse the ISO 8601 date string
    DateTime parsedDate = DateTime.parse(isoDateStr);

    // Format the date as 9-9-2024
    String formattedDate = DateFormat('yyy-MM-dd').format(parsedDate);

    return formattedDate;
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    // Show a dialog to choose between camera or gallery
    final pickedFile = await showDialog<XFile>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Image Source'),
          actions: [
            TextButton(
              onPressed: () async {
                final image = await _picker.pickImage(source: ImageSource.camera);
                Navigator.of(context).pop(image);
              },
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () async {
                final image = await _picker.pickImage(source: ImageSource.gallery);
                Navigator.of(context).pop(image);
              },
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Store the selected image
      });
    }
  }

  Future<void> _selectDate(BuildContext context, String label) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        if (label == 'Date of Birth') {
          _selectedDOB = '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';
        } else {
          _selectedMarriageDate = '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';
        }
      });
    }
  }

  Future<ProfileModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');

    print("usernamessssssssssssss $u_id");

    final url = ApiConfig.getAdminProfile();
    final Map<String, dynamic> body = {
      'u_id': u_id,
      'code': savedUsername,
    };

    print(body);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      // Print the raw response body
      print("Admin Profile Response: ${response.body}");

      // Parse and return the ProfileModel
      return ProfileModel.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response, throw an exception
      print("falied to response");
      throw Exception('Failed to load data');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Outside card background color
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: RiveAppTheme.background, // Use theme or specific color
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (!_isLoading) { // Allow navigation only if not loading
              Navigator.of(context).pop(); // Go back to the previous screen
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // Main UI
          AbsorbPointer(
            absorbing: _isLoading, // Disable interaction if loading
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    RiveAppTheme.background, // Gradient start color
                    Color(0xFF147D73), // Gradient end color
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(15), // Add padding to the scroll area
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Card with fixed height and scrollable content
                      Container(
                        child: _buildProfileCard(),
                      ),
                      SizedBox(height: 5), // Space between sections
                      // Button Row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle change password action
                                if (!_isLoading) {
                                  _showChangePasswordSheet(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text(
                                'Change Password',
                                style: TextStyle(
                                  color: RiveAppTheme.background3,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 30), // Space between buttons
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (!_isLoading) {
                                  // Trigger upload and update
                                  uploadAndPostProfile();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text(
                                'Update',
                                style: TextStyle(
                                  color: RiveAppTheme.background3,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
              child: Center(
                child: LoadingIndicator(), // Loading animation widget
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildProfileCard() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8, // Adjust height based on your need
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4ECDC4),
                Color(0xFF556270)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView( // Scrollable content inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image with Camera Icon in the center
                  Center(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) // Show selected image from file
                          : (profilePic != null && profilePic!.isNotEmpty
                          ? NetworkImage(profilePic!) // Show image from URL
                          : null), // If no URL, show null

                      child: Stack(
                        children: [
                          if (_profileImage == null && (profilePic == null || profilePic!.isEmpty)) // Show default icon if no image is selected and no URL
                            Align(
                              alignment: Alignment.center,
                              child: Icon(Icons.person, size: 40, color: Colors.white),
                            ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(Icons.camera_alt, size: 15, color: Colors.black),
                                onPressed: _pickImage, // Open camera or gallery
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ),


                  SizedBox(height: 30),

                  // Non-editable Fields
                  _buildInfoRow(Icons.person, 'Username', username, isEditable: false),
                  _buildInfoRow(Icons.business, 'Company Name', companyName, isEditable: false),
                  _buildInfoRow(Icons.code, 'User Code', userCode, isEditable: false),
                  _buildInfoRow(Icons.business_center, 'Business Type', businessTpe, isEditable: false),

                  // Editable Fields
                  _buildEditableInfoRow(
                    Icons.email,
                    'Email',
                    _emailController,
                    _emailController.text,
                    _isEmailEditable,
                        () {
                      setState(() {
                        _isEmailEditable = !_isEmailEditable;
                      });
                    },
                  ),
                  _buildEditableInfoRow(
                    Icons.phone,
                    'Contact Number',
                    _contactController,
                    _contactController.text,
                    _isContactEditable,
                        () {
                      setState(() {
                        _isContactEditable = !_isContactEditable;
                      });
                    },
                  ),
                  _buildEditableInfoRow(
                    Icons.note,
                    'Welcome Note',
                    _welcomeNoteController,
                    _welcomeNoteController.text,
                    _isWelcomeNoteEditable,
                        () {
                      setState(() {
                        _isWelcomeNoteEditable = !_isWelcomeNoteEditable;
                      });
                    },
                  ),

                  // Date of Birth and Marriage Date
                  _buildDateField(context, 'Date of Birth', _selectedDOB ),
                  _buildDateField(context, 'Marriage Date', _selectedMarriageDate ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildInfoRow(IconData icon, String label, String value, {bool isEditable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Editable Row Widget
  Widget _buildEditableInfoRow(
      IconData icon,
      String label,
      TextEditingController controller,
      String initialValue,
      bool isEditable,
      VoidCallback toggleEdit,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
                // Reduce the height here to minimize space
                SizedBox(height: 2), // Further reduce this value if needed
                TextField(
                  controller: controller..text = initialValue,
                  enabled: isEditable,
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 0, bottom: 0), // Adjust to reduce padding
                    isDense: true, // Reduce height of the TextField
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(isEditable ? Icons.check : Icons.edit, size: 20, color: Colors.white),
            onPressed: toggleEdit,
          ),
        ],
      ),
    );
  }

  // Date Field Widget
  Widget _buildDateField(BuildContext context, String label, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 24, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context, label),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                  Text(date, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> changePass() async {
    // Define the URL of the API endpoint
    final String url = ApiConfig.reqChangePassword(); // Replace with actual endpoint

    // Define the body of the request
    Map<String, dynamic> requestBody = {
      "u_id": u_id,
      "status": 1, // if login 1 else 0
      "old_password": _oldPasswordController.text, // if login
      "password": _confirmPasswordController.text,
      "code": userCode,
    };

    // Encode the body to JSON format
    String jsonBody = jsonEncode(requestBody);

    // Set the headers for the request
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    // Make the POST request
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        // Request was successful, handle response here
        print('Response data: ${response.body}');

        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password Changed Successfully'),
            backgroundColor: Colors.green, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );

        Navigator.of(context).pop();
      } else {
        // Handle errors
        print('Error: ${response.statusCode}, ${response.body}');

        // Show error SnackBar for incorrect old password
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Old Password is not correct'),
            backgroundColor: Colors.red, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions during the request
      print('Request failed: $e');

      // Show error SnackBar for request failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password. Please try again.'),
          backgroundColor: Colors.red, // Optional: Customize the color
          duration: Duration(seconds: 2), // Duration for the SnackBar
        ),
      );
    }
  }


  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to take up more space
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return AnimatedPadding(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: MediaQuery.of(context).viewInsets, // To handle keyboard opening
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Old Password Field
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: !_isOldPasswordVisible, // Hide text
                        decoration: InputDecoration(
                          labelText: 'Old Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isOldPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isOldPasswordVisible = !_isOldPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your old password';
                          } else if (value.length <= 4) {
                            return 'Password must be more than 4 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      // New Password Field
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: !_isNewPasswordVisible, // Hide text
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your new password';
                          } else if (value.length <= 4) {
                            return 'Password must be more than 4 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible, // Hide text
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          } else if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Change Password Button
                      // Change Password Button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            changePass();
                            Navigator.pop(context); // Close the bottom sheet after submission
                          }
                        },
                        child: Text('Change Password'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: TextStyle(color: Colors.white), // Custom text style
                          backgroundColor: RiveAppTheme.background2, // Optional: Set background color
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

}
