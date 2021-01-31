import 'dart:math';

import 'package:flutter/material.dart' hide Card;
import 'package:roomride/model/card.dart';

class CardWidget extends StatefulWidget {
  final Card card;

  CardWidget(this.card) : super(key: ValueKey(card.hashCode));

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  late final PageController _imageViewCtrl;

  bool _enlargeImg = false;

  @override
  void initState() {
    super.initState();
    _imageViewCtrl = PageController()..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          AnimatedContainer(
            curve: Curves.linearToEaseOut,
            duration: Duration(milliseconds: 180),
            height: _enlargeImg &&
                    (widget.card.images[_imageViewCtrl.page?.toInt() ?? 0]
                        is CardImageLoaded)
                ? min(500, MediaQuery.of(context).size.height * 0.7)
                : min(240, MediaQuery.of(context).size.height * 0.4),
            child: Stack(
              children: [
                !_imageViewCtrl.hasClients
                    ? Container(color: Colors.black)
                    : AnimatedBuilder(
                        animation: _imageViewCtrl,
                        builder: (_, child) => Container(
                          color: (widget.card
                                      .images[_imageViewCtrl.page?.toInt() ?? 0]
                                  is CardImageLoading)
                              ? Colors.grey[850]
                              : Colors.black,
                          child: child,
                        ),
                      ),
                GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  onTapUp: (details) {
                    double width = MediaQuery.of(context).size.width;
                    int region = 1; // 0: left, 1: center, 2: right
                    if (details.globalPosition.dx > 2 * width / 3) {
                      region = 2;
                    } else if (details.globalPosition.dx < width / 3) {
                      region = 0;
                    }

                    int currentPage = _imageViewCtrl.page?.toInt() ?? 0;
                    if (region == 1) {
                      if (widget.card.images[currentPage] is CardImageError) {
                        // Tap to retry
                        widget.card.reloadImages();
                        return;
                      } else {
                        // Enlarge image
                        setState(() => _enlargeImg = !_enlargeImg);
                      }
                    } else {
                      int totalPages = widget.card.images.length;
                      int page = totalPages < 2
                          ? 0 // go back to first page
                          : (currentPage + (region == 2 ? 1 : -1)) % totalPages;

                      _imageViewCtrl.animateToPage(page,
                          duration: Duration(milliseconds: 250),
                          curve: Curves.easeInOut);
                    }
                  },
                  child: PageView(
                    controller: _imageViewCtrl,
                    children: widget.card.images.isEmpty
                        ? [Center(child: Text('No image for this insert'))]
                        : widget.card.images.map<Widget>((cardImage) {
                            if (cardImage is CardImageLoading) {
                              return Center(
                                  child: CircularProgressIndicator(
                                      // backgroundColor: Colors.green,
                                      ));
                            } else if (cardImage is CardImageLoaded) {
                              return Image.memory(
                                cardImage.bytes,
                                fit: BoxFit.contain,
                              );
                            } else if (cardImage is CardImageError) {
                              return Center(
                                child: Text(
                                    'Could not load image. Tap to retry',
                                    style: TextStyle(color: Colors.white)),
                              );
                            } else {
                              throw UnimplementedError();
                            }
                          }).toList(),
                  ),
                ),
                IgnorePointer(
                  child: Stack(
                    children: [
                      Container(
                        constraints: BoxConstraints.expand(),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xAA000000)],
                          stops: [0.5, 1],
                        )),
                      ),
                      AnimatedBuilder(
                        animation: _imageViewCtrl,
                        builder: (_, __) => PageIndicator(
                            _imageViewCtrl.page ?? 0,
                            widget.card.images.length),
                      ),
                      widget.card.images.length < 2
                          ? SizedBox()
                          : Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.chevron_left,
                                        color: Colors.white70, size: 32),
                                    Icon(Icons.chevron_right,
                                        color: Colors.white70, size: 32)
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  widget.card.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                CardQuickinfo(widget.card),
                SizedBox(height: 12),
                Text(
                  widget.card.description,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 96),
        ],
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  PageIndicator(this.page, this.pagesCount);

  final double page;
  final int pagesCount;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: (20 * pagesCount).toDouble(),
        // height: 20,
        margin: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(pagesCount, (index) {
            double factor = 0;
            if ((index - page).abs() < 1) {
              factor = (1 - (index - page).abs());
            }

            return Container(
              width: 12,
              height: 12,
              child: Center(
                child: Container(
                  height: 7 + 5 * factor,
                  width: 7 + 5 * factor,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white54.withOpacity(1 / 3 + 2 * factor / 3),
                  ),
                  child: SizedBox(),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class CardQuickinfo extends StatelessWidget {
  final Card card;

  const CardQuickinfo(this.card, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFF7F7F7),
          border: Border.all(color: Color(0xFFD9D9D9)),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Center(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '32'),
                    TextSpan(
                        text: ' qm', style: TextStyle(color: Colors.grey[700])),
                  ]),
                  // '32 qm',
                  style: TextStyle(
                    color: Colors.grey[800]!,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '310 €',
                  style: TextStyle(
                    color: Colors.grey[800]!,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '4',
                      style: TextStyle(
                        color: Colors.grey[800]!,
                        fontSize: 18,
                      ),
                    ),
                    Icon(Icons.person_outline, color: Colors.grey[700]),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class CardsFeedCardWidget extends StatelessWidget {
  final Card card;
  final double swipeAmount;

  CardsFeedCardWidget(this.card, this.swipeAmount)
      : super(key: ValueKey(card.hashCode));

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
        children: [
          CardWidget(card),
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
                    // ClipRRect(
                    //   child:
                    OverflowBox(
                      maxHeight: _phoneHeight * 1.5,
                      maxWidth: _phoneHeight * 1.5,
                      child: Container(
                        height: _phoneHeight *
                            1.3 *
                            pow(
                                Curves.easeInOutCubic
                                    .transform(swipeAmount.abs()),
                                1.2),
                        width: _phoneHeight *
                            1.3 *
                            pow(
                                Curves.easeInOutCubic
                                    .transform(swipeAmount.abs()),
                                1.2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                              Colors.grey[500],
                              _overlayColor,
                              Curves.easeInOutCirc
                                  .transform(min(swipeAmount.abs() * 1.3, 1))),
                        ),
                      ),
                      // ),
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
