import 'package:flutter/material.dart';
import 'package:specifit/utilities/export.dart';

class RunnerWidget extends StatelessWidget {
  const RunnerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: bgcolor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: kElevationToShadow[3],
              ),
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    child: SizedBox(
                      height: 65,
                      child: AspectRatio(
                        aspectRatio: 1.714,
                        child: Image.asset("assets/fitness_app/back.png"),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 100,
                              right: 16,
                              top: 12,
                            ),
                            child: Text(
                              "You're doing great!",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.0,
                                color: Color.fromARGB(255, 157, 183, 255),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 100,
                          bottom: 12,
                          right: 16,
                        ),
                        child: Text(
                          "Keep it up & stick to your plan!",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            letterSpacing: 0.0,
                            color: const Color(0xFF3A5160).withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -16,
            left: 0,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.asset("assets/fitness_app/runner.png"),
            ),
          ),
        ],
      ),
    );
  }
}
