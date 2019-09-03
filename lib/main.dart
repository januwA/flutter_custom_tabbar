import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

double ourMap(v, start1, stop1, start2, stop2) {
  return (v - start1) / (stop1 - start1) * (stop2 - start2) + start2;
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final int initPage = 0;
  PageController _pageController;
  List<String> tabs = ['aaa', 'bbb', 'ccc', 'ddd', 'eee'];

  Stream<int> get currentPage$ => _currentPageSubject.stream;
  Sink<int> get currentPageSink => _currentPageSubject.sink;
  BehaviorSubject<int> _currentPageSubject;

  Alignment _dragAlignment;
  AnimationController _controller;
  Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    _currentPageSubject = BehaviorSubject<int>.seeded(initPage);
    _pageController = PageController(initialPage: initPage);
    _dragAlignment = Alignment(ourMap(initPage, 0, tabs.length - 1, -1, 1), 0);

    _controller = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    )..addListener(() {
        setState(() {
          _dragAlignment = _animation.value;
        });
      });

    currentPage$.listen((int page) {
      _runAnimation(
        _dragAlignment,
        Alignment(ourMap(page, 0, tabs.length - 1, -1, 1), 0),
      );
    });
  }

  @override
  void dispose() {
    _currentPageSubject.close();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _runAnimation(Alignment oldA, Alignment newA) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: oldA,
        end: newA,
      ),
    );

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).padding.top + 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(35),
              ),
              child: Stack(
                children: <Widget>[
                  // use animation controller
                  // Align(
                  //   alignment: _dragAlignment,
                  //   child: LayoutBuilder(
                  //     builder:
                  //         (BuildContext context, BoxConstraints constraints) {
                  //       double width = constraints.maxWidth;
                  //       return Padding(
                  //         padding: const EdgeInsets.all(2.0),
                  //         child: Container(
                  //           height: double.infinity,
                  //           width: width / tabs.length,
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(35),
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),

                  // use animated widget
                  StreamBuilder(
                    stream: currentPage$,
                    builder: (context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        return AnimatedAlign(
                          duration: kThemeAnimationDuration,
                          alignment: Alignment(
                              ourMap(snapshot.data, 0, tabs.length - 1, -1, 1),
                              0),
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              double width = constraints.maxWidth;
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  height: double.infinity,
                                  width: width / tabs.length,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return SizedBox();
                    },
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      children: tabs.map((t) {
                        int index = tabs.indexOf(t);
                        return Expanded(
                          child: MaterialButton(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            color: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            focusElevation: 0.0,
                            hoverElevation: 0.0,
                            elevation: 0.0,
                            highlightElevation: 0.0,
                            child: StreamBuilder(
                                stream: currentPage$,
                                builder:
                                    (context, AsyncSnapshot<int> snapshot) {
                                  return AnimatedDefaultTextStyle(
                                    duration: kThemeAnimationDuration,
                                    style: TextStyle(
                                      inherit: true,
                                      color: snapshot.data == index
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    child: Text(t),
                                  );
                                }),
                            onPressed: () {
                              currentPageSink.add(index);
                              _pageController.jumpToPage(index);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => currentPageSink.add(page),
              children: <Widget>[
                for (var t in tabs)
                  Center(
                    child: Text(t),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
