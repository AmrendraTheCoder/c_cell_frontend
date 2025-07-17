import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login_page/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checklist.dart';

class AntiRaggingScreen extends StatefulWidget {
  const AntiRaggingScreen({super.key});

  @override
  State<AntiRaggingScreen> createState() => _AntiRaggingScreenState();
}

class _AntiRaggingScreenState extends State<AntiRaggingScreen> {
  bool allDone = false;
  bool isDone = false;

  @override
  void initState() {
    super.initState();
    _loadDoneStatus();
    _checkAllDone();
  }

  Future<void> _loadDoneStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDone = prefs.getBool('anti_ragging_done') ?? false;
    });
  }

  Future<void> _checkAllDone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      allDone = (prefs.getBool('hostel_registration_done') ?? false) &&
          (prefs.getBool('document_verification_done') ?? false) &&
          (prefs.getBool('biometric_done') ?? false) &&
          (prefs.getBool('credential_collection_done') ?? false) &&
          (prefs.getBool('anti_ragging_done') ?? false);
    });
  }

  static const String antiRaggingLocation = 'Admin Office, Room 101, LNM Institute, Jaipur';
  static const String description = "1. Fill anti-ragging form.\n2. Collect student ID card at Admin Office, Room 101.";

  Future<void> _launchMapUrl(BuildContext context) async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(antiRaggingLocation)}';
    final Uri url = Uri.parse(googleMapsUrl);
    if (!await launchUrl(url)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open map for Admin Office.')),
      );
    }
  }

  Future<void> _setDone(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('anti_ragging_done', value);
    if (!mounted) return;
    setState(() {
      isDone = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value ? 'Marked as done!' : 'Marked as not done!')),
    );
    _checkAllDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001219),
      appBar: AppBar(
        title: const Text('Final Step – Anti-Ragging Form & ID'),
        backgroundColor: const Color(0xFF001219),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Illustration
            Image.asset(
              'assets/antirag.png',
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.assignment_turned_in, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 32),
            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 40),
            // "Get Directions" Button for Admin Office
            ElevatedButton.icon(
              onPressed: () => _launchMapUrl(context),
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text(
                'Get Directions (Admin Office)',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF0077B6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // "Mark as Done/Not Done" Button
            ElevatedButton.icon(
              onPressed: () => _setDone(!isDone),
              icon: Icon(
                isDone ? Icons.cancel : Icons.check_circle,
                color: Colors.white,
              ),
              label: Text(
                isDone ? 'Mark as Not Done' : 'Mark as Done',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 32), // Add space above the bottom button
            // Show different button based on checklist status
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (allDone) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ChecklistScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: allDone ? const Color(0xFF48CAE4) : Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  allDone
                      ? 'Finish & Proceed to Login'
                      : 'Back to Checklist',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}