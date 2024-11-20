import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:distributers_app/dataModels/LoginModel.dart';
import 'package:distributers_app/view/forgetPass.dart';
import 'package:distributers_app/view/home.dart';
import 'package:distributers_app/view/signUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // Import http package

import '../dataModels/LoginResponse.dart';
import '../services/api_services.dart';
import 'mainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _emailControllerAnimation;
  late AnimationController _passwordControllerAnimation;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _emailControllerAnimation = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _passwordControllerAnimation = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
     String? savedUsername = prefs.getString('username');
      String? savedPassword = prefs.getString('password');

      if (savedUsername != null && savedPassword != null) {
        _emailController.text = savedUsername;
        _passwordController.text = savedPassword;

    }
  }

  @override
  void dispose() {
    _emailControllerAnimation.dispose();
    _passwordControllerAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView( // Make the content scrollable
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          margin: const EdgeInsets.only(top: 50.0), // Add margin here
          child: Form(
            key: _formKey, // Add Form widget with GlobalKey
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Title
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30),

                // Email TextFormField
                // Username TextFormField
                _buildShakableTextFormField(
                  'Username',
                  null,
                  _emailControllerAnimation,
                  keyboardType: TextInputType.emailAddress,
                  textController: _emailController,
                  prefixIcon: Icon(Icons.person), // Add icon here
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),


// Password TextFormField
                _buildShakableTextFormField(
                  'Password',
                  null,
                  _passwordControllerAnimation,
                  obscureText: _obscurePassword, // Use the state variable here
                  textController: _passwordController,
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ), // Add the toggle icon here
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 3) {
                      return 'Password must be at least 4 characters long';
                    }
                    return null;
                  },
                ),
                _buildRememberMeCheckbox(), // Add Remember Me checkbox
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Add forgot password functionality
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color(0xFF199A8E), fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Form is valid, proceed with login functionality
                      _login();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF199A8E), // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    minimumSize: Size(350, 55), // Full width button
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),

                // Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Don’t have an account?',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Color(0xFF199A8E), fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    final prefs = await SharedPreferences.getInstance();

    final String apiUrl = ApiConfig.postLogin(); // Get the full URL from ApiConfig
    final url = Uri.parse(apiUrl); // Replace with your API endpoint

    final authRequest = UserModel(
      user_name: _emailController.text,
      pwd: _passwordController.text,
    );

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(authRequest.toJson()),
      );

      // Print the raw response body
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response using LoginResponse model
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        print(loginResponse.message);

        if (loginResponse.statusCode == 200) {
          print('Login successful: ${loginResponse.data?.user}');
          print('Token: ${loginResponse.data?.token}');

          // Save login credentials and status if "Remember Me" is checked
          if (_rememberMe) {
            await prefs.setString('username', _emailController.text);
            await prefs.setString('password', _passwordController.text);
          }

          await prefs.setString('user', loginResponse.data!.user.toString());
          await prefs.setString('division', loginResponse.data!.division.toString());
          await prefs.setString('reg_code', loginResponse.data!.uNo.toString());
          await prefs.setInt('u_id', loginResponse.data!.userId!);
          await prefs.setInt('companyId', loginResponse.data!.companyId!);
          await prefs.setInt('smid', loginResponse.data!.smid!);

          // Save the login status
          await prefs.setBool('isLoggedIn', true);

          // Show success dialog
          AwesomeDialog(
            context: context,
            animType: AnimType.topSlide,
            headerAnimationLoop: true,
            dialogType: DialogType.success,
            showCloseIcon: false,
            title: 'Success',
            desc: 'Login Successfully',
            btnOkOnPress: () {
              debugPrint('Dialog button clicked');
              // Navigate to home screen on success
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Home()),
                    (Route<dynamic> route) => false,
              );

            },
            btnOkIcon: Icons.check_circle,
          ).show();
        } else {
          // Handle invalid credentials case
          AwesomeDialog(
            context: context,
            animType: AnimType.topSlide,
            headerAnimationLoop: true,
            dialogType: DialogType.error,
            showCloseIcon: false,
            title: 'Failure',
            desc: 'Invalid Credentials',
            btnOkOnPress: () {
              debugPrint('Dialog button clicked');
            },
            btnOkIcon: Icons.error,
          ).show();
        }

      } else {
        print('Failed to login. Status code: ${response.statusCode}');
        // Show error dialog for invalid credentials
        AwesomeDialog(
          context: context,
          animType: AnimType.topSlide,
          headerAnimationLoop: true,
          dialogType: DialogType.error,
          showCloseIcon: false,
          title: 'Error',
          desc: 'Invalid Credentials',
          btnOkOnPress: () {
            debugPrint('Dialog button clicked');
          },
          btnOkIcon: Icons.error,
        ).show();
      }
    } catch (e) {
      print('Error: $e');
      // Handle network or parsing error
      AwesomeDialog(
        context: context,
        animType: AnimType.topSlide,
        headerAnimationLoop: true,
        dialogType: DialogType.error,
        showCloseIcon: false,
        title: 'Error',
        desc: 'Something went wrong. Please try again later',
        btnOkOnPress: () {
          debugPrint('Dialog button clicked');
        },
        btnOkIcon: Icons.error,
      ).show();
    }
  }

  Widget _buildRememberMeCheckbox() {
    return CheckboxListTile(
      title: Text("Remember Me"),
      value: _rememberMe,
      onChanged: (bool? value) {
        setState(() {
          _rememberMe = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }


  Widget _buildShakableTextFormField(
      String labelText,
      String? errorText,
      AnimationController controller, {
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        required TextEditingController textController,
        String? Function(String?)? validator,
        bool obscureText = false,
        Widget? prefixIcon, // Add prefixIcon parameter
        Widget? suffixIcon, // Add suffixIcon parameter
      }) {
    return ShakeAnimation(
      controller: controller,
      child: Center(
        child: SizedBox(
          width: 330,
          child: TextFormField(
            controller: textController,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
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
                borderRadius: BorderRadius.circular(30),
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
              prefixIcon: prefixIcon, // Set prefixIcon
              suffixIcon: suffixIcon, // Set suffixIcon
            ),
            validator: validator,
            onChanged: (value) {
              _validateField(labelText, value, controller);
            },
          ),
        ),
      ),
    );
  }




  void _validateField(String labelText, String value, AnimationController controller) {
    if (value.isEmpty) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }
}
