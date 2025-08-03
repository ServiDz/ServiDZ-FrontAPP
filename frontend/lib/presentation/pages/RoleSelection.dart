import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  void _selectRole(BuildContext context, String role) {
    Navigator.pushNamed(context, 'login', arguments: role);
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.5; // For smoother animations

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo with subtle animation
                _buildAnimatedLogo(),
                const SizedBox(height: 40),

                // Welcome section
                _buildWelcomeSection(),
                const SizedBox(height: 40),

                // Role selection cards
                _buildRoleCards(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              children: [
                Hero(
                  tag: 'app-logo',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        // BoxShadow(
                        //   color: Colors.blue[800]!.withOpacity(0.1),
                        //   blurRadius: 20,
                        //   spreadRadius: 5,
                        // ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'images/logo.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Text(
          'Welcome to ServiDz',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
            children: const [
              TextSpan(
                text: 'All home & office services in one simple app\n',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: 'Fast, safe, and reliable!',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCards(BuildContext context) {
    return Column(
      children: [
        // Looking for Service Provider card
        _buildRoleCard(
          context: context,
          role: 'user',
          title: 'Find a Service',
          subtitle: 'Get your tasks done by professionals',
          icon: Icons.search_rounded,
          bgColor: Colors.blue[50]!, // Light blue background
          textColor: Colors.blue[800]!,
          borderColor: Colors.blue[200]!,
        ),
        const SizedBox(height: 20),
        
        // I am a Service Provider card
        _buildRoleCard(
          context: context,
          role: 'tasker',
          title: 'Offer Services',
          subtitle: 'Connect with clients and grow your business',
          icon: Icons.work_outline_rounded,
          bgColor: Colors.blue[800]!, // Dark blue background
          textColor: Colors.white,
          borderColor: Colors.blue[800]!,
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _selectRole(context, role),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: textColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}