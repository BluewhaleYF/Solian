import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_watch.freezed.dart';
part 'post_watch.g.dart';

/// Where a post watch comes from. Bookmarking, reacting to, or replying to a
/// post makes the acting account a watcher of that post.
enum PostWatchSource {
  @JsonValue('bookmark')
  bookmark,
  @JsonValue('reaction')
  reaction,
  @JsonValue('reply')
  reply,
}

/// Per-account notification filters for one watch source.
///
/// Filters are not per post: one `reaction` setting covers every post the
/// account reacted to. The server returns effective values, defaults included.
@freezed
sealed class SnPostWatchPreference with _$SnPostWatchPreference {
  const factory SnPostWatchPreference({
    required PostWatchSource source,
    @Default(true) bool notifyReactions,
    @Default(true) bool notifyReplies,
    @Default(true) bool notifyChains,
    @Default(true) bool notifyForwards,
    @Default(true) bool notifyEdits,
  }) = _SnPostWatchPreference;

  factory SnPostWatchPreference.fromJson(Map<String, dynamic> json) =>
      _$SnPostWatchPreferenceFromJson(json);
}
