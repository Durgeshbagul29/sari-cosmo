import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How do I enroll in a course?',
      'answer': 'Browse our Courses section, select a course, and tap "Enroll Now". For paid courses, complete the payment to get instant access. Free courses can be enrolled immediately.',
    },
    {
      'question': 'How can I track my order?',
      'answer': 'Go to My Profile → My Orders. Each order shows its current status (Processing, Shipped, Delivered). Tap "Track" on shipped orders for real-time location tracking.',
    },
    {
      'question': 'Can I reschedule an appointment?',
      'answer': 'Yes! Go to My Appointments and tap "Reschedule" on any upcoming appointment. You can reschedule up to 2 hours before the scheduled time at no extra charge.',
    },

    {
      'question': 'What is the return policy?',
      'answer': 'We offer a 7-day return policy for unopened products. Courses have a 3-day money-back guarantee if less than 10% of content has been accessed. Contact support for returns.',
    },
    {
      'question': 'How do I get a certificate?',
      'answer': 'Complete 100% of the course content and pass the final assessment. Your certificate will be automatically generated and available in My Courses → Certificates.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          _buildContactOptions(context),
          const SizedBox(height: 24),
          _buildFAQ(context),
          const SizedBox(height: 24),
          _buildMoreHelp(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContactOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _contactCard(Icons.chat_bubble_outline_rounded, 'Live Chat', 'Chat with us', AppTheme.primary, () {})),
            const SizedBox(width: 12),
            Expanded(child: _contactCard(Icons.email_outlined, 'Email', 'support@iictn.com', const Color(0xFF2980B9), () {})),
            const SizedBox(width: 12),
            Expanded(child: _contactCard(Icons.phone_outlined, 'Call', '+91 98765 43210', AppTheme.success, () {})),
          ],
        ),
      ],
    );
  }

  Widget _contactCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQ(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: _faqItems.map((faq) => Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.help_outline_rounded, color: AppTheme.primary, size: 18),
                ),
                title: Text(
                  faq['question'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
                children: [
                  Text(
                    faq['answer'],
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.6),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreHelp(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent_rounded, size: 40, color: AppTheme.primary),
          const SizedBox(height: 12),
          const Text(
            'Still need help?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'Our support team is available\nMon-Sat, 9 AM - 7 PM IST',
            style: TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.headset_mic_outlined, size: 18),
              label: const Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
