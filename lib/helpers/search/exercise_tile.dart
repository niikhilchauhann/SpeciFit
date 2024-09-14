import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/details/homeworkout_detail.dart';

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    super.key,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.name,
    required this.target,
  });

  final dynamic bodyPart;
  final dynamic equipment;
  final dynamic gifUrl;
  final dynamic name;
  final dynamic target;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showCupertinoModalPopup(
          barrierColor: Colors.black54,
          context: context,
          builder: (context) => ExerciseDetails(
            bodyPart: bodyPart,
            equipment: equipment,
            gifUrl: gifUrl,
            name: name,
            target: target,
          ),
        );
      },
      leading: Container(
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(gifUrl),
          ),
        ),
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Row(
        children: [
          Text('$bodyPart • ', style: Theme.of(context).textTheme.labelLarge),
          Text(equipment, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
    );
  }
}
