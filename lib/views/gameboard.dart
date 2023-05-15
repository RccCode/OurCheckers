import 'package:flutter/material.dart';
import 'package:ourcheckers/provider/room_data_provider.dart';
import 'package:ourcheckers/screens/singleplayer_screen.dart';
import 'package:ourcheckers/src/socket_methods.dart';
import 'package:provider/provider.dart';
import 'package:ourcheckers/src/block_table.dart';
import 'package:ourcheckers/src/coordinate.dart';
import 'package:ourcheckers/src/game_table.dart';
import 'package:ourcheckers/src/men.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final SocketMethods _socketMethods = SocketMethods();
  GameTable gameTable = GameTable(countRow: 8, countCol: 8);
  late int modeWalking;

  final Color colorBackgroundF = Color(0xffeec295);
  final Color colorBackgroundT = Color(0xff9a6851);
  final Color colorBorderTable = Color(0xff6d3935);
  final Color colorAppBar = Color(0xff6d3935);
  final Color colorBackgroundGame = Color(0xffc16c34);
  final Color colorBackgroundHighlight = Colors.blue[500]!;
  final Color colorBackgroundHighlightAfterKilling = Colors.purple[500]!;

  @override
  void initState() {
    super.initState();
    initGame();
    _socketMethods.tappedListener(context);
  }

  void initGame() {
    modeWalking = GameTable.MODE_WALK_NORMAL;
    gameTable = GameTable(countRow: 8, countCol: 8);
    gameTable.initMenOnTable();
  }

  void tapped(int index, RoomDataProvider roomDataProvider) {
    _socketMethods.tapGrid(
      index,
      roomDataProvider.roomData['_id'],
      roomDataProvider.displayElements,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);
    initScreenSize(context);

    return Container(
      height: MediaQuery.of(context).size.height-296,
      width: MediaQuery.of(context).size.width,
      child: AbsorbPointer(
        absorbing: roomDataProvider.roomData['turn']['socketID'] !=
            _socketMethods.socketClient.id,
        child: GridView.builder(
          itemCount: 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Scaffold(
        appBar: AppBar(
          backgroundColor: colorAppBar,
          centerTitle: true,
          title: Text('OurCheckers'),
          elevation: 0,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.refresh), onPressed: () {
              setState(() {
                initGame();
              });
            })
          ],
        ),
        body: Container(color: colorBackgroundGame, 
        child:
        Column(children: <Widget>[
          Expanded(
              child: Center(
                child: buildGameTable(),
              )),
          Container(decoration: BoxDecoration(color: colorAppBar,
              boxShadow: [BoxShadow(
                  color: Colors.black26, offset: Offset(0, 3), blurRadius: 12)
              ]),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[buildCurrentPlayerTurn()],),
          ),
        ]
        )
        )
    );
          },
        ),
      ),
    );
  }

  void initScreenSize(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double shortestSide = MediaQuery
        .of(context)
        .size
        .shortestSide-141;

    if (width < height) {
      blockSize = (shortestSide / 8) - (shortestSide * 0.03);
    } else {
      blockSize = (shortestSide / 8) - (shortestSide * 0.05);
    }
  }

  buildGameTable() {
    List<Widget> listCol = [];
    for (int row = 0; row < gameTable.countRow; row++) {
      List<Widget> listRow = [];
      for (int col = 0; col < gameTable.countCol; col++) {
        listRow.add(buildBlockContainer(Coordinate(row: row, col: col)));
      }

      listCol.add(Row(mainAxisSize: MainAxisSize.min,
          children: listRow));
    }

    return Container(padding: EdgeInsets.all(8),
        color: colorBorderTable,
        child: Column(mainAxisSize: MainAxisSize.min,
            children: listCol));
  }

  Widget buildBlockContainer(Coordinate coor) {
    BlockTable block = gameTable.getBlockTable(coor);

    Color colorBackground;
    if (block.isHighlight) {
      colorBackground = colorBackgroundHighlight;
    } else if (block.isHighlightAfterKilling) {
      colorBackground = colorBackgroundHighlightAfterKilling;
    } else {
      if (gameTable.isBlockTypeF(coor)) {
        colorBackground = colorBackgroundF;
      } else {
        colorBackground = colorBackgroundT;
      }
    }

    Widget menWidget;
    if (block.men != null) {
      Men? men = gameTable
          .getBlockTable(coor)
          .men;

      menWidget =
          Center(child: buildMenWidget(player: men!.player, isKing: men.isKing, size: blockSize));

      if (men.player == gameTable.currentPlayerTurn) {
        menWidget = Draggable<Men>(
            child: menWidget,
            feedback: menWidget,
            childWhenDragging: Container(),
            data: men,
            onDragStarted: () {
              setState(() {
                print("walking mode = ${modeWalking}");
                gameTable.highlightWalkable(men, mode: modeWalking);
              });
            },
            onDragEnd: (details) {
              setState(() {
                gameTable.clearHighlightWalkable();
              });
            });
      }
    } else {
      menWidget = Container();
    }

    if (!gameTable.hasMen(coor) && !gameTable.isBlockTypeF(coor)) {
      return DragTarget<Men>(
          builder: (context, candidateData, rejectedData) {
            return buildBlockTableContainer(colorBackground, menWidget);
          },
          onWillAccept: (men) {
            BlockTable blockTable = gameTable
                .getBlockTable(coor);
            return
              blockTable.isHighlight || blockTable.isHighlightAfterKilling;
          },
          onAccept: (men) {
            print("onAccept");
            setState(() {
              gameTable.moveMen(men, Coordinate.of(coor));
              gameTable.checkKilled(coor);
              if (gameTable.checkKillableMore(men, coor)) {
                modeWalking = GameTable.MODE_WALK_AFTER_KILLING;
              } else {
                if (gameTable.isKingArea(
                    player: gameTable.currentPlayerTurn, coor: coor)) {
                  men.upgradeToKing();
                }
                modeWalking = GameTable.MODE_WALK_NORMAL;
                gameTable.clearHighlightWalkable();
                gameTable.togglePlayerTurn();
                print("Player 1 : " + gameTable.countMenForPlayer(1).toString());
                print("Player 2 : " + gameTable.countMenForPlayer(2).toString());
                if (gameTable.countMenForPlayer(1) == 0){
                  print("Player 2 Wins!");
                  showWinningMessage(this.context, "Player 2 won the game!", () => {setState(() {initGame();})});
                } else if (gameTable.countMenForPlayer(2) == 0){
                  print("Player 1 Wins!");
                  showWinningMessage(this.context, "Player 1 won the game!", () => {setState(() {initGame();})});
                }
              }
            });
          });
    }

    return buildBlockTableContainer(colorBackground, menWidget);
  }

  Widget buildBlockTableContainer(Color colorBackground, Widget menWidget) {
    Widget containerBackground = Container(
        width: blockSize + (blockSize * 0.1),
        height: blockSize + (blockSize * 0.1),
        color: colorBackground,
        margin: EdgeInsets.all(2),
        child: menWidget);
    return containerBackground;
  }

  Widget buildCurrentPlayerTurn() {
    return Padding(padding: EdgeInsets.all(12),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text("Current turn".toUpperCase(),
              style: TextStyle(fontSize: 16, color: Colors.white)),
          Padding(padding: EdgeInsets.all(6),
              child: buildMenWidget(player: gameTable.currentPlayerTurn, size: blockSize))
        ]));
  }

  buildMenWidget({int player = 1, bool isKing = false, double size = 32}) {
    if (isKing) {
      return Container(width: size, height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: Colors.black45, offset: Offset(0, 4), blurRadius: 4)
              ],
              color: player == 1 ? Colors.black54 : Colors.grey[100]),
          child: Icon(Icons.star,
              color: player == 1 ? Colors.grey[100]!.withOpacity(0.5) : Colors
                  .black54.withOpacity(0.5),
              size: size - (size * 0.1)));
    }

    return Container(width: size, height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
                color: Colors.black45, offset: Offset(0, 4), blurRadius: 4)
            ],
            color: player == 1 ? Colors.black54 : Colors.grey[100]));
  }
}