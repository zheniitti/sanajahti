import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SanamahtiBoard extends StatefulWidget {
  _SanamahtiBoardState createState() => _SanamahtiBoardState();
}

class _SanamahtiBoardState extends State<SanamahtiBoard> {
  String appBarTitle = "Sanamahti Grid";
  bool pointerDown = false; //when sanamahti grid being touched, pointer is down
  int latestPointerIndex = -1;
  int currentPointerIndex;
  final Color upColor = Colors.purple; //inactive color
  final Color downColor = Colors.blue[500]; //active color
  Color ccolor = Colors.teal;
  List<Widget> widgetList = [];
  List<int> downedIndexesList = [];

  ///list of list [key$index, getNeighbours(index), index]
  ///ruudun key, naapurin indeksi ja oma indeksi. Kaikki ruudut
  List ruutuList = [];
  final letterList = [];
  var becameList = [];
  int touchAreaPadding = 18;
  Curve curve = Curves.easeOutCirc;
  double ruutuSize = 50;

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback(_afterLayout); what is this?
    createBoardOffline();
    //createBoardOnline(); //no code yet
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(appBarTitle)),
      ),
      body: SizedBox(
        child: AbsorbPointer(
          absorbing: pointerDown,
          child: GestureDetector(
            onPanDown: updateBoardOnPanDown,
            onPanUpdate: updateBoardOnPan,
            onPanEnd: updateOnPanEnd,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  children: ruutuList.map((lis) {
                    GlobalKey key = lis[0];
                    int index = lis[2];
                    return AnimatedContainer(
                      key: key,
                      height: 0.8 * ruutuSize,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: getColor(index)),
                      child: Center(
                          child: Text(
                        letterList[index].toString(),
                        style: TextStyle(
                            fontSize: 0.5 * ruutuSize,
                            fontWeight: FontWeight.bold),
                      )),
                      duration: Duration(milliseconds: 600),
                      curve: curve,
                    );
                  }).toList()),
            ),
          ),
        ),
      ),
    );
  }

  getColor(int i) {
    if (downedIndexesList.contains(i)) return downColor;
    return upColor;
  }

  void updateBoardOnPanDown(DragDownDetails t) {
    ruutuSize = getRuutuSize();
    int currentPointerIndex = getCurrentPointerIndexD(t);
    if (isActivatable(currentPointerIndex)) {
      downedIndexesList.add(currentPointerIndex);
      becameList.add(letterList[currentPointerIndex]);
    }
    setState(() {
      pointerDown = true;
      int length = downedIndexesList.length;
      appBarTitle = becameList.toString() /* '$length $downedIndexesList' */;
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
      appBarTitle = becameList.toString() /* '$length $downedIndexesList' */;
    });
  }

  void updateOnPanEnd(DragEndDetails t) {
    setState(() {
      pointerDown = false;
      pointerDown ? ccolor = downColor : ccolor = upColor;

      int length = downedIndexesList.length;
      appBarTitle = '$length $downedIndexesList';
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

  getRuutuSize() {
    RenderBox ruutuBox = ruutuList[0][0].currentContext.findRenderObject();
    return ruutuBox.size.width;
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

  void createBoardOffline() {
    var random = new Random();
    for (int i = 0; i < 16; i++) {
      GlobalKey key = GlobalKey();
      var letter =
          'iatsenukolrpmävyhjdö'[random.nextInt(20)] /*  random.nextInt(28) */;
      letterList.add(letter);
      ruutuList.add([key, getNeighbours(i), i]);
      //next creating container
      AnimatedContainer ruutu = AnimatedContainer(
        key: key,
        color: upColor,
        padding: EdgeInsets.all(10),
        child: Center(
            child: Expanded(
          child: Text(
            letter,
            style: TextStyle(fontSize: 20),
          ),
        )),
        curve: Curves.easeInOutBack,
        duration: Duration(milliseconds: 1000),
      );
      widgetList.add(ruutu);
    }
  }
}
