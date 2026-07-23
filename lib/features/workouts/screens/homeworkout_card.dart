import '/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class HomeworkoutCard extends StatelessWidget {
  const HomeworkoutCard({
    super.key,
    required this.width,
    required this.image,
    required this.cardColor,
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.time,
  });

  final double width;
  final String image;
  final String title;
  final String calories;
  final String time;
  final String subtitle;
  final dynamic cardColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[4],
            color: cardColor,
            borderRadius: BorderRadius.circular(35),
          ),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Image(width: width, image: AssetImage(image)),
          ),
        ),
        Positioned(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 0, 5),
            width: width / 1.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xff2b2b2b),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.instance.label.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white60,
                        ),
                        child: Center(
                          child: Text(
                            "🔥 $calories kcal",
                            style: AppTextStyles.instance.labelSmall,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white60,
                        ),
                        child: Center(
                          child: Text(
                            "▶ $time min",
                            style: AppTextStyles.instance.labelSmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
