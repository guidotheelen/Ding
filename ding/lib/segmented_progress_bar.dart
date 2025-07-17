import 'package:flutter/material.dart';

class Segment {
  final Duration duration;
  final Color color;
  Segment({required this.duration, required this.color});
}

class SegmentedProgressBar extends StatelessWidget {
  final List<Segment> segments;
  final double elapsedSeconds;
  final void Function(int segmentIndex)? onSegmentTap;
  const SegmentedProgressBar({
    required this.segments,
    required this.elapsedSeconds,
    this.onSegmentTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double acc = 0;
    return SizedBox(
      height: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              for (int i = 0; i < segments.length; i++)
                Expanded(
                  flex: segments[i].duration.inMilliseconds,
                  child: GestureDetector(
                    onTap: onSegmentTap != null ? () => onSegmentTap!(i) : null,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      children: [
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: segments[i].color.withOpacity(0.5),
                            borderRadius: i == 0
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  )
                                : i == segments.length - 1
                                    ? const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      )
                                    : BorderRadius.zero,
                          ),
                        ),
                        Builder(builder: (context) {
                          double start = acc;
                          acc += segments[i].duration.inMilliseconds;
                          double fill = (elapsedSeconds * 1000 - start)
                              .clamp(0, segments[i].duration.inMilliseconds)
                              .toDouble();
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: segments[i].duration.inMilliseconds ==
                                    0
                                ? 0
                                : fill / segments[i].duration.inMilliseconds,
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: segments[i].color,
                                borderRadius: i == 0
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      )
                                    : i == segments.length - 1
                                        ? const BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          )
                                        : BorderRadius.zero,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
