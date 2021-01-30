import 'dart:math';

import 'package:flutter/material.dart' hide Card;
import 'package:find_wg/model/card.dart';

class CardWidget extends StatefulWidget {
  final Card card;

  CardWidget(this.card);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  late final PageController _imageViewCtrl;

  @override
  void initState() {
    super.initState();
    _imageViewCtrl = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            height: min(240, MediaQuery.of(context).size.height * 0.4),
            color: Colors.grey[300],
            child: widget.card.images.isEmpty
                ? Text('No image for this insert')
                : GestureDetector(
                    onTap: () {
                      int page = (_imageViewCtrl.page?.toInt() ?? 0) ==
                              widget.card.images.length - 1
                          ? 0
                          : (_imageViewCtrl.page?.toInt() ?? 0) + 1;

                      _imageViewCtrl.animateToPage(page,
                          duration: Duration(milliseconds: 250),
                          curve: Curves.easeInOut);
                    },
                    child: PageView(
                      controller: _imageViewCtrl,
                      children: widget.card.images.map((cardImage) {
                        if (cardImage is CardImageLoading) {
                          return Center(child: Text('Loading...'));
                        } else if (cardImage is CardImageLoaded) {
                          return Image.memory(cardImage.bytes,
                              fit: BoxFit.fill);
                        } else {
                          throw UnimplementedError();
                        }
                      }).toList(),
                    ),
                  ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.card.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  widget.card.description,
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

class CardsFeedCardWidget extends StatelessWidget {
  final Card card;
  final double swipeAmount;

  CardsFeedCardWidget(this.card, this.swipeAmount);

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
