// lib/pages/help_page.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// The main page is now a StatelessWidget for better performance.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How to Use This App"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // We use our new, self-contained, and optimized widget here.
                child: const CustomVideoPlayer(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Video Controls Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tap the video to play/pause. Use the slider to seek.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Guide Section
            const Text(
              "Quick Guide",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            _buildGuideItem(
              context,
              Icons.people_outline,
              'Add Friends',
              'Go to the Friends tab and add your friends to split expenses with them.',
            ),
            const SizedBox(height: 12),
            
            _buildGuideItem(
              context,
              Icons.receipt_long_outlined,
              'Add Expenses',
              'Record expenses in the Expenses tab. Choose category and split with friends.',
            ),
            const SizedBox(height: 12),
            
            _buildGuideItem(
              context,
              Icons.pie_chart_outline,
              'Split Options',
              'Use equal split or custom split with sliders to divide expenses.',
            ),
            const SizedBox(height: 12),
            
            _buildGuideItem(
              context,
              Icons.edit_outlined,
              'Edit & Delete',
              'Tap the edit icon to modify or swipe left to delete expenses.',
            ),
            const SizedBox(height: 12),
            
            _buildGuideItem(
              context,
              Icons.analytics_outlined,
              'View Analytics',
              'Check the Analytics tab to track your spending and budget.',
            ),
            const SizedBox(height: 12),
            
            _buildGuideItem(
              context,
              Icons.summarize_outlined,
              'Summary',
              'See per-person totals and who owes whom in the Summary tab.',
            ),
            const SizedBox(height: 12),
            
            _buildGuideItem(
              context,
              Icons.light_mode_outlined,
              'Theme & Budget',
              'Switch between light/dark mode and set monthly budget from the menu.',
            ),
            
            const SizedBox(height: 24),
            
            // Tips Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Pro Tips',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Set a monthly budget to get notifications when exceeded\n'
                    '• Use custom split when expenses aren\'t equally divided\n'
                    '• Swipe left on any expense for quick delete\n'
                    '• Check Analytics regularly to track spending patterns',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the guide items
  Widget _buildGuideItem(BuildContext context, IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// A new, self-contained, and optimized video player widget
class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({super.key});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/video.mp4');
      await _controller.initialize();
      _controller.addListener(() {
        if (mounted) setState(() {});
      });
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
      debugPrint('Error initializing video: $e');
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const _VideoErrorWidget();
    }

    if (!_isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.grey.shade300,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // *** THIS IS THE FINAL, UNIVERSAL FIX ***
    // This logic checks if the video is wide or tall and displays it correctly.
    final bool isWide = _controller.value.aspectRatio > 1.1; // Check if video is horizontal

    return AspectRatio(
      // Use the video's own ratio if it's wide, otherwise use a standard 16:9 frame.
      aspectRatio: isWide ? _controller.value.aspectRatio : 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // If the video is wide, let it fill the frame.
            // If it's tall, use FittedBox to contain it with black bars.
            isWide
              ? VideoPlayer(_controller)
              : FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),

            // Controls Overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  color: Colors.transparent,
                  // The play button fades in and out
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(Icons.play_arrow, size: 50, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Controls Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                      onPressed: _togglePlayPause,
                    ),
                    Text(_formatDuration(_controller.value.position), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                          trackHeight: 2.0,
                        ),
                        child: Slider(
                          value: _controller.value.position.inSeconds.toDouble(),
                          min: 0,
                          max: _controller.value.duration.inSeconds.toDouble().clamp(0.0, double.infinity),
                          onChanged: (value) => _controller.seekTo(Duration(seconds: value.toInt())),
                          activeColor: Colors.white,
                          inactiveColor: Colors.white38,
                        ),
                      ),
                    ),
                    Text(_formatDuration(_controller.value.duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fullscreen feature coming soon!'))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

// Helper widget for a clean error state
class _VideoErrorWidget extends StatelessWidget {
  const _VideoErrorWidget();
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.white70),
            const SizedBox(height: 8),
            const Text('Unable to load video', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            const Text(
              'Check asset path in pubspec.yaml and code',
              style: TextStyle(fontSize: 12, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}