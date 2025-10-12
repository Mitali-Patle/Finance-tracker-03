// lib/pages/help_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  // Replace this with your actual video URL (YouTube or hosted mp4).
  static const String tutorialUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
  static const String thumbnailUrl = 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("How to Use This App")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // thumbnail + play button overlay
            GestureDetector(
              onTap: () async {
                // copy link to clipboard and show SnackBar
                await Clipboard.setData(const ClipboardData(text: tutorialUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video link copied to clipboard. Paste into a browser to watch.')),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(child: Icon(Icons.play_circle_outline, size: 64)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.play_arrow, size: 48, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap the thumbnail to copy the tutorial link. Then paste it in your browser to watch the walkthrough.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(const ClipboardData(text: tutorialUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Video link copied to clipboard.')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Link'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // show the link so user can open it manually
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Open tutorial'),
                        content: SelectableText(tutorialUrl),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show Link'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Quick guide",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '''
• Add friends in the Friends tab.  
• Record expenses in the Expenses tab. Use "Add" to create a new expense.  
• Choose category, split equally or choose custom split and sliders.  
• Edit an expense by tapping the edit icon next to it.  
• View analytics to track budget and trends.  
• Summary tab shows per-person totals from recorded splits.  
• Switch Light/Dark mode from the AppBar.  
• Set monthly budget (AppBar menu) and get a notification when exceeded.
''',
              style: TextStyle(fontSize: 15, height: 1.45),
            ),
            const SizedBox(height: 18),
            const Text(
              'Notes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you prefer in-app playback, add the `video_player` package to pubspec.yml and replace this thumbnail with a VideoPlayerController-based player. If you want a quick open-in-browser action, add `url_launcher` and call launchUrl on the link.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
