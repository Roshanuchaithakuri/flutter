// lib/pages/terms_conditions_page.dart
import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

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
                      _buildTextSection('Terms and Conditions',
                          'By downloading or using the app, these terms will automatically apply to you. Please read them carefully before using the application.'),
                      _buildTextSection('App Usage License',
                          'Smart Home grants you a revocable, non-exclusive, non-transferable, limited license to download, install, and use the app strictly in accordance with these terms.'),
                      _buildTextSection(
                          'Content Restrictions',
                          '• Modify, disassemble, decompile or reverse engineer the application\n'
                              '• Remove, circumvent, disable, damage or otherwise interfere with security features\n'
                              '• Use the application for any unlawful purpose or in violation of any laws\n'
                              '• Share your account credentials with any other person'),
                      _buildTextSection('Account Responsibilities',
                          'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.'),
                      _buildTextSection('Service Modifications',
                          'We reserve the right to modify or withdraw the application temporarily or permanently. We may change these terms and conditions at any time. Changes to the subscription fees will be notified in advance.'),
                      _buildTextSection('Technical Requirements',
                          'The app requires a device with internet access and appropriate software. You are responsible for arranging access to these requirements.'),
                      _buildTextSection('Intellectual Property',
                          'The application and its original content, features, and functionality are owned by Smart Home and are protected by international copyright, trademark, and other intellectual property laws.'),
                      _buildTextSection('Termination',
                          'We may terminate or suspend your access to the app immediately, without prior notice, for conduct that we believe violates these Terms and Conditions.'),
                      _buildTextSection(
                          'Contact Information',
                          'If you have any questions about these Terms and Conditions, please contact us:\n\n'
                              'Email: KOI@smarthome.com\n'
                              'Phone: +1 (555) 123-4567'),
                      const SizedBox(height: 24),
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
            'Terms & Conditions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection(String title, String content) {
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
