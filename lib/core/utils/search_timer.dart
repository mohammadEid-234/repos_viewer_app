import 'dart:async';
import 'dart:ui';

class SearchTimer{
  /*
   this class prevents search on every character , instead it waits for
   period after the user has stopped typing
   */
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  SearchTimer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer!=null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}