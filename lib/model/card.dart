import 'dart:typed_data';

import 'package:find_wg/util/networkmanager.dart';
import 'package:flutter/widgets.dart';

enum Reaction { LIKE, DISLIKE, SKIP }

class CardFeedProvider with ChangeNotifier {
  static const int MIN_CACHE_SIZE = 5;
  final NetworkManager _networkManager = NetworkManager.getInstance();
  final List<Card> _cache = [];

  CardFeedProvider() {
    preloadNext(count: 5);
  }

  void preloadNext({int? count}) {
    int _count = count ?? _cache.length + MIN_CACHE_SIZE;
    for (int i = 0; i < _count; i++) {
      _cache.add(_networkManager.loadCard());
    }
  }

  bool get isEmpty => _cache.isEmpty;

  int get length => _cache.length;

  Card operator [](int index) => elementAt(index);

  Card elementAt(int index) {
    if (_cache.length < MIN_CACHE_SIZE) {
      preloadNext();
    } else if (_cache.length < index) {
      preloadNext(count: _cache.length + index);
    }
    return _cache[index];
  }

  void like() {
    _networkManager.saveReaction(Reaction.LIKE, _cache.removeAt(0));
    notifyListeners();
  }

  void dislike() {
    _networkManager.saveReaction(Reaction.LIKE, _cache.removeAt(0));
    notifyListeners();
  }
}

class Card {
  final String title;
  final String description;
  final List<CardImage> images;
  final bool highlighted;

  Card(this.title, this.description,
      {List<String>? images, this.highlighted = false})
      : this.images =
            images?.map<CardImage>((url) => CardImageLoading(url)).toList() ??
                [] {
    _loadImages();
  }

  void _loadImages() {
    for (int i = 0; i < this.images.length; i++) {
      CardImage image = this.images[i];
      if (image is CardImageLoading) {
        image.load(onComplete: (completedImage) {
          this.images.removeAt(i);
          this.images.insert(i, completedImage);
        });
      }
    }
  }
}

abstract class CardImage {}

class CardImageLoading extends CardImage {
  final String url;

  CardImageLoading(this.url);

  void load({required void Function(CardImage) onComplete}) {
    NetworkManager.getInstance().loadImage(this.url).then((bytes) {
      onComplete(CardImageLoaded(bytes));
    });
  }
}

class CardImageError extends CardImage {}

class CardImageLoaded extends CardImage {
  final Uint8List bytes;

  CardImageLoaded(this.bytes);
}
