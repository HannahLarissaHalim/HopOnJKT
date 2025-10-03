import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ"),
        backgroundColor: const Color(0xFF1A3C6E),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          FAQItem(
            question: "How do I buy a ticket?",
            answer: "To buy a ticket, go to the Home screen, select your departure and arrival stations, then tap 'Show Ticket'. Choose your preferred route and tap 'Buy Ticket'. You'll need to enter your 6-digit PIN to complete the purchase.",
          ),
          FAQItem(
            question: "How do I get points?",
            answer: "You can get points by topping up through the Points page. Go to your Profile, tap on 'My Points', and select the top-up option. Points are used to purchase tickets.",
          ),
          FAQItem(
            question: "Can I cancel my ticket?",
            answer: "Yes, you can cancel active tickets. Go to 'My Orders' tab, find your active ticket, and tap the cancel button. Please note that cancellation policies may apply.",
          ),
          FAQItem(
            question: "Where can I see my ticket history?",
            answer: "Go to the 'My Orders' screen (ticket icon in bottom navigation), then switch to the 'History' tab to see all your past tickets including cancelled and expired ones.",
          ),
          FAQItem(
            question: "How do I reset my password or PIN?",
            answer: "To reset your password, use the 'Forgot Password' option on the login screen. To change your PIN, go to Profile > Change PIN. You'll need to verify your current PIN before setting a new one.",
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A3C6E),
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF1A3C6E),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
