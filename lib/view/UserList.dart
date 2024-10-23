import 'dart:convert';
import 'dart:io';

import 'package:distributers_app/components/LoadingIndicator.dart';
import 'package:distributers_app/dataModels/LoginModel.dart';
import 'package:distributers_app/dataModels/SalesManModel.dart';
import 'package:distributers_app/dataModels/UsersModel.dart';
import 'package:distributers_app/services/api_services.dart';
import 'package:distributers_app/theme.dart';
import 'package:distributers_app/view/adminProfile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class User {
  final String code;
  final String username;
  final String email;
  final DateTime dateOfBirth;
  final DateTime weddingDate;
  final String mobileNo;
  final String salesman;
  bool isActive;

  User({
    required this.code,
    required this.username,
    required this.email,
    required this.dateOfBirth,
    required this.weddingDate,
    required this.mobileNo,
    required this.salesman,
    this.isActive = true,
  });
}
class UsersListScreen extends StatefulWidget {
  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  String _filterStatus = 'All';
  List<UserListRes> userList = []; // Initialize as an empty list
  TextEditingController _searchController = TextEditingController();
  List<UserListRes> _filteredUserList = []; // Initialize as an empty list

  @override
  void initState() {
    super.initState();
    postData(); // Fetch user data when the screen loads
    _searchController.addListener(_filterUserList); // Add search listener
  }

