import 'package:flutter/material.dart';
import 'package:flutter_auth/pages/login_page.dart';
import 'package:flutter_auth/pages/sign_up_page.dart';
import 'package:flutter_auth/theme.dart';

class LoginAndSignup extends StatefulWidget {
  const LoginAndSignup({super.key});

  @override
  State<LoginAndSignup> createState() => _LoginAndSignupState();
}

class _LoginAndSignupState extends State<LoginAndSignup> {
  bool isLogin = true;

  void togglePage() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome Header
          Column(
            children: [
              Text(
                isLogin ? 'Welcome Back!' : 'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 10),
              Text(
                isLogin 
                    ? 'Sign in to continue your collaboration journey'
                    : 'Join ProjectConnect to start connecting',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: 40),
          
          // Login/Signup Form
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: isLogin
                  ? LoginPage(showSignupPage: togglePage)
                  : SignUp(showLoginPage: togglePage),
            ),
          ),
          
          // Toggle Button
          Container(
            margin: EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin ? "Don't have an account? " : "Already have an account? ",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
                GestureDetector(
                  onTap: togglePage,
                  child: Text(
                    isLogin ? 'Sign Up' : 'Login',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}