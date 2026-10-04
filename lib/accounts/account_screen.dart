import 'dart:async';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/accounts/widgets/account/leveling_progress.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/core/websocket.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/debug_sheet.dart';
import 'package:island/core/config.dart';
import 'package:island/notifications/notification.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (isWideScreen(context)) return const SizedBox.shrink();
    return const AccountFeatureWidget();
  }
}

@RoutePage()
class AccountScreen extends HookConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    return AppBackground(
      isRoot: true,
      child: isWide
          ? SafeArea(
              child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: const AccountFeatureWidget(isAside: true),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Flexible(flex: 3, child: const AutoRouter()),
                ],
              ),
            )
          : const AutoRouter(),
    );
  }
}

class AccountFeatureWidget extends HookConsumerWidget {
  final bool isAside;
  const AccountFeatureWidget({super.key, this.isAside = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    final isDeveloperMode = ref.watch(developerModeProvider);

    final user = ref.watch(userInfoProvider);
    final notificationUnreadCount = ref.watch(notificationUnreadCountProvider);

    if (user.value == null || user.value == null) {
      return _UnauthorizedAccountScreen();
    }

    // Periodically refresh presence while app is in foreground.
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 60), (_) {
        if (context.mounted) {
          ref.invalidate(accountStatusProvider(user.value!.name));
        }
      });
      return timer.cancel;
    }, []);

    final theme = Theme.of(context);
    final account = user.value!;

    // The header tints its scrim with the background image's average color so
    // the title sits on a soft, colorful backdrop. White text keeps it legible;
    // with no background image the title falls back to the surface color.
    final serverUrl = ref.watch(serverUrlProvider);
    final headerBackground = account.profile.background;
    final headerTint = useState<Color?>(null);
    final scrollController = useScrollController();
    final headerCollapsed = useState(false);

    useEffect(() {
      final file = headerBackground;
      if (file == null) return null;
      var disposed = false;
      _imageAverageColor(
        CloudImageWidget.provider(file: file, serverUrl: serverUrl),
      ).then((color) {
        if (disposed) return;
        headerTint.value = color ?? Colors.black;
      });
      return () => disposed = true;
    }, [headerBackground?.id, serverUrl]);

    // Once the header has shrunk to its pinned toolbar, swap it to a solid
    // primary-colored app bar so the title stays readable instead of sitting
    // on a sliver of the background image.
    final collapsedBarHeight =
        kToolbarHeight + MediaQuery.paddingOf(context).top;
    final collapseThreshold = 220 - collapsedBarHeight;
    useEffect(() {
      void update() {
        if (!scrollController.hasClients) {
          headerCollapsed.value = false;
          return;
        }
        headerCollapsed.value =
            scrollController.position.pixels >= collapseThreshold;
      }

      scrollController.addListener(update);
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
      return () => scrollController.removeListener(update);
    }, [scrollController, collapseThreshold]);

    // Derive a "primary" color from the header image so the collapsed bar and
    // its title read as an extension of the backdrop.
    final hasHeaderImage = headerBackground != null;
    final headerScheme = headerTint.value == null
        ? null
        : ColorScheme.fromSeed(seedColor: headerTint.value!);
    final primary = headerScheme?.primary ?? theme.colorScheme.primary;
    final onPrimary = primary.computeLuminance() < 0.5
        ? Colors.white
        : Colors.black87;
    final headerTitleColor = headerCollapsed.value
        ? onPrimary
        : hasHeaderImage
        ? Colors.white.withOpacity(0.9)
        : theme.colorScheme.onSurface;

    return AppScaffold(
      isNoBackground: isWide,
      appBar: null,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            automaticallyImplyLeading: false,
            backgroundColor: headerCollapsed.value
                ? primary
                : theme.colorScheme.surface,
            foregroundColor: headerTitleColor,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: headerTitleColor,
                  fontWeight: FontWeight.w600,
                ),
                child: Text('account').tr(),
              ),
              background: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: headerCollapsed.value
                    ? ColoredBox(
                        key: const ValueKey('header-collapsed'),
                        color: primary,
                      )
                    : hasHeaderImage
                    ? Stack(
                        key: const ValueKey('header-image'),
                        fit: StackFit.expand,
                        children: [
                          CloudImageWidget(
                            file: account.profile.background,
                            fit: BoxFit.cover,
                            imageOnly: true,
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  (headerTint.value ?? Colors.black)
                                      .withOpacity(0.45),
                                  (headerTint.value ?? Colors.black)
                                      .withOpacity(0),
                                  (headerTint.value ?? Colors.black)
                                      .withOpacity(0.5),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ColoredBox(
                        key: const ValueKey('header-plain'),
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              spacing: 12,
              children: <Widget>[
                _AccountIdentityCard(account: account),
                if (user.value?.activatedAt == null)
                  AccountUnactivatedCard().padding(horizontal: 12, bottom: 4),
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      AccountStatusCreationWidget(uname: user.value!.name),
                      ActivityPresenceWidget(
                        uname: user.value!.name,
                        isCompact: true,
                        compactPadding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 8,
                          top: 4,
                        ),
                      ),
                    ],
                  ),
                ).padding(horizontal: 12, bottom: 4),
                CheckInWidget(
                  margin: EdgeInsets.zero,
                ).padding(horizontal: 12, bottom: 4),
                LevelingProgressCard(
                  isCompact: true,
                  level: user.value!.profile.level,
                  experience: user.value!.profile.experience,
                  progress: user.value!.profile.levelingProgress,
                ).padding(horizontal: 12),
                Builder(
                  builder: (context) {
                    final menuItems = [
                      {
                        'icon': Symbols.notifications,
                        'title': 'notifications',
                        'badgeCount': notificationUnreadCount.value ?? 0,
                        'onTap': () {
                          showAttentionModal(
                            id: 'notifications',
                            replaceIfExists: true,
                            barrierDismissible: true,
                            builder: (context, dismiss) =>
                                NotificationModal(onDismiss: dismiss),
                          );
                        },
                      },
                      {
                        'icon': Symbols.workspace_premium,
                        'title': 'progress',
                        'onTap': () {
                          context.router.push(ProgressRoute());
                        },
                      },
                      {
                        'icon': Symbols.trending_up,
                        'title': 'leveling',
                        'onTap': () {
                          context.router.push(const LevelingRoute());
                        },
                      },
                      {
                        'icon': Symbols.storefront,
                        'title': 'store',
                        'onTap': () {
                          context.router.push(const StoreRoute());
                        },
                      },
                      {
                        'icon': Symbols.handshake,
                        'title': 'meet',
                        'onTap': () {
                          context.router.push(const MeetRoute());
                        },
                      },
                      {
                        'icon': Symbols.qr_code_rounded,
                        'title': 'qrCode',
                        'onTap': () {
                          context.router.push(const AccountQrRoute());
                        },
                      },
                      {
                        'icon': Symbols.people,
                        'title': 'relationships',
                        'onTap': () {
                          context.router.push(const RelationshipRoute());
                        },
                      },
                      {
                        'icon': Symbols.sticker_rounded,
                        'title': 'stickers',
                        'onTap': () {
                          context.router.push(const StickerMarketplaceRoute());
                        },
                      },
                    ];
                    return Column(
                      children: menuItems.map((item) {
                        final icon = item['icon'] as IconData;
                        final title = item['title'] as String;
                        final badgeCount = item['badgeCount'] as int?;
                        final onTap = item['onTap'] as VoidCallback?;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          trailing: const Icon(Symbols.chevron_right),
                          dense: true,
                          leading: Badge(
                            isLabelVisible:
                                badgeCount != null && badgeCount > 0,
                            label: Text(badgeCount.toString()),
                            child: Icon(icon, size: 24),
                          ),
                          title: Text(title).tr(),
                          onTap: onTap,
                        );
                      }).toList(),
                    );
                  },
                ),
                const Divider(height: 1).padding(vertical: 8),
                ListTile(
                  leading: const Icon(Symbols.report),
                  trailing: const Icon(Symbols.chevron_right),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  dense: true,
                  title: Text('tickets').tr(),
                  onTap: () {
                    context.router.push(const TicketListRoute());
                  },
                ),
                ListTile(
                  leading: const Icon(Symbols.settings),
                  trailing: const Icon(Symbols.chevron_right),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  dense: true,
                  title: Text('appSettings').tr(),
                  onTap: () {
                    context.router.push(const SettingsRoute());
                  },
                ),
                ListTile(
                  leading: const Icon(Symbols.manage_accounts),
                  trailing: const Icon(Symbols.chevron_right),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  dense: true,
                  title: Text('accountSettings').tr(),
                  onTap: () {
                    context.router.push(const AccountSettingsRoute());
                  },
                ),
                const Divider(height: 1).padding(vertical: 8),
                if (isDeveloperMode)
                  ListTile(
                    leading: const Icon(Symbols.bug_report),
                    trailing: const Icon(Symbols.chevron_right),
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    title: Text('debugOptions').tr(),
                    dense: true,
                    onTap: () {
                      toggleDebugOverlay(ref);
                    },
                  ),
                ListTile(
                  leading: const Icon(Symbols.logout),
                  trailing: const Icon(Symbols.chevron_right),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  title: Text('logout').tr(),
                  dense: true,
                  onTap: () async {
                    final ws = ref.watch(websocketStateProvider.notifier);
                    final client = ref.watch(solarNetworkClientProvider);
                    showLoadingModal(context);
                    // Fire and forgot
                    client.auth.revokeCurrentSession();
                    await resetDatabase(ref);
                    if (!context.mounted) return;
                    hideLoadingModal(context);
                    final userNotifier = ref.read(userInfoProvider.notifier);
                    userNotifier.logOut();
                    ws.close();
                  },
                ),
              ],
            ).padding(top: 8, bottom: MediaQuery.of(context).padding.bottom),
          ),
        ],
      ),
    );
  }
}

