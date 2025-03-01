
import 'package:clothes_store/core/app_data.dart';
import 'package:clothes_store/src/model/REVIEW_MODEL.dart';
import 'package:clothes_store/src/view/widget/rating_widget.dart';
import 'package:flutter/material.dart';

class ReviewWidget extends StatelessWidget {
  final REVIEW_MODEL review;

  ReviewWidget(this.review, {super.key});

  @override
  Widget build(BuildContext context) {
    double rating = review.rating == null ? 0 : review.rating!.toDouble();
    return Card(
      elevation: 10,
      color: Colors.white.withValues(alpha: 0.8),
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(2, 5, 0, 5),
          child: Text(review.userInfo!.fullName!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            RatingStars(rating),
            SizedBox(height: 10,),
            Text("Comment: ${review.comment}", style: TextStyle(height: 2, fontSize: 15, fontWeight: FontWeight.w500),),
            SizedBox(height: 5,),
            Text("Created At: ${review.createdAt != null ? AppData.formatDateTime(review.createdAt!) : ''}"),
          ],
        ),
      ),
    );
  }
}
