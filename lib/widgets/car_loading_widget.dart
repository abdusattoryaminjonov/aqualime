import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CarLoadingBar extends StatelessWidget {
  final int totalLength; // Masalan: 4 bosqich
  final int currentValue; // 0 dan boshlanadi, 0=boshlanish, 3=finish

  const CarLoadingBar({
    super.key,
    required this.totalLength,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    const double iconSize = 20;

    return SizedBox(
      height: 40,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // ✅ TO‘G‘RILANGAN QATOR
          final double segmentWidth =
              (constraints.maxWidth - 2 * iconSize) / (totalLength);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Progress bar chiziqlari
              Positioned(
                left: iconSize,
                right: iconSize,
                top: 30,
                child: Row(
                  children: List.generate(totalLength, (index) {
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        color: index < currentValue
                            ? Colors.green
                            : Colors.grey[300],
                      ),
                    );
                  }),
                ),
              ),

              // Mashina iconi
              if (currentValue < totalLength)
                Positioned(
                  left: iconSize +
                      segmentWidth * currentValue -
                      (iconSize / 2),
                  top: 5,
                  child: Icon(
                    Iconsax.truck_time,
                    size: iconSize,
                    color: Colors.blue,
                  ),
                ),

              // Finish flag
              Positioned(
                right: 0,
                top: 10,
                child: Icon(
                  Icons.flag,
                  size: iconSize,
                  color:  Colors.red,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}