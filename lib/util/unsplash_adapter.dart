import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class UnsplashAdapter {
  UnsplashAdapter._();
  static final UnsplashAdapter _instance = UnsplashAdapter._();
  static UnsplashAdapter get instance => _instance;

  List<UnsplashRequest> _requests = [];

  bool get hitRateLimit {
    DateTime now = DateTime.now();
    Duration oneHour = Duration(hours: 1);
    return _requests
            .where((request) => now.difference(request.time) < oneHour)
            .length >=
        50;
  }

  String get randomImageUrl =>
      "https://source.unsplash.com/collection/1540143/600x400?auto=format&fit=crop&w=400&q=80&sig=" +
      Random().nextInt(10000).toString();

  List<Uint8List> _cache = [];

  Uint8List? _getRandomCachedImage() =>
      _cache.length > 0 ? _cache[Random().nextInt(_cache.length)] : null;

  Future<Uint8List?> loadImage(String url) {
    var request = UnsplashRequest();
    _requests.add(request);
    print("loading image (req #${_requests.length})");
    if (hitRateLimit) {
      return Future.value(_getRandomCachedImage());
    } else if (_requests.isNotEmpty ? _requests.last.success == false : false) {
      // Last request unsuccessful
      return Future.value(_getRandomCachedImage());
    } else {
      return http.get(Uri.parse(url)).then(
        (response) {
          _cache.add(response.bodyBytes);
          request.success = true;
          return response.bodyBytes;
        },
        onError: ((_, __) {
          request.success = false;
          return null;
        }),
      );
    }
  }
}

class UnsplashRequest {
  final DateTime time;
  bool? success;

  UnsplashRequest({this.success}) : time = DateTime.now();
}
