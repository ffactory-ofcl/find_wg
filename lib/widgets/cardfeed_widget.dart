import 'dart:math';
import 'package:find_wg/widgets/menu_bar.dart';
import 'package:flutter/material.dart' hide Card;

import 'package:find_wg/model/card.dart';
import 'card_widget.dart';

class CardsFeed extends StatefulWidget {
  final CardFeedProvider cardProvider;

  const CardsFeed(this.cardProvider, {Key? key}) : super(key: key);

  @override
  _CardsFeedState createState() => _CardsFeedState();
}

class _CardsFeedState extends State<CardsFeed> with TickerProviderStateMixin {
  void _reactedToCard({bool? positive}) {
    double val = _swipeController.value;
    if (positive != null) {
      val = positive ? -0.1 : 0.1;
    }

    if (val < 0) {
      _likeAnimationController.forward();
    } else {
      _dislikeAnimationController.forward();
    }
    _swipeController.animateTo(
      val > 0 ? 2 : -2,
      duration: Duration(
        milliseconds: (180 * (2 - val.abs())).toInt(),
      ),
    );

    Future.delayed(_swipeController.duration!, () {
      setState(() {
        val = 0;
        if (val < 0) {
          widget.cardProvider.like();
        } else {
          widget.cardProvider.dislike();
        }
      });
    });
  }

