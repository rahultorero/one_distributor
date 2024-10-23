import 'package:distributers_app/view/signIn.dart';
import 'package:distributers_app/view/signUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg package

class MainScreens extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Medics Logo
                SvgPicture.asset(
                  'assets/images/main_icon.svg', // Path to your SVG asset
                  height: 100, // Adjust the height as needed
                ),
                SizedBox(height: 30),

                // Title
                Text(
                  "Let’s get started!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 8),

                // Subtitle
                Text(
                  "Login to enjoy the features we’ve provided, and stay healthy!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 45),

                // Login Button
                SizedBox(
                  width: 325,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn(),),);
                      // Add your login navigation here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF199A8E), // Green color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 17,
                      color: Colors.white),

                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Sign Up Button
                SizedBox(
                  width: 325,
                  height: 65,
                  child: OutlinedButton(
                    onPressed: () {
                      // Add your sign-up navigation here
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen(),),);

                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF199A8E)), // Green border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF199A8E), // Green color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


