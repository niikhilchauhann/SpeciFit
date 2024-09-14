import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../utilities/export.dart';

class ExerciseCard extends StatelessWidget {
  final String exerciseImage;

  final String exerciseName;

  const ExerciseCard(
      {Key? key, required this.exerciseImage, required this.exerciseName})
      : super(key: key);

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
                  style: medium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
