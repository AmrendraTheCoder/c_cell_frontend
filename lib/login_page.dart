import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_page/google_sign_in.dart';
import 'package:login_page/welcome_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final Uri emailUrl = Uri(
      scheme: 'mailto',
      path: 'c-cell.students@lnmiit.ac.in',
      query: Uri.encodeQueryComponent(
        'subject=Unable to Login into C-Cell App',
      )
  );




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 18, 25),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      'assets/images/Frame_dark.png',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/images/ccell_logo_dark.png',
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'WELCOME!',
                  style: GoogleFonts.lilitaOne(
                    fontSize: 30,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(45),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(45),
                      onTap: () {
                        signInWithCollegeGoogleAccount(context);
                      },
                      child: Image.asset(
                        'assets/images/google_logo.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text("Only use your College ID to Sign in",
                    style: GoogleFonts.inter(
                      color: Colors.white
                    )),
                SizedBox(height: 90),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 18, 25),
                    ),
                    onPressed: () { 
                      showDialog(context: context,
                          builder: (BuildContext context){
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.indigo,
                              width: 3
                            ),
                            borderRadius: BorderRadius.circular(45),
                          ),
                          title: Center(child: Text(
                              'Steps to Follow',
                              style: GoogleFonts.poppins(),
                          )),
                          content: DefaultTextStyle(
                            style: GoogleFonts.inter(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.arrow_forward_ios_rounded),
                                    SizedBox(width: 30),
                                    Text('Have you gotten your College Email-ID? \nTry signing in with that'),
                                  ],
                                ),
                                SizedBox(width: 30),
                                SizedBox(
                                  width: 200,
                                  child: Divider(
                                    thickness: 2,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 30),
                                Row(
                                  children: [
                                    Icon(Icons.arrow_forward_ios_rounded),
                                    SizedBox(width: 20),
                                    Text('Contact your nearest C-Cell Member'),
                                  ],
                                ),
                                SizedBox(width: 30),
                                SizedBox(
                                  width: 200,
                                  child: Divider(
                                    thickness: 2,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 30),
                                Row(
                                  children: [
                                    Icon(Icons.arrow_forward_ios_rounded),
                                    SizedBox(width: 20),
                                    TextButton(onPressed: () async {
                                      if (await canLaunchUrl(emailUrl)){
                                        await launchUrl(emailUrl);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Could Not Open Email-App, \nMail us as c-cell.students@lnmiit.ac.in'),
                                            )
                                        );
                                      }
                                    },
                                      child:
                                        Text('Email Us'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                          }
                      );
                    },
                    child: Text(
                      'Unable to Login?',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                    ),
                  ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



