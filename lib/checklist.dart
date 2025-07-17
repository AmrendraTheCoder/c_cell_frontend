import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'hostel_registration.dart';
import 'document_verification.dart';
import 'implocations.dart';
import 'biometric_screen.dart';
import 'credential_collection.dart';
import 'anti_ragging.dart';
import 'login_page.dart';
import 'welcome_screen.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen>
    with TickerProviderStateMixin {
  final List<_ChecklistStep> steps = [
    _ChecklistStep(
      title: 'Hostel Registration',
      description: 'Register for hostel accommodation and room allocation',
      icon: Icons.home_rounded,
      route: HostelRegistrationScreen(),
      keyName: 'hostel_registration_done',
      color: const Color(0xFF3B82F6),
    ),
    _ChecklistStep(
      title: 'Document Verification',
      description: 'Submit and verify your academic documents',
      icon: Icons.assignment_rounded,
      route: DocumentVerificationScreen(),
      keyName: 'document_verification_done',
      color: const Color(0xFF10B981),
    ),
    _ChecklistStep(
      title: 'Biometric Registration',
      description: 'Complete biometric data registration for ID card',
      icon: Icons.fingerprint_rounded,
      route: BiometricScreen(),
      keyName: 'biometric_done',
      color: const Color(0xFFEC4899),
    ),
    _ChecklistStep(
      title: 'Credential Collection',
      description: 'Collect your student ID card and login credentials',
      icon: Icons.badge_rounded,
      route: CredentialCollectionScreen(),
      keyName: 'credential_collection_done',
      color: const Color(0xFFF59E0B),
    ),
    _ChecklistStep(
      title: 'Anti Ragging Declaration',
      description: 'Sign the mandatory anti-ragging declaration form',
      icon: Icons.security_rounded,
      route: AntiRaggingScreen(),
      keyName: 'anti_ragging_done',
      color: const Color(0xFF8B5CF6),
    ),
  ];

  late List<bool> _done;
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late List<AnimationController> _itemControllers;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _done = List.filled(steps.length, false);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _itemControllers = List.generate(
      steps.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _loadChecklist();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < steps.length; i++) {
        _done[i] = prefs.getBool(steps[i].keyName) ?? false;
      }
    });
    
    _updateProgress();
    _animateItems();
  }

  void _updateProgress() {
    final completedCount = _done.where((done) => done).length;
    final targetProgress = completedCount / steps.length;
    
    _progressController.animateTo(targetProgress);
  }

  void _animateItems() {
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + (i * 150)), () {
        if (mounted) {
          _itemControllers[i].forward();
        }
      });
    }
  }

  Future<void> _setDone(int index, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(steps[index].keyName, value);
    setState(() {
      _done[index] = value;
    });
    _updateProgress();
  }

  void _navigateToStep(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => steps[index].route),
    );
    _loadChecklist();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 768 && size.width < 1024;
    final allDone = _done.every((element) => element);
    final completedCount = _done.where((done) => done).length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(isDesktop, completedCount),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 48 : (isTablet ? 32 : 20),
                    vertical: 24,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProgressSection(isDesktop, completedCount),
                      const SizedBox(height: 32),
                      _buildInstructions(isDesktop),
                      const SizedBox(height: 32),
                      _buildChecklistItems(isDesktop, isTablet),
                      const SizedBox(height: 32),
                      _buildActionButtons(isDesktop, allDone),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDesktop, int completedCount) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        ),
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Student Onboarding',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 22 : 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            '$completedCount of ${steps.length} completed',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(bool isDesktop, int completedCount) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFF7C3AED).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Overview',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Complete all steps to access full student features',
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 14 : 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop) ...[
                Text(
                  '${((completedCount / steps.length) * 100).round()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completion Progress',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$completedCount / ${steps.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 8,
                  color: Colors.white.withOpacity(0.1),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF8B5CF6),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E40AF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tap on each step below to complete your registration process. You can mark steps as complete and track your progress.',
              style: GoogleFonts.inter(
                fontSize: isDesktop ? 14 : 13,
                color: const Color(0xFF3B82F6),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItems(bool isDesktop, bool isTablet) {
    return Column(
      children: List.generate(steps.length, (index) {
        return AnimatedBuilder(
          animation: _itemControllers[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _itemControllers[index].value)),
              child: Opacity(
                opacity: _itemControllers[index].value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildChecklistItem(index, isDesktop),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildChecklistItem(int index, bool isDesktop) {
    final step = steps[index];
    final isCompleted = _done[index];

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _navigateToStep(index),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 24 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCompleted
                  ? [
                      step.color.withOpacity(0.15),
                      step.color.withOpacity(0.08),
                    ]
                  : [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? step.color.withOpacity(0.4)
                  : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? LinearGradient(colors: [step.color, step.color.withOpacity(0.8)])
                      : LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : step.icon,
                  color: isCompleted ? Colors.white : Colors.white60,
                  size: isDesktop ? 24 : 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? step.color : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 14 : 12,
                        color: isCompleted
                            ? step.color.withOpacity(0.8)
                            : Colors.white60,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () => _setDone(index, !isCompleted),
                    icon: Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isCompleted ? step.color : Colors.white30,
                      size: isDesktop ? 28 : 24,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white30,
                    size: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDesktop, bool allDone) {
    return Column(
      children: [
        if (allDone) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 24 : 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Congratulations!',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have completed all onboarding steps. You can now sign in with your student account.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 14 : 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Proceed to Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 24,
                      vertical: isDesktop ? 16 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ImplocationsScreen()),
                );
              },
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Skip & Explore Campus'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white30),
                padding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChecklistStep {
  final String title;
  final String description;
  final IconData icon;
  final Widget route;
  final String keyName;
  final Color color;

  _ChecklistStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.keyName,
    required this.color,
  });
}
