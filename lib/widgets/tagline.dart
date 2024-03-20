import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hyper_effects/hyper_effects.dart';

class TagLine extends StatefulWidget {
  const TagLine({super.key});

  @override
  State<TagLine> createState() => _TagLineState();
}

class _TagLineState extends State<TagLine> {
  List<String> tagLines = [
    'better',
    'faster',
    'smarter',
    'healthier',
    'stronger',
    'more',
  ];
  int lastTagLine = 0;
  int tagLine = 0;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(milliseconds: (2000 * timeDilation).toInt()), (timer) {
      setState(() {
        lastTagLine = tagLine;
        tagLine = (tagLine + 1) % tagLines.length;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Grow ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [
              Color(0xFF57CC99),
              Color(0xFF6B8E23),
            ],
          ).createShader(rect),
          child: Text(
            tagLines[lastTagLine],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          )
              .roll(
                tagLines[tagLine],
                symbolDistanceMultiplier: 1.5,
                tapeSlideDirection: TapeSlideDirection.down,
                tapeCurve: Curves.easeInOutCubic,
                widthCurve: Curves.easeOutCubic,
                widthDuration: const Duration(milliseconds: 1000),
                // padding: const EdgeInsets.only(left: 16),
              )
              .animate(
                trigger: tagLine,
                duration: const Duration(milliseconds: 1000),
              ),
        ),
      ],
    );
  }
}
