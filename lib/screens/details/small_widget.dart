import 'package:flutter/material.dart';

class SmallWidget extends StatelessWidget {
  const SmallWidget(
      {super.key,
      required this.txt1,
      required this.txt2,
      this.txtcolor = const Color(0xff147e4e)});
  final String txt1;
  final String txt2;
  final dynamic txtcolor;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF3A5160).withOpacity(0.2),
                offset: const Offset(1.12, 1.12),
                blurRadius: 12),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 20, right: 20, top: 12.0, bottom: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                txt1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.28,
                  color: txtcolor,
                ),
              ),
              const SizedBox(height: 2),
              Text(txt2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
