import 'dart:convert';
import 'package:distributers_app/components/LoadingIndicator.dart';
import 'package:distributers_app/view/signIn.dart';
import 'package:distributers_app/view/signUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../services/api_services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  late AnimationController _usernameControllerAnimation;
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _passwordControllerAnimation;
  bool _showOtpFields = false; // Track whether to show OTP fields
  String _buttonText = 'SEND'; // Button text
  List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _usernameControllerAnimation = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _passwordControllerAnimation = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _usernameControllerAnimation.dispose();
    _usernameController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  String getOtp() {
    // Combine the OTP values from all controllers
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _submitForgotPassword() async {

    setState(() {
      _isLoading = true;
    });

    final String apiUrl = ApiConfig.postForgotPassword(); // Get the full URL from ApiConfig
    final url = Uri.parse(apiUrl);
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'code': _usernameController.text, // The "code" field in the body
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Handle success, e.g., show a confirmation message
        print('OTP has been sent to your mobile number!');
        print(response.body);
        _showMessage('OTP has been sent to your mobile number!');
        setState(() {
          _showOtpFields = true;
          _buttonText = 'Submit';
        });
      } else {
        // Handle failure
        print('Failed to send password reset link. Status code: ${response.statusCode}');
        _showMessage('Failed to send Otp. Please Check Username.');
      }
    } catch (e) {
      print('Errorssssssssssssss: $e');
      _showMessage('An error occurred. Please check your network and try again.');
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isLoading = true;
    });
    final String apiUrl = ApiConfig.postVerifyOtp(); // Get the full URL from ApiConfig
    final url = Uri.parse(apiUrl);
    final headers = {
      'Content-Type': 'application/json',
    };
    print(_usernameController.text);
    print(otp);
    final body = jsonEncode({
      'code': _usernameController.text, // The "code" field in the body
      'otp': otp
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Handle success, e.g., show a confirmation message
        print(response.body);
        _showMessage('Otp Verified Successfully ');
        _showResetPasswordDialog();
      } else {
        // Handle failure
        print('Failed to send password reset link. Status code: ${response.statusCode}');
        _showMessage('Failed to send password reset link. Please try again.');
      }
    } catch (e) {
      print('Error: $e');
      _showMessage('An error occurred. Please check your network and try again.');
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });
    final String apiUrl = ApiConfig.resetPassword(); // Get the full URL from ApiConfig
    final url = Uri.parse(apiUrl);
    final headers = {
      'Content-Type': 'application/json',
    };
    print(_usernameController.text);
    final body = jsonEncode({
      "status":0, // if login 1 else 0
      'code': _usernameController.text, // The "code" field in the body
      'password': _passwordController.text
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Handle success, e.g., show a confirmation message
        print(response.body);
        _showMessage('Password Reset Successfully');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      } else {
        // Handle failure
        print('Failed to send password reset link. Status code: ${response.statusCode}');
        _showMessage('Failed to send password reset link. Please try again.');
      }
    } catch (e) {
      print('Error: $e');
      _showMessage('An error occurred. Please check your network and try again.');
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF199A8E), // Set the background color here
        behavior: SnackBarBehavior.floating, // Optional: makes it float above other content
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Forgot Password',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SignIn()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              margin: const EdgeInsets.only(top: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Username TextFormField
                    _buildShakableTextFormField(
                      'Username',
                      null,
                      _usernameControllerAnimation,
                      keyboardType: TextInputType.emailAddress,
                      textController: _usernameController,
                      prefixIcon: Icon(Icons.person),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),

                    // Conditionally display OTP fields and top margin
                    if (_showOtpFields) ...[
                      SizedBox(height: 30), // Add top margin before OTP fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45, // Adjust width for each box
                            child: TextFormField(
                              controller: _otpControllers[index],
                              onChanged: (value) {
                                if (value.length == 1 && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: "",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(11),
                                  borderSide: BorderSide(
                                    color: Color(0xFF199A8E),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                    SizedBox(height: 30),

                    // Send/Submit Button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (!_showOtpFields) {
                            _submitForgotPassword();
                          } else {
                            String otp = getOtp();
                            _verifyOtp(otp);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF199A8E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        minimumSize: Size(350, 55),
                      ),
                      child: Text(
                        _buttonText,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Display loading animation if _isLoading is true
          if (_isLoading)
            Center(
              child: LoadingIndicator()
            ),
        ],
      ),
    );
  }



// Function to show the Reset Password dialog
  void _showResetPasswordDialog() {
    bool _obscurePassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.85, // Set dialog width
              child: AlertDialog(
                backgroundColor: Colors.grey[200], // Set background color to grey
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                title: Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 17, // Adjust title size
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Password input field
                      _buildShakablePassField(
                        'New Password',
                        null,
                        _passwordControllerAnimation,
                        obscureText: _obscurePassword, // Toggle password visibility
                        textController: _passwordController, // Use a new TextEditingController for the password
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            // Use the StateSetter to toggle the state within the dialog
                            setState(() {
                              _obscurePassword = !_obscurePassword; // Toggle password visibility
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Handle password reset logic here
                        _resetPassword();

                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF199A8E), // Same button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildShakablePassField(
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

            },
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
        required TextEditingController textController,
        required Widget prefixIcon,
        String? Function(String?)? validator,
        bool obscureText = false,
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
              prefixIcon: prefixIcon,
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
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }
}


