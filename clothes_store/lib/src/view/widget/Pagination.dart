import 'dart:math';

import 'package:flutter/material.dart';

class PaginationWidget extends StatefulWidget {
  int totalPage;
  int currentPage;
  void Function(int newPage) setPageNumber;
  PaginationWidget(this.totalPage, this.currentPage, this.setPageNumber,
      {super.key});

  @override
  State<PaginationWidget> createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<PaginationWidget> {
  @override
  void initState() {
    super.initState();
    getCurrentPageAndTotalPage();
  }

  void getCurrentPageAndTotalPage() async {}

  Widget _buildPageButton(int page) {
    return Container(
      width: 42,
      height: 40,
      child: ElevatedButton(
        style: ButtonStyle(
          //maximumSize: MaterialStateProperty.all(Size(20, 20)),
          // minimumSize: MaterialStateProperty.all(Size(20, 20)),
          backgroundColor: MaterialStateProperty.all<Color>(
              widget.currentPage == page
                  ? Color(0xffF9D1B8)
                  : Colors.grey[200]!), // Màu nền xám nhạt
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0), // Bo 4 góc vừa
            ),
          ),
        ),
        onPressed: () {
          widget.setPageNumber(page);
        },
        child: Text(
          page.toString(),
          style: TextStyle(
            fontWeight: widget.currentPage == page
                ? FontWeight.bold
                : FontWeight.normal,
            color:
                widget.currentPage == page ? Color(0xffEC6813) : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageItems = [];

    if (widget.totalPage < 4) {
      for (int i = 1; i <= widget.totalPage; i++) {
        pageItems.add(
          _buildPageButton(i),
        );
        pageItems.add(SizedBox(
          width: 5,
        ));
      }
    } else {
      pageItems.add(_buildPageButton(1));
      pageItems.add(SizedBox(
        width: 5,
      ));

      if (widget.currentPage >= 4) {
        pageItems.add(
          Text(
            "...",
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        );
        pageItems.add(SizedBox(
          width: 5,
        ));
      }

      int start = max(2, widget.currentPage - 1);
      int end = min(widget.totalPage - 1, widget.currentPage + 1);

      for (int i = start; i <= end; i++) {
        pageItems.add(_buildPageButton(i));
        pageItems.add(SizedBox(
          width: 5,
        ));
      }

      if (widget.currentPage <= widget.totalPage - 3) {
        pageItems.add(
          Text(
            "...",
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        );
        pageItems.add(SizedBox(
          width: 5,
        ));
      }
      pageItems.add(_buildPageButton(widget.totalPage));
    }

    if (widget.totalPage <= 0) {
      return Container(
        child: Text("total page = 0"),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            child: TextButton(
              onPressed: () {
                // Add navigation logic for Previous button
              },
              child: Text('<'),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          ...pageItems,
          SizedBox(
            width: 5,
          ),
          Container(
            width: 40,
            child: TextButton(
              onPressed: () {
                // Add navigation logic for Next button
              },
              child: Text('>'),
            ),
          ),
        ],
      );
    }
  }
}
