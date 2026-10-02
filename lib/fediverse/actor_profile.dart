import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:island/posts/screens/publisher_profile.dart';
import 'package:island/shared/widgets/app_scaffold.dart';

/// Deep link target for a remote fediverse actor.
///
/// Remote actors are mirrored as publishers, so this renders the shared
/// publisher profile with the actor id. The route is kept so old links,
/// notifications and share targets keep working.
@RoutePage()
class FediverseActorProfileScreen extends HookConsumerWidget {
  final String id;
  final String? fullHandle;

  const FediverseActorProfileScreen({
    super.key,
    @PathParam("id") required this.id,
    this.fullHandle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisher = ref.watch(publisherProvider(id));

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text(
          publisher.value?.effectiveName ?? fullHandle ?? '@$id',
        ),
      ),
      body: PublisherProfileContent(name: id),
    );
  }
}
