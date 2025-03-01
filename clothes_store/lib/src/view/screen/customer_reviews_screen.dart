import 'package:clothes_store/src/controller/review_controller.dart';
import 'package:clothes_store/src/model/REVIEW_MODEL.dart';
import 'package:clothes_store/src/view/widget/review_widget.dart';
import 'package:flutter/material.dart';

ReviewController reviewController = ReviewController();

class CustomerReviewsScreen extends StatefulWidget {
  const CustomerReviewsScreen({super.key, required this.productID});
  final int productID;

  @override
  State<CustomerReviewsScreen> createState() => _CustomerReviewsScreenState();
}

class _CustomerReviewsScreenState extends State<CustomerReviewsScreen> {
  List<REVIEW_MODEL> reviewList = [];

  Future<void> fetchReviews() async {
    try {
      final data =
          await reviewController.getReviewsByProductId(widget.productID);
      if (data != null) {
        setState(() {
          reviewList = data;
        });
      }
    } on Exception catch (e) {
      print("error tại fetch category list:");
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.black),
      ),
    );
  }

  // Widget itemReview(){
  //
  //
  // }

  @override
  Widget build(BuildContext context) {
    if (reviewList.isEmpty) {
      return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _appBar(context),
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sản phẩm chưa có review"),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
    } else {
      return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _appBar(context),
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(reviewList.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Container(
                                child: (ReviewWidget(
                                  reviewList[index],
                                )),
                              ),
                            );
                          })
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
    }
  }
}