  late Size _deviceSize;
  Point<double>? _dragStart;
  late AnimationController _swipeController;
  late AnimationController _likeAnimationController;
  late AnimationController _dislikeAnimationController;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      duration: Duration(milliseconds: 350),
      lowerBound: -2,
      upperBound: 2,
      value: 0,
      vsync: this,
    );
    _likeAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _likeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(
            Duration(milliseconds: 200),
            () => _likeAnimationController.animateBack(0,
                duration: Duration(milliseconds: 300)));
      }
    });
    _dislikeAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _dislikeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(
            Duration(milliseconds: 200),
            () => _dislikeAnimationController.animateBack(0,
                duration: Duration(milliseconds: 300)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        widget.cardProvider.isEmpty
            ? NoCardsLeftBackdrop(resetMatches: () {})
            : GestureDetector(
                onHorizontalDragStart: (details) {
                  _dragStart = Point(
                      details.globalPosition.dx, details.globalPosition.dy);
                  // setState(() =>
                  _swipeController.value = 0;
                },
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity!.abs() > 600 ||
                      _swipeController.value.abs() > 0.35) {
                    _reactedToCard();
                  } else {
                    _swipeController.animateTo(0,
                        duration: Duration(
                            milliseconds:
                                (350 * _swipeController.value.abs()).toInt()));
                  }
                  _dragStart = null;
                  // setState(() => swipeAmount = 0);
                },
                onHorizontalDragUpdate: (details) {
                  Point dragNow =
                      Point(details.globalPosition.dx, _dragStart!.y);
                  // setState(() =>
                  _swipeController.value =
                      (dragNow.x - _dragStart!.x) / _deviceSize.width;
                },
                child: Stack(
                  children: [
                    widget.cardProvider.length == 1
                        ? SizedBox()
                        : Container(color: Colors.black),
                    widget.cardProvider.length == 1
                        ? NoCardsLeftBackdrop(resetMatches: () {})
                        : AnimatedBuilder(
                            animation: _swipeController,
                            builder: (_, __) {
                              Matrix4 cardTransform = Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..scale(0.8 +
                                    Curves.easeOutQuad.transform(
                                            _swipeController.value.abs() / 2) *
                                        0.2)
                                ..rotateX(-0.1 *
                                    (-4 *
                                            pow(
                                              Curves.easeOutCirc.transform(
                                                      _swipeController.value
                                                              .abs() /
                                                          2) -
                                                  0.5,
                                              2,
                                            ) +
                                        1));
                              return Transform(
                                origin: Offset(0.5, 0.5),
                                transform: cardTransform,
                                alignment: Alignment.center,
                                child: Opacity(
                                  opacity: Curves.easeOutQuad.transform(
                                      0.5 * _swipeController.value.abs()),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16 *
                                        (1 -
                                            _swipeController.value.abs() *
                                                0.5)),
                                    child: CardsFeedCardWidget(
                                        widget.cardProvider[1], 0),
                                  ),
                                ),
                              );
                            }),
                    AnimatedBuilder(
                      // Card in front
                      animation: _swipeController,
                      builder: (_, __) {
                        Matrix4 cardRotation = Matrix4.identity();
                        cardRotation.rotateZ((_swipeController.value) * 0.1);
                        Matrix4 cardTransform = Matrix4.identity();
                        cardTransform.translate(
                            _swipeController.value * _deviceSize.width * 0.6);
                        cardTransform.scale(
                            1 - min(1, _swipeController.value.abs()) * 0.2);

                        return Transform(
                          transform: cardTransform,
                          alignment: Alignment.center,
                          child: Transform(
                            transform: cardRotation,
                            alignment: Alignment(0.0, 1.25),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 32 *
                                          (1 -
                                              _swipeController.value.abs() / 2),
                                      spreadRadius: 2)
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8 *
                                    Curves.easeOutCubic.transform(min(
                                        1,
                                        max(
                                            0,
                                            4 *
                                                _swipeController.value
                                                    .abs())))),
                                child: CardsFeedCardWidget(
                                    widget.cardProvider[0],
                                    (_swipeController.value > 0 ? 1 : -1) *
                                        Curves.easeOutCubic.transform(
                                            _swipeController.value.abs() *
                                                0.5)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Center(
                      child: Container(
                          height: min(
                              250, MediaQuery.of(context).size.height * 0.3),
                          child: AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _likeAnimationController,
                                    child: Image.asset(
                                      "resources/img/icons8-heart-240.png",
                                      fit: BoxFit.contain,
                                    ),
                                    builder: (ctx, widget) => IgnorePointer(
                                      child: Opacity(
                                        opacity: 0.7 *
                                            (_likeAnimationController.status ==
                                                        AnimationStatus.forward
                                                    ? Curves.easeInOut
                                                    : Curves.easeIn)
                                                .transform(
                                              min(
                                                  1,
                                                  _likeAnimationController
                                                      .value),
                                            ),
                                        child: widget,
                                      ),
                                    ),
                                  ),
                                  AnimatedBuilder(
                                    animation: _dislikeAnimationController,
                                    child: Image.asset(
                                      "resources/img/icons8-dislike-80.png",
                                      fit: BoxFit.contain,
                                    ),
                                    builder: (ctx, widget) => IgnorePointer(
                                      child: Opacity(
                                        opacity: 0.7 *
                                            (_dislikeAnimationController
                                                            .status ==
                                                        AnimationStatus.forward
                                                    ? Curves.easeInOut
                                                    : Curves.easeIn)
                                                .transform(
                                              min(
                                                  1,
                                                  _dislikeAnimationController
                                                      .value),
                                            ),
                                        child: widget,
                                      ),
                                    ),
                                  ),
                                ],
                              ))),
                    ),
                  ],
                ),
              ),
        Positioned(
          bottom: 16,
          // left: 0,
          // right: 0,
          child: FloatingMenuBar(
            widget.cardProvider,
            onLike: () => _reactedToCard(positive: true),
            onDislike: () => _reactedToCard(positive: false),
          ),
        )
      ],
    );
  }
}

class NoCardsLeftBackdrop extends StatelessWidget {
  NoCardsLeftBackdrop({
    Key? key,
    required this.resetMatches,
  }) : super(key: key);

  final VoidCallback resetMatches;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            Text("no cards"),
            ElevatedButton(
                onPressed: () => resetMatches(), child: Text("reset"))
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
    );
  }
}
