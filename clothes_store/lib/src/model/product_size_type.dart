import 'package:clothes_store/src/model/categorical.dart';
import 'package:clothes_store/src/model/numerical.dart';

class ProductSizeType {
  List<Numerical>? numerical;
  List<Categorical>? categorical;

  ProductSizeType({this.numerical, this.categorical});
}
