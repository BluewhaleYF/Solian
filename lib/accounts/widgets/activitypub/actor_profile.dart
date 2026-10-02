import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Avatar of a publisher, including remote fediverse actors.
///
/// Remote actors carry a plain [SnPublisher.avatarUrl] while local
/// publishers store a cloud file, so both are handled here.
class ActorPictureWidget extends StatelessWidget {
  final SnPublisher actor;
  final double radius;

  const ActorPictureWidget({super.key, required this.actor, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = actor.avatarUrlOrPicture;
    final instanceIconUrl = actor.instance?.iconUrl;
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Icon(
          Symbols.person,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (!actor.isFediverse) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
      );
    }

    return Stack(
      children: [
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(avatarUrl),
          radius: radius,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: CircleAvatar(
            backgroundImage: instanceIconUrl != null
                ? CachedNetworkImageProvider(instanceIconUrl)
                : null,
            radius: radius * 0.4,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: instanceIconUrl == null
                ? Icon(
                    Symbols.public,
                    size: radius * 0.6,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
