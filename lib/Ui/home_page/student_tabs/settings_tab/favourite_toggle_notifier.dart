import 'dart:async';

/// Notifier for favourite toggle events across tabs
/// Broadcasts courseId and new isFavourite state when a course is toggled
class FavouriteToggleNotifier {
  static final FavouriteToggleNotifier _instance =
      FavouriteToggleNotifier._internal();

  factory FavouriteToggleNotifier() => _instance;

  FavouriteToggleNotifier._internal();

  final _controller = StreamController<FavouriteToggleEvent>.broadcast();

  Stream<FavouriteToggleEvent> get stream => _controller.stream;

  void notify(String courseId, bool isFavourite) {
    print(
        '📢 [NOTIFIER] Broadcasting event: courseId=$courseId, isFavourite=$isFavourite');
    _controller.add(FavouriteToggleEvent(courseId, isFavourite));
  }

  void dispose() {
    _controller.close();
  }
}

class FavouriteToggleEvent {
  final String courseId;
  final bool isFavourite;

  FavouriteToggleEvent(this.courseId, this.isFavourite);
}
