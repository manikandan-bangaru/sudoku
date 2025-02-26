import 'package:flutter/material.dart';
import '/utils/game_colors.dart';

class StarBadgeWidget extends StatelessWidget {
  StarBadgeWidget({
    this.today,
    super.key,
  });

  int? today;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        // color: GameColors.starBadgeBg,
        shape: BoxShape.circle,
        border: Border.all(color: GameColors.starBadgeBg, // Border color
          width: 2,)
      ),
      child:
      Stack(
        clipBehavior: Clip.none, // Ensures the star icon can overflow the container
        children: [
          Center(
            child: FittedBox(
              child: (today == null)
                  ? Icon(Icons.star, color: GameColors.starBadgeStar)
                  : Text(
                '$today',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
          if (today != null) const Positioned(
            top: -4, // Adjust the position
            right: -4, // Adjust the position
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 12, // Small star size
            ),
          ),
        ],
      ),
      // FittedBox(
      //   child:  (this.today == null ) ? Icon(Icons.star,color: GameColors.starBadgeStar) : Text(
      //     '$today',style: TextStyle(color:Colors.black ),
      //     // size: 14,
      //     // color: GameColors.starBadgeStar,
      //   ),
      // ),
    );
  }
}
