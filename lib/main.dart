import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomride',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MatchPage(),
    );
  }
}

class MatchPage extends StatefulWidget {
  MatchPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> with TickerProviderStateMixin {
  Size? _deviceSize;

  late List<Card> matchCards;
  List<Card> likedCards = [];
  List<Card> dislikedCards = [];

  double swipeAmount = 0;
  Point<double>? _dragStart;
  // late AnimationController _controller;
  late AnimationController _heartAnimationController;

  void _resetMatches() {
    matchCards = [
      House("House 1", "This is desc5iption"),
      House("House 2", "This is seconds"),
      House("House 3", "This is me"),
      House("House 4", "This is apapment"),
      House("House 5", "This is house"),
    ];
  }

  _MatchPageState() {
    _resetMatches();
  }

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //   duration: Duration(milliseconds: 500),
    //   lowerBound: -1,
    //   upperBound: 1,
    //   vsync: this,
    // );
    _heartAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(
            Duration(milliseconds: 200),
            () => _heartAnimationController.animateBack(0,
                duration: Duration(milliseconds: 300)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Matrix4 cardRotation = Matrix4.identity();
    cardRotation.rotateZ((swipeAmount) * 0.1);

    Matrix4 cardTransform = Matrix4.identity();
    cardTransform.translate((swipeAmount) * (_deviceSize?.width ?? 0) * 0.6);
    cardTransform.scale(1 - swipeAmount.abs() * 0.2);
    if (_deviceSize == null) {
      _deviceSize = MediaQuery.of(context).size;
    }

    return Scaffold(
      body: matchCards.length <= 1
          ? Container(
              child: Center(
                child: Column(
                  children: [
                    Text("no cards"),
                    RaisedButton(
                        onPressed: () => setState(() => _resetMatches()),
                        child: Text("reset"))
                  ],
                  mainAxisSize: MainAxisSize.min,
                ),
              ),
            )
          : GestureDetector(
              onHorizontalDragStart: (details) {
                _dragStart =
                    Point(details.globalPosition.dx, details.globalPosition.dy);
                setState(() => swipeAmount = 0);
              },
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity!.abs() > 600 ||
                    swipeAmount.abs() > 0.35) {
                  if (swipeAmount < 0) {
                    likedCards.add(matchCards[0]);
                    _heartAnimationController.forward();
                  } else {
                    dislikedCards.add(matchCards[0]);
                  }
                  matchCards.removeAt(0);
                }
                _dragStart = null;
                // swipeAmount
                setState(() => swipeAmount = 0);
              },
              onHorizontalDragUpdate: (details) {
                Point dragNow = Point(details.globalPosition.dx, _dragStart!.y);
                setState(() => swipeAmount =
                    (dragNow.x - _dragStart!.x) / (_deviceSize?.width ?? 0));
              },
              child: Stack(
                children: [
                  Container(color: Colors.black),
                  Container(color: Colors.green[900]!.withOpacity(0.2)),
                  Transform.scale(
                    scale: 0.8 + (swipeAmount).abs() * 0.2,
                    child: Opacity(
                      opacity: 0.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MatchCardWidget(matchCards[1], 0),
                      ),
                    ),
                  ),
                  Transform(
                    transform: cardTransform,
                    alignment: Alignment.center,
                    child: Transform(
                      transform: cardRotation,
                      alignment: Alignment(0.0, 1.25),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8 *
                            Curves.easeIn
                                .transform(max(1, min(1, 4 * swipeAmount)))),
                        child: MatchCardWidget(matchCards[0], swipeAmount),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _heartAnimationController,
                    child: Image.asset(
                      "resources/img/icons8-heart-240.png",
                      fit: BoxFit.contain,
                    ),
                    builder: (ctx, widget) => IgnorePointer(
                      child: Opacity(
                        opacity: (_heartAnimationController.status ==
                                    AnimationStatus.forward
                                ? Curves.easeInOut
                                : Curves.easeIn)
                            .transform(
                          min(1, _heartAnimationController.value),
                        ),
                        child: widget,
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

abstract class Card extends StatelessWidget {}

class House extends Card {
  final String title;
  final String description;
  final List<ImageProvider> images;
  final bool highlighted;

  House(this.title, this.description,
      {List<ImageProvider>? images, this.highlighted = false})
      : this.images = images ?? List.empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            // height: min(240, MediaQuery.of(context).size.height * 0.2),
            color: Colors.grey[300],
            child: images.isEmpty
                ? Image.network(
                    "https://images.unsplash.com/photo-1450704944629-6a65f6810cf2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=900&q=60",
                  )
                : Image(image: images.first),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MatchCardWidget extends StatelessWidget {
  final Card card;
  final double swipeAmount;

  MatchCardWidget(this.card, this.swipeAmount);

  @override
  Widget build(BuildContext context) {
    Widget _icon = Container();
    Color? _overlayColor = Colors.black;
    if (swipeAmount > 0) {
      _icon = Icon(Icons.remove_circle_outline, size: 64, color: Colors.white);
      _overlayColor = Colors.blue[700];
    } else if (swipeAmount < 0) {
      _icon = Icon(Icons.add_box, size: 64, color: Colors.white);
      _overlayColor = Colors.pink[300];
    }

    double _phoneHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints.expand(),
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          card,
          IgnorePointer(
            child: Opacity(
              opacity: Curves.easeInOutCirc.transform(swipeAmount.abs()),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                    ),
                    ClipRRect(
                      child: OverflowBox(
                        maxHeight: _phoneHeight,
                        maxWidth: _phoneHeight,
                        child: Container(
                          height: _phoneHeight *
                              0.7 *
                              pow(
                                  Curves.easeOutCubic
                                      .transform(swipeAmount.abs()),
                                  2),
                          width: _phoneHeight *
                              0.7 *
                              pow(
                                  Curves.easeOutCubic
                                      .transform(swipeAmount.abs()),
                                  2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.lerp(
                                Colors.grey[500],
                                _overlayColor,
                                Curves.easeInOutCirc.transform(
                                    min(swipeAmount.abs() * 1.3, 1))),
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: Curves.easeOut.transform(
                          min(1, max(swipeAmount.abs() * 2 - 0.3, 0))),
                      child: Container(
                        height: 60,
                        width: 60,
                        child: _icon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
