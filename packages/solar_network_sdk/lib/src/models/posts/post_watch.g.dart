// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_watch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPostWatchPreference _$SnPostWatchPreferenceFromJson(
  Map<String, dynamic> json,
) => _SnPostWatchPreference(
  source: $enumDecode(_$PostWatchSourceEnumMap, json['source']),
  notifyReactions: json['notify_reactions'] as bool? ?? true,
  notifyReplies: json['notify_replies'] as bool? ?? true,
  notifyChains: json['notify_chains'] as bool? ?? true,
  notifyForwards: json['notify_forwards'] as bool? ?? true,
  notifyEdits: json['notify_edits'] as bool? ?? true,
);

Map<String, dynamic> _$SnPostWatchPreferenceToJson(
  _SnPostWatchPreference instance,
) => <String, dynamic>{
  'source': _$PostWatchSourceEnumMap[instance.source]!,
  'notify_reactions': instance.notifyReactions,
  'notify_replies': instance.notifyReplies,
  'notify_chains': instance.notifyChains,
  'notify_forwards': instance.notifyForwards,
  'notify_edits': instance.notifyEdits,
};

const _$PostWatchSourceEnumMap = {
  PostWatchSource.bookmark: 'bookmark',
  PostWatchSource.reaction: 'reaction',
  PostWatchSource.reply: 'reply',
};
