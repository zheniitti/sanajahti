import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';

class SanamahtiBoard extends StatefulWidget {
  _SanamahtiBoardState createState() => _SanamahtiBoardState();
}

class _SanamahtiBoardState extends State<SanamahtiBoard> {
  String appBarText = "Sanamahti Board";
  bool pointerDown = false; //when sanamahti grid being touched, pointer is down
  int latestPointerIndex = -1;
  int currentPointerIndex;
  final Color upColor = Colors.purple; //inactive color
  final Color downColor = Colors.blue[500]; //active color
  Color ccolor = Colors.teal;
  List<int> downedIndexesList = [];

  ///list of list [key$index, getNeighbours(index), index]
  ///ruudun key, naapurin indeksi ja oma indeksi. Kaikki ruudut
  List ruutuList = [];
  List<String> letterList = [
    'u',
    'S',
    'ä',
    'e',
    'k',
    'n',
    'l',
    's',
    'e',
    'a',
    'u',
    'l',
    'k',
    'l',
    's',
    'u'
  ];
  var becameList = [];
  int touchAreaPadding = 18;
  Curve curve = Curves.easeOutCirc;
  double ruutuSize = 100;

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback(_afterLayout); what is this?
    createOfflineBoard();
    //createBoardOnline(); //no code yet
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(appBarText)),
      ),
      body: SizedBox(
        child: AbsorbPointer(
          absorbing: pointerDown,
          child: GestureDetector(
            onPanDown: updateBoardOnPanDown,
            onPanUpdate: updateBoardOnPan,
            onPanEnd: updateOnPanEnd,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Board(),
            ),
          ),
        ),
      ),
    );
  }

  Widget Board() {
    return Container(
      child: LayoutBuilder(
        builder: (context, constraints) => GridView.count(
            childAspectRatio: 1,
            crossAxisSpacing: constraints.maxWidth / 4 * 0.1,
            mainAxisSpacing: constraints.maxWidth / 4 * 0.1,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            children: ruutuList.map((lis) {
              GlobalKey key = lis[0];
              int index = lis[2];
              return Ruutu(index, key, constraints);
            }).toList()),
      ),
    );
  }

  AnimatedContainer Ruutu(
      int index, GlobalKey key, BoxConstraints constraints) {
    return AnimatedContainer(
      key: key,
      margin: downedIndexesList.contains(index)
          ? EdgeInsets.all(5)
          : EdgeInsets.all(0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(constraints.maxWidth / 4 * 0.2),
          color: getColor(index)),
      child: Center(child:
          LayoutBuilder(builder: (BuildContext c, BoxConstraints strain) {
        return Text(
          letterList[index].toUpperCase(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: strain.maxHeight * 0.6,
              fontFamily: 'Courier'),
        );
      })),
      duration: Duration(milliseconds: 600),
      curve: curve,
    );
  }

  void createOfflineBoard() {
    for (int i = 0; i < 16; i++) {
      /*  String letter = 'iatsenukolrpmävyhjdö'[
          Random().nextInt(20)] /*  random.nextInt(28) */;
      letterList.add(letter); */
      GlobalKey key = GlobalKey();
      ruutuList.add([key, getNeighbours(i), i]);
    }
  }

  getColor(int i) {
    if (downedIndexesList.contains(i)) return downColor;
    return upColor;
  }

  void updateBoardOnPanDown(DragDownDetails t) {
    setRuutuSize();
    int currentPointerIndex = getCurrentPointerIndexD(t);
    if (isActivatable(currentPointerIndex)) {
      downedIndexesList.add(currentPointerIndex);
      becameList.add(letterList[currentPointerIndex]);
    }
    setState(() {
      pointerDown = true;
      int length = downedIndexesList.length;
      appBarText = becameList.toString() /* '$length $downedIndexesList' */;
    });
  }

  void updateBoardOnPan(DragUpdateDetails t) {
    setState(() {
      pointerDown = true;
      currentPointerIndex = getCurrentPointerIndexU(t);

      if (isActivatable(currentPointerIndex)) {
        downedIndexesList.add(currentPointerIndex);
        becameList.add(letterList[currentPointerIndex]);
      }

      wentBackToLastIndex(currentPointerIndex);

      int length = downedIndexesList.length;
      appBarText = becameList.toString() /* '$length $downedIndexesList' */;
    });
  }

  void updateOnPanEnd(DragEndDetails t) {
    setState(() {
      pointerDown = false;
      pointerDown ? ccolor = downColor : ccolor = upColor;

      int length = downedIndexesList.length;
      appBarText = '$length $downedIndexesList';
      downedIndexesList.clear();
      becameList.clear();
    });
  }

  /// gets neigbhours list of neigbour indexes of current index
  List<int> getNeighbours(int i) {
    List<int> list = [];
    switch (i) {
      case 0:
        {
          list = [1, 4, 5];
        }
        break;

      case 1:
        {
          list = [0, 2, 6, 4, 5];
        }
        break;

      case 2:
        {
          list = [1, 3, 5, 6, 7];
        }
        break;

      case 3:
        {
          list = [2, 6, 7];
        }
        break;

      case 4:
        {
          list = [0, 1, 5, 8, 9];
        }
        break;

      case 5:
        {
          list = [0, 1, 2, 4, 6, 8, 9, 10];
        }
        break;

      case 6:
        {
          list = [1, 2, 6, 3, 9, 10, 5, 7, 11];
        }
        break;

      case 7:
        {
          list = [2, 3, 6, 10, 11];
        }
        break;

      case 8:
        {
          list = [4, 13, 5, 8, 9, 12];
        }
        break;

      case 9:
        {
          list = [4, 5, 6, 8, 10, 11, 12, 13, 14];
        }
        break;

      case 10:
        {
          list = [5, 6, 7, 9, 11, 13, 14, 15];
        }
        break;

      case 11:
        {
          list = [6, 7, 10, 14, 15];
        }
        break;

      case 12:
        {
          list = [8, 9, 13];
        }
        break;

      case 13:
        {
          list = [8, 9, 10, 12, 14];
        }
        break;

      case 14:
        {
          list = [9, 10, 11, 13, 15];
        }
        break;

      case 15:
        {
          list = [10, 11, 14];
        }
    }
    list.sort();
    return list;
  }

  ///gets pointer index in the sanamahti grid WHEN pan down
  int getCurrentPointerIndexU(DragUpdateDetails t) {
    int index;
    double x = t.globalPosition.dx;
    double y = t.globalPosition.dy;

    for (int i = 0; i < 16; i++) {
      double x1 = getRuutuPosition(i)[0];
      double x2 = getRuutuPosition(i)[1];
      double y1 = getRuutuPosition(i)[2];
      double y2 = getRuutuPosition(i)[3];
      if (x >= x1 + touchAreaPadding &&
          x < x2 - touchAreaPadding &&
          y >= y1 + touchAreaPadding &&
          y < y2 - touchAreaPadding) {
        index = i;
        break;
      }
    }

    return index;
  }

  ///gets pointer index in the sanamahti grid WHEN on pan
  int getCurrentPointerIndexD(DragDownDetails t) {
    int index;
    double x = t.globalPosition.dx;
    double y = t.globalPosition.dy;

    for (int i = 0; i < 16; i++) {
      double x1 = getRuutuPosition(i)[0];
      double x2 = getRuutuPosition(i)[1];
      double y1 = getRuutuPosition(i)[2];
      double y2 = getRuutuPosition(i)[3];
      if (x >= x1 + touchAreaPadding &&
          x < x2 - touchAreaPadding &&
          y >= y1 + touchAreaPadding &&
          y < y2 - touchAreaPadding) {
        index = i;
        break;
      }
    }

    return index;
  }

  ///list contain all ruutu corner coordinate
  List getRuutuPosition(int i) {
    final RenderBox ruutuBox =
        ruutuList[i][0].currentContext.findRenderObject();
    final ruutuPosition = ruutuBox.localToGlobal(Offset.zero);
    var postitionlist = [];
    postitionlist.add(ruutuPosition.dx);
    postitionlist.add(ruutuPosition.dx + ruutuBox.size.width);
    postitionlist.add(ruutuPosition.dy);
    postitionlist.add(ruutuPosition.dy + ruutuBox.size.height);

    return postitionlist;
  }

  setRuutuSize() {
    RenderBox ruutu = ruutuList[0][0].currentContext.findRenderObject();
    this.ruutuSize = ruutu.size.width;
  }

  bool isActivatable(int currentPointerIndex) {
    if (currentPointerIndex != null) {
      if (downedIndexesList.length == 0) return true;
      int latestIndex = downedIndexesList[downedIndexesList.length - 1];
      bool isNeighbourOfLastActivated =
          getNeighbours(latestIndex).contains(currentPointerIndex);
      if (isNeighbourOfLastActivated &&
          !downedIndexesList.contains(currentPointerIndex))
        return true;
      else
        return false;
    } else
      return false;
  }

  void wentBackToLastIndex(int currentPointerIndex) {
    int length = downedIndexesList.length;
    if (length > 1 && currentPointerIndex == downedIndexesList[length - 2]) {
      becameList.removeLast();
      downedIndexesList.removeLast();
    }
  }
}