class _UnauthorizedAccountScreen extends HookConsumerWidget {
  const _UnauthorizedAccountScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeveloperMode = ref.watch(developerModeProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('account').tr()),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  onTap: () {
                    context.router.push(const CreateAccountRoute());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Symbols.person_add, size: 48),
                        const SizedBox(height: 8),
                        Text('createAccount').tr().bold(),
                        Text('createAccountDescription').tr(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  onTap: () {
                    context.router.push(LoginRoute());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Symbols.login, size: 48),
                        const SizedBox(height: 8),
                        Text('login').tr().bold(),
                        Text('loginDescription').tr(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    context.router.push(const AboutRoute());
                  },
                  iconSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                  icon: const Icon(Icons.info, fill: 1),
                  tooltip: 'about'.tr(),
                ),
                if (isDeveloperMode)
                  IconButton(
                    icon: const Icon(Icons.bug_report, fill: 1),
                    onPressed: () {
                      toggleDebugOverlay(ref);
                    },
                    iconSize: 18,
                    color: Theme.of(context).colorScheme.secondary,
                    tooltip: 'debugOptions'.tr(),
                  ),
                IconButton(
                  onPressed: () {
                    context.router.push(const SettingsRoute());
                  },
                  icon: const Icon(Icons.settings, fill: 1),
                  iconSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                  tooltip: 'appSettings'.tr(),
                ),
              ],
            ),
          ],
        ),
      ).center(),
    );
  }
}

