import 'package:flutter/material.dart';

class CommunityGuidelinesPage extends StatelessWidget {
  const CommunityGuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.green),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Community Guidelines',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Container(
                padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.lightGreen, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                     const SizedBox(height: 16),
            const Text(
              '1. Be respectful to others.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '2. Do not post hate speech or threats.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '3. No harassment or bullying.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '4. Do not share misleading or false information.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '5. Respect the privacy of others.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '6. No spam or irrelevant content.',
              style: TextStyle(fontSize: 16),
            ),
              const SizedBox(height: 8),
            const Text(
              '7. Your posts will be subject to review if reported.If found to be in violation of our guidelines, your post will be removed and your account may be suspended if necessary.',
              style: TextStyle(fontSize: 16),
            ),
              const SizedBox(height: 8),
            const Text(
              '8. You can view system notifications including any actions that may be taken against your post if necessary in the System Notices tab.',
              style: TextStyle(fontSize: 16),
            ),
             const SizedBox(height: 8),
            const Text(
              '9. To ensure real information reaches the community, upvote or downvote posts based on their relevance and accuracy.',
              style: TextStyle(fontSize: 16),
            ),
             const SizedBox(height: 8),
            const Text(
              '10. Notices are sorted on basis of relevance and accuracy. The most relevant and accurate notices will be shown first.',
              style: TextStyle(fontSize: 16),
            ),

                ],
              ),
            ),
          
            // Add more guidelines here
          ],
        ),
      ),
    );
  }
}