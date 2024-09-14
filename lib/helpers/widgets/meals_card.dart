import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../utilities/export.dart';

class SmallRecipeCard extends StatelessWidget {
  final String image;
  final String name;
  final String kcal;
  final dynamic score;
  final dynamic ontap;
  final dynamic addmeal;
  const SmallRecipeCard({
    Key? key,
    required this.image,
    required this.name,
    required this.kcal,
    required this.score,
    required this.ontap,
    required this.addmeal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: ontap,
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0xffF8FAFB),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                boxShadow: kElevationToShadow[3]),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, bottom: 15, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                          style: h2black,
                        ),
                        const SizedBox(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              kcal,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: hNormal,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: primary,
                                  size: 20,
                                ),
                                Text(
                                  " $score",
                                  textAlign: TextAlign.left,
                                  style: hNormal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 135,
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFB),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(image)),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: addmeal,
            child: Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: bgcolor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