class _AccountIdentityCard extends StatelessWidget {
  final SnAccount account;

  const _AccountIdentityCard({required this.account});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            child: ProfilePictureWidget(
              file: account.profile.picture,
              fallbackName: account.nick,
              radius: 24,
            ),
            onTap: () {
              context.router.push(AccountProfileRoute(name: account.name));
            },
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: AccountName(
                        account: account,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '@${account.name}',
                      ).fontSize(11).padding(bottom: 2.5),
                    ),
                  ],
                ),
                Text(
                  (account.profile.bio.isNotEmpty)
                      ? account.profile.bio
                      : 'descriptionNone'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Average color of [provider]'s image, or null when it never resolves or
/// cannot be decoded. Pixels are sampled sparsely, so this stays cheap on
/// large headers.
Future<Color?> _imageAverageColor(ImageProvider provider) {
  final completer = Completer<Color?>();
  final stream = provider.resolve(const ImageConfiguration());
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, synchronousCall) {
      stream.removeListener(listener);
      // The stream owns [info.image]; clone before releasing it so the async
      // decode below does not race with its disposal.
      final image = info.image.clone();
      unawaited(() async {
        Color? value;
        try {
          value = await _averageColorOf(image);
        } catch (_) {
          value = null;
        } finally {
          image.dispose();
        }
        completer.complete(value);
      }());
    },
    onError: (error, stackTrace) {
      stream.removeListener(listener);
      completer.complete(null);
    },
  );
  stream.addListener(listener);
  return completer.future;
}

Future<Color?> _averageColorOf(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (data == null) return null;
  final bytes = data.buffer.asUint8List();
  // Every 32nd pixel: plenty for an average, cheap on big images.
  const step = 4 * 32;
  var rSum = 0;
  var gSum = 0;
  var bSum = 0;
  var count = 0;
  for (var i = 0; i + 3 < bytes.length; i += step) {
    if (bytes[i + 3] == 0) continue; // skip fully transparent pixels
    rSum += bytes[i];
    gSum += bytes[i + 1];
    bSum += bytes[i + 2];
    count++;
  }
  if (count == 0) return null;
  return Color.fromARGB(255, rSum ~/ count, gSum ~/ count, bSum ~/ count);
}
