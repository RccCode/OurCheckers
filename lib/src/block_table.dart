import 'package:ourcheckers/src/killing.dart';
import 'package:ourcheckers/src/men.dart';

class BlockTable {
  int row;
  int col;
  Men? men;
  bool isHighlight;
  bool isHighlightAfterKilling;
  Killed victim = Killed.none();
  bool killableMore = false;

  BlockTable({this.row = 0, this.col = 0, this.men,
    this.isHighlight = false,
    this.isHighlightAfterKilling = false,
    this.killableMore =false});

}