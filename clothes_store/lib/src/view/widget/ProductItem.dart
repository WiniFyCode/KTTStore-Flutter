
import 'package:flutter/material.dart';

class ProductItemWidget extends StatelessWidget {
  String hinh;
  String tieude;
  double gia;

  ProductItemWidget({
    super.key,
    this.hinh = "",
    this.tieude = "",
    this.gia = 0
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 180,
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: (){

        },
        child: Container(
          margin: EdgeInsets.all(8.0),
          width: 150,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black)
          ),
          child: Column(
            children: [
              Image.asset(
                  hinh,
                width: 130,
                height: 130,
              ),
              Text(this.tieude),
              Text('${this.gia}\$'),
            ],
          ),
        ),
      )
    );
  }
}
