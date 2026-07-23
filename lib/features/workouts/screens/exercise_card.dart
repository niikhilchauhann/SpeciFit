import '/core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ExerciseCard extends StatelessWidget {
  final String exerciseImage;

  final String exerciseName;

  const ExerciseCard({
    super.key,
    required this.exerciseImage,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(exerciseImage),
          ),
        ),
        width: 200,
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            Positioned(
              bottom: 10,
              left: 12,
              child: SizedBox(
                width: 138,
                child: Text(
                  exerciseName,
                  style: AppTextStyles.instance.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
