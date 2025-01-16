// lib/pages/privacy_policy_page.dart
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        'Introduction',
                        'This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our Smart Home application.',
                      ),
                      _buildSection(
                        'Information Collection',
                        'We collect information that you provide directly to us, including but not limited to:\n\n'
                            '• Account information (name, email, password)\n'
                            '• Device information and settings\n'
                            '• Usage data and preferences\n'
                            '• Location data (with your permission)',
                      ),
                      _buildSection(
                        'Use of Information',
                        'We use the collected information for various purposes:\n\n'
                            '• Providing and maintaining our services\n'
                            '• Personalizing your experience\n'
                            '• Improving our application\n'
                            '• Communicating with you\n'
                            '• Ensuring security and preventing fraud',
                      ),
                      _buildSection(
                        'Data Security',
                        'We implement appropriate technical and organizational security measures to protect your information. However, no electronic transmission or storage system is 100% secure.',
                      ),
                      _buildSection(
                        'Third-Party Services',
                        'Our application may contain links to third-party websites or services. We are not responsible for their privacy practices or content.',
                      ),
                      _buildSection(
                        'Updates to Policy',
                        'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.',
                      ),
                      _buildSection(
                        'Contact Us',
                        'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                            'Email: KOI@smarthome.com\n'
                            'Phone: +1 (555) 123-4567',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
