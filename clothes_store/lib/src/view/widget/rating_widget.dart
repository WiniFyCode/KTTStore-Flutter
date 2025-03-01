import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RatingStars extends StatelessWidget {
  final double rating;

  RatingStars(this.rating, {super.key});

  int calculateStarRating(double rating) {
    double roundedRating = rating.roundToDouble();
    if (roundedRating >= 4.6) {
      return 5;
    } else if (roundedRating >= 4.0) {
      return 4;
    } else if (roundedRating >= 3.0) {
      return 3;
    } else if (roundedRating >= 2.0) {
      return 2;
    } else if (roundedRating >= 1.0) {
      return 1;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    int starCount = calculateStarRating(rating);

    return Row(
      children: List.generate(5, (index) {
        if (index < starCount) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              FontAwesomeIcons.solidStar,
              color: Colors.amber,
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              FontAwesomeIcons.star,
              color: Colors.grey,
            ),
          );
        }
      }),
    );
  }
}