  Future<void> postData() async {
    final prefs = await SharedPreferences.getInstance();
    final String apiUrl = ApiConfig.reqAdminList();

    final int? userId = prefs.getInt("u_id");
    final String? regCode = prefs.getString("reg_code");

    if (userId == null || regCode == null) {
      print('User ID or Registration Code is null.');
      return; // Exit if any required value is null
    }

    final userData = {
      "u_id": userId,
      "code": regCode,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> usersData = responseData['data'] ?? [];

        // Update the state with the fetched data
        setState(() {
          userList = usersData.map((user) => UserListRes.fromJson(user)).toList();
          _filteredUserList = userList; // Initialize _filteredUserList after data is fetched
        });
      } else {
        print('Failed to post data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Users',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: RiveAppTheme.background2,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: _setFilter,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'Active', child: Text('Active')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name, Code, Mobile No, Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: _filteredUserList.isEmpty
                ? Center(child: LoadingIndicator())
                : ListView.builder(
              itemCount: _filteredUserList.length,
              itemBuilder: (context, index) {
                final user = _filteredUserList[index];
                double dragOffset = 0.0; // To track swipe offset
                bool isEditingVisible = false; // To track edit button visibility

                return StatefulBuilder(
                  builder: (context, setState) {
                    return GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        // Update the drag offset based on the swipe
                        dragOffset += details.delta.dx;
                        dragOffset = dragOffset.clamp(-100.0, 0.0); // Limit drag offset
                        setState(() {}); // Trigger rebuild to update position
                      },
                      onHorizontalDragEnd: (details) {
                        // Determine if the edit button should be shown or hidden
                        if (dragOffset < -50) {
                          isEditingVisible = true; // Show the edit button
                        } else {
                          dragOffset = 0; // Reset drag offset
                          isEditingVisible = false; // Hide the edit button
                        }
                        setState(() {}); // Trigger rebuild to update state
                      },
                      child: Stack(
                        children: [
                          // Edit button that matches card size
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 200),
                            right: isEditingVisible ? 0 : -100, // Position it off-screen when not visible
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to the edit screen
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AdminProfile(
                                      u_id: user.uId,
                                      username: user.duNo.toString(),
                                    ),
                                  ),
                                );
                                // Reset drag offset and hide button after navigation
                                dragOffset = 0;
                                isEditingVisible = false;
                                setState(() {});
                              },
                              child: Container(
                                width: 100,
                                height: 75,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Edit',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Main content of the item
                          Transform.translate(
                            offset: Offset(dragOffset, 0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                color: Colors.white,
                                shadowColor: Colors.grey.withOpacity(0.5),
                                child: ClipRect(
                                  child: ExpansionTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.orange.shade200,
                                      child: Text(
                                        user.userName.isNotEmpty
                                            ? user.userName.toUpperCase()[0]
                                            : 'U',
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.orange.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      user.userName,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      user.email ?? 'No Email',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                    ),
                                    trailing: Switch(
                                      value: user.isActive,
                                      onChanged: (bool value) {
                                        setState(() {
                                          userList[index] = user.copyWith(isActive: value);
                                        });
                                      },
                                      activeColor: Colors.orange,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildInfoRow(Icons.code, 'Code', user.duNo ?? 'No Code'),
                                            _buildInfoRow(Icons.cake, 'Date of Birth', formatDateFromString(user.dob) ?? 'No DOB'),
                                            if (user.wad != null)
                                              _buildInfoRow(Icons.favorite, 'Wedding Date', formatDateFromString(user.wad)),
                                            _buildInfoRow(Icons.phone, 'Mobile No.', user.mobile),
                                            if (user.salesmanName?.isNotEmpty ?? false)
                                              _buildInfoRow(Icons.person, 'Salesman', user.salesmanName!),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddUserScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: RiveAppTheme.background2,
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

  void _filterUserList() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredUserList = userList.where((user) {
        // Check if the user matches the search query
        final matchesSearch = user.userName.toLowerCase().contains(query) ||
            user.duNo!.toLowerCase().contains(query) ||
            user.mobile.toLowerCase().contains(query) ||
            (user.email?.toLowerCase().contains(query) ?? false);

        // Check if the user matches the filter criteria
        final matchesFilter = _filterStatus == 'All' || user.isActive;

        return matchesSearch && matchesFilter; // Return true if both match
      }).toList();
    });
  }

  // Function to handle the filter change
  void _setFilter(String filter) {
    setState(() {
      _filterStatus = filter;
      _filterUserList(); // Reapply the filter when changed
    });
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;

  DateTime? _dateOfBirth;
  DateTime? _dateOfMarriage;
  File? _profileImage;
  String profilePic = "";
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _welcomeNoteController = TextEditingController(text: 'WELCOME TO ONE SPIDER TECHNOLOGIES LLP.');
  GenderOption? _selectedGenderOption; // Store the selected option
  SalesManModel? _selectedSalesman;
  int? _selectedFxdIdGen; // Store the corresponding FxdIdGen
  int? _selectFXIdSales;
  List<SalesManModel> salesmen = []; // Replace with actual salesmen
  late bool _isPasswordVisible = false;
  Future<void> _selectDate(BuildContext context, bool isDateOfBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          _dateOfBirth = picked;
        } else {
          _dateOfMarriage = picked;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _loadPreferencesAndFetchProfile();
  }

  Future<void> _loadPreferencesAndFetchProfile() async {
    final prefs = await SharedPreferences.getInstance(); // Await the Future to resolve

    postSalesManData(prefs.getInt("companyId") ?? 0, prefs.getString("reg_code") ?? '');
  }


  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path); // Save the selected image file
      });
    }
  }
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _welcomeNoteController.dispose();
    super.dispose();
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
        await _addUser(imageUrl);
      } else {
        print("Image upload failed, skipping profile update.");
      }
    } catch (e) {
      print('Error: $e');
      addUserWithoutProfile(); // Handle the error and proceed without image
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
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

  Future<void> _addUser(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    String apiUrl = ApiConfig.postAddUser();

    final userData = {
      "User_Name": _usernameController.text, // Use .text to get the string value
      "Pwd": _passwordController.text, // Use .text to get the string value
      "Mobile": _mobileController.text, // Use .text to get the string value
      "Email": _emailController.text, // Use .text to get the string value
      "DOB": _dateOfBirth != null ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!) : null, // Use date format
      "WAD": _dateOfMarriage != null ? DateFormat('yyyy-MM-dd').format(_dateOfMarriage!) : null, // Use date format
      "WNote": _welcomeNoteController.text,
      "Url_Photo": imageUrl, // Use path or upload image separately
      "CusrId":prefs.getInt("u_id"),
      "FxdId_Gen": _selectedFxdIdGen,
      "Id_Role": 0,
      "id":prefs.getInt("u_id"),
      "fxd_usertype": 2,
      "smid": _selectFXIdSales,
    };



    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"data":userData}),
      );


      print("check the data $userData");

      if (response.statusCode == 201) {
        // Handle success
        final responseData = json.decode(response.body);
        print('User added successfully: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile Created Successfully'),
            backgroundColor: Colors.green, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
        Navigator.of(context).pop(); // Go back to previous screen or show success message
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed TO Create Profile'),
            backgroundColor: Colors.red, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
        print('Failed to post data. Status code: ${response.statusCode}');
        // Optionally handle the error
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed TO Create Profile'),
          backgroundColor: Colors.red, // Optional: Customize the color
          duration: Duration(seconds: 2), // Duration for the SnackBar
        ),
      );
      print('Error: $e');
      // Optionally handle the exception
    }
  }


  Future<void> addUserWithoutProfile() async {
    final prefs = await SharedPreferences.getInstance();
     String apiUrl = ApiConfig.postAddUser(); // Replace with your API endpoint

    final userData = {
      "User_Name": _usernameController.text, // Use .text to get the string value
      "Pwd": _passwordController.text, // Use .text to get the string value
      "Mobile": _mobileController.text, // Use .text to get the string value
      "Email": _emailController.text, // Use .text to get the string value
      "DOB": _dateOfBirth != null ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!) : null, // Use date format
      "WAD": _dateOfMarriage != null ? DateFormat('yyyy-MM-dd').format(_dateOfMarriage!) : null, // Use date format
      "WNote": _welcomeNoteController.text,
      "CusrId": prefs.getInt("u_id"),
      "FxdId_Gen": _selectedFxdIdGen, // Keep as per your requirement
      "Id_Role": 0, // Set according to your role
      "fxd_usertype": 2, // Keep as per your requirement
      "id":prefs.getInt("u_id"),
      "smid": _selectFXIdSales, // Set according to your requirement
    };



    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"data":userData}),
      );

      if (response.statusCode == 201) {
        // Handle success
        final responseData = json.decode(response.body);
        print('User added successfully: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile Created Successfully'),
            backgroundColor: Colors.green, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
        Navigator.of(context).pop(); // Go back to previous screen or show success message
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed TO Create Profile'),
            backgroundColor: Colors.red, // Optional: Customize the color
            duration: Duration(seconds: 2), // Duration for the SnackBar
          ),
        );
        print('Failed to post data. Status codessssss: ${response.statusCode}');
        // Optionally handle the error
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed TO Create Profile'),
          backgroundColor: Colors.red, // Optional: Customize the color
          duration: Duration(seconds: 2), // Duration for the SnackBar
        ),
      );
      print('Errorssss: $e');
      // Optionally handle the exception
    }
  }

  Future<void> postSalesManData(int companyId, String regCode) async {
    final url = ApiConfig.reqSalesManList();

    // Create the request body
    final Map<String, dynamic> requestBody = {
      'companyid': companyId,
      'regcode': regCode,
    };

    print("request body ${requestBody}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        // Decode the response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Log the full response body for debugging
        print('Full response: ${response.body}');

        // Check if 'data' is a list
        if (jsonResponse['data'] is List) {
          List<SalesManModel> fetchedSalesMenList = (jsonResponse['data'] as List)
              .map((data) => SalesManModel.fromJson(data))
              .toList();

          // Update the state with the fetched list
          setState(() {
            salesmen = fetchedSalesMenList;
          });

          print('Successfully posted SalesMan data');
        } else {
          // Log unexpected format
          print('Unexpected data format: ${jsonResponse['data']}');
          print('Type of data: ${jsonResponse['data'].runtimeType}');
        }
      } else {
        print('Failed to post SalesMan data. Status code: ${response.statusCode}');
        print('Error response: ${response.body}');
      }
    } catch (e) {
      print('Error posting SalesMan data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
        backgroundColor: RiveAppTheme.background2,
      ),
      body: _isLoading
          ? Center(
        child: LoadingIndicator(), // Loader while loading
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black45,
                    width: 2.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.transparent,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (profilePic != null && profilePic!.isNotEmpty
                      ? NetworkImage(profilePic!)
                      : null),
                  child: Stack(
                    children: [
                      if (_profileImage == null &&
                          (profilePic == null || profilePic!.isEmpty))
                        Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.person, size: 40, color: Colors.black45),
                        ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey,
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, size: 15, color: Colors.black),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'User Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'User Password *',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: 'User Mobile *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter a mobile number' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<GenderOption>(
                decoration: InputDecoration(
                  labelText: 'Gender *',
                  border: OutlineInputBorder(),
                ),
                value: _selectedGenderOption,
                items: genderOptions.map((GenderOption genderOption) {
                  return DropdownMenuItem<GenderOption>(
                    value: genderOption,
                    child: Text(genderOption.title),
                  );
                }).toList(),
                onChanged: (GenderOption? newValue) {
                  setState(() {
                    _selectedGenderOption = newValue;
                    _selectedFxdIdGen = newValue?.fxdIdGen;
                    print(_selectedFxdIdGen);
                  });
                },
                validator: (value) => value == null ? 'Please select a gender' : null,
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date Of Birth',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(_dateOfBirth == null ? 'Select Date' : '${_dateOfBirth!.day}-${_dateOfBirth!.month}-${_dateOfBirth!.year}'),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date Of Marriage',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(_dateOfMarriage == null ? 'Select Date' : '${_dateOfMarriage!.day}-${_dateOfMarriage!.month}-${_dateOfMarriage!.year}'),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _welcomeNoteController,
                decoration: InputDecoration(
                  labelText: 'Welcome Note',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<SalesManModel>(
                decoration: InputDecoration(
                  labelText: 'Select Salesman *',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSalesman,
                items: salesmen.map((SalesManModel salesmanSelect) {
                  return DropdownMenuItem<SalesManModel>(
                    value: salesmanSelect,
                    child: Text(salesmanSelect.sman!,style: TextStyle(fontSize: 13),),
                  );
                }).toList(),
                onChanged: (SalesManModel? newValue) {
                  setState(() {
                    _selectedSalesman = newValue;
                    _selectFXIdSales = newValue?.smanid;
                    print(_selectFXIdSales);
                  });
                },
                validator: (value) => value == null ? 'Please select a gender' : null,
              ),


              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final userData = {
                          "user_name": _usernameController.text,
                          "password": _passwordController.text,
                          "mobile": _mobileController.text,
                          "email": _emailController.text,
                          "gender": _selectedGenderOption?.title, // Changed to title
                          "dob": _dateOfBirth?.toIso8601String(),
                          "marriage_date": _dateOfMarriage?.toIso8601String(),
                          "welcome_note": _welcomeNoteController.text,
                          "salesman": _selectedSalesman?.smanid, // Use the ID of the salesman
                          "profile_image": _profileImage?.path ?? '' // Handle null safely
                        };

                        // Call your API here with userData
                        uploadAndPostProfile();
                      }
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RiveAppTheme.background2,
                    ),
                  ),
                  SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RiveAppTheme.backgroundDark,
                      side: BorderSide(color: RiveAppTheme.background2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


}

class GenderOption {
  final int id;
  final String title;
  final int fxdIdGen;

  GenderOption({
    required this.id,
    required this.title,
    required this.fxdIdGen,
  });
}

// List of gender options
final List<GenderOption> genderOptions = [
  GenderOption(id: 1, title: 'Male', fxdIdGen: 600),
  GenderOption(id: 2, title: 'Female', fxdIdGen: 601),
  GenderOption(id: 3, title: 'Other', fxdIdGen: 602),
];