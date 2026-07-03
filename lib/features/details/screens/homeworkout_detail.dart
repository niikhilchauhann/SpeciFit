import 'dart:async';
import 'package:flutter/material.dart';

class ExerciseDetails extends StatelessWidget {
  final String bodyPart;
  final String equipment;
  final String gifUrl;
  final String name;
  final String target;

  const ExerciseDetails({
    super.key,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.name,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.74,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.directions_run_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 6),
                Text(
                  'Target: $target',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 6),
                Text(
                  'Equipment: $equipment',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.accessibility_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 6),
                Text(
                  'Body Part: $bodyPart',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(8),
            //   child: CachedNetworkImage(imageUrl: gifUrl, fit: BoxFit.cover),
            // ),
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: WgerImageAnimator(imageUrls: gifUrl.split(',')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WgerImageAnimator extends StatefulWidget {
  final List<String> imageUrls;
  const WgerImageAnimator({super.key, required this.imageUrls});

  @override
  State<WgerImageAnimator> createState() => _WgerImageAnimatorState();
}

class _WgerImageAnimatorState extends State<WgerImageAnimator> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrls.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.imageUrls.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Image.network(
        widget.imageUrls[_currentIndex],
        key: ValueKey<String>(widget.imageUrls[_currentIndex]),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error, size: 50)),
      ),
    );
  }
}
