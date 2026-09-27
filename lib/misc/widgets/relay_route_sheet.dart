import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/network/relay.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

/// Name shown for a relay: its region, or the leading label of the host when
/// the catalog did not announce a region.
///
/// Regions are airport codes — `can` is Guangzhou — so a code is looked up in
/// the translation files (`relayRegionCAN`) and falls back to the code itself,
/// which a reader can still place. Anything that is not a three-letter code is
/// already a name and is shown as it arrived.
String relayDisplayName(String region, String host) {
  final trimmed = region.trim();
  if (trimmed.isNotEmpty) {
    if (!_looksLikeAirportCode(trimmed)) return trimmed;
    final code = trimmed.toUpperCase();
    final key = 'relayRegion$code';
    final localized = key.tr();
    return localized == key ? code : localized;
  }
  final label = host.split('.').first;
  return label.isEmpty ? host : label;
}

/// Whether [region] is an airport code rather than a name someone wrote out.
bool _looksLikeAirportCode(String region) =>
    region.length == 3 && RegExp(r'^[A-Za-z]{3}$').hasMatch(region);

/// Picks the relay the app dials through.
///
/// Reads [relayRouteProvider] for the current choice, [activeRelayRouteProvider]
/// for the choice as it will actually be dialed, [relayCatalogProvider] for the
/// announced relays, and [relayProbeResultsProvider] for what each of them
/// measures — the catalog is fetched over a direct connection, so this sheet
/// still works while the selected relay is down.
///
/// One accent per selected row and one alert mark per unhealthy relay: a
/// healthy relay is silent, which keeps a long catalog quiet to scan. A
/// measured round trip is the only other thing a row says.
class RelayRouteSheet extends ConsumerWidget {
  const RelayRouteSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(activeRelayRouteProvider);
    final suspended = ref.watch(relaySuspensionProvider);
    final catalog = ref.watch(relayCatalogProvider);
    final probes = ref.watch(relayProbeResultsProvider);
    final scheme = Theme.of(context).colorScheme;
    final report = probes.value;

    void select(RelayRoute? route) {
      ref.read(relayRouteProvider.notifier).select(route);
      Navigator.of(context).pop();
    }

    return SheetScaffold(
      titleText: 'settingsRelayRoute'.tr(),
      actions: [
        // The error state carries its own retry, so the header drops the
        // duplicate action instead of offering two ways to do one thing.
        if (!catalog.hasError)
          IconButton(
            tooltip: 'refresh'.tr(),
            onPressed: catalog.isLoading
                ? null
                : () => ref.read(relayCatalogProvider.notifier).refresh(),
            icon: catalog.isLoading
                ? const _Spinner()
                : const Icon(Symbols.refresh),
          ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(
              'settingsRelayRouteHelper'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
          // The app dropped the chosen node itself: without this the picker
          // would look like it simply ignored the selection.
          if (suspended != null)
            _SheetNotice(
              icon: Symbols.link_off,
              title: 'settingsRelayRouteSuspended'.tr(
                args: [relayDisplayName(suspended.route.region, suspended.route.host)],
              ),
              detail: '${suspended.error}',
              action: TextButton.icon(
                // Re-selecting is the retry, and it closes the sheet like any
                // other selection: the notice has said what happened.
                onPressed: () => select(suspended.route),
                icon: const Icon(Symbols.refresh, size: 18),
                label: Text('settingsRelayRouteRetry'.tr()),
              ),
            ),
          _RelayOption(
            icon: Symbols.public,
            title: 'settingsRelayRouteDirect'.tr(),
            subtitle: 'settingsRelayRouteDirectHelper'.tr(),
            selected: selected == null,
            latency: report?.direct.latency,
            silent: probes.hasValue && report!.direct.reachable == false,
            onTap: () => select(null),
          ),
          ..._buildCatalog(context, ref, catalog, probes, selected, select),
        ],
      ),
    );
  }

  List<Widget> _buildCatalog(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<RelayEntry>> catalog,
    AsyncValue<RelayProbeReport> probes,
    RelayRoute? selected,
    void Function(RelayRoute?) select,
  ) {
    return catalog.when(
      loading: () => const [_RelayCatalogSkeleton()],
      error: (error, _) => [
        _SheetNotice(
          icon: Symbols.cloud_off,
          title: 'settingsRelayRouteError'.tr(),
          detail: error is RelayCatalogException ? error.message : '$error',
          action: TextButton.icon(
            onPressed: () => ref.read(relayCatalogProvider.notifier).refresh(),
            icon: const Icon(Symbols.refresh, size: 18),
            label: Text('retry'.tr()),
          ),
        ),
      ],
      data: (entries) {
        final currentId = selected?.id;
        final announced = entries.any((entry) => entry.id == currentId);
        final current = selected;
        final report = probes.value;
        // Direct is a candidate like any relay: when it is the fastest one, the
        // picker takes it.
        final fastest = report?.fastest;
        final probing = probes.isLoading;

        return [
          // A route picked from an earlier catalog may not be announced
          // anymore; keep it visible so the selection is never invisible.
          if (current != null && !announced)
            _RelayOption(
              icon: Symbols.help,
              title: relayDisplayName(current.region, current.host),
              subtitle: current.displayHost,
              selected: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          if (entries.isEmpty)
            _SheetNotice(
              icon: Symbols.dns,
              title: 'settingsRelayRouteEmpty'.tr(),
            ),
          if (entries.isNotEmpty)
            _RelayOption(
              icon: Symbols.speed,
              title: 'settingsRelayRouteAuto'.tr(),
              subtitle: probing
                  ? 'settingsRelayRouteProbing'.tr()
                  : fastest == null
                  ? 'settingsRelayRouteProbeFailed'.tr()
                  : 'settingsRelayRouteAutoHelper'.tr(),
              selected: false,
              // Measuring, or nothing answered: there is no best yet, so the
              // row says so instead of pretending to be pickable.
              onTap: fastest == null
                  ? null
                  : () => select(fastest.route),
              trailing: probing ? const _Spinner() : null,
            ),
          for (final entry in entries)
            _RelayOption(
              icon: Symbols.dns,
              title: relayDisplayName(entry.region, entry.endpoint),
              subtitle: entry.displayEndpoint,
              selected: currentId == entry.id,
              warning: entry.healthy
                  ? null
                  : 'settingsRelayRouteUnhealthy'.tr(),
              latency: report?.forId(entry.id)?.latency,
              silent:
                  probes.hasValue &&
                  report?.forId(entry.id)?.reachable == false,
              onTap: () => select(RelayRoute.fromEntry(entry)),
            ),
        ];
      },
    );
  }
}

/// One pickable route: where it is, and what it is.
class _RelayOption extends StatelessWidget {
  const _RelayOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.warning,
    this.latency,
    this.silent = false,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;

  /// Runs when the row is picked; null renders the row as unavailable.
  final VoidCallback? onTap;

  /// Localized status for a relay worth avoiding, shown after the subtitle.
  final String? warning;

  /// Round trip of the last probe, shown when the relay answered.
  final Duration? latency;

  /// Whether the last probe finished without an answer, so an unmeasured row
  /// is not confused with a measured one.
  final bool silent;

  /// Replaces the status marks entirely, for a row that is working.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final warning = this.warning;
    final latency = this.latency;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
      // Round trips line up in a column, like the hosts beside them.
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return ListTile(
      selected: selected,
      onTap: onTap,
      minLeadingWidth: 32,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      tileColor: selected ? scheme.primary.withValues(alpha: 0.10) : null,
      leading: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        warning == null ? subtitle : '$subtitle · $warning',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
          // Hosts and ports line up in a column, like the route table they are.
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      trailing:
          trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (latency != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text('${latency.inMilliseconds} ms', style: labelStyle),
                )
              else if (silent)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text('—', style: labelStyle),
                ),
              if (warning != null)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: scheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              if (selected)
                Icon(Symbols.check, size: 20, color: scheme.primary),
            ],
          ),
    );
  }
}

/// The empty and error states: one icon, one line, optional detail and action.
class _SheetNotice extends StatelessWidget {
  const _SheetNotice({
    required this.icon,
    required this.title,
    this.detail,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final detail = this.detail;
    final action = this.action;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(icon, size: 18, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
            ],
          ),
          if (detail != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 4, 0, 0),
              child: Text(
                detail,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          if (action != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 0, 0),
              child: action,
            ),
        ],
      ),
    );
  }
}

/// Placeholder rows for the first catalog load. Deliberately still: the header
/// spinner already carries the "working" signal.
class _RelayCatalogSkeleton extends StatelessWidget {
  const _RelayCatalogSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bar = scheme.onSurfaceVariant.withValues(alpha: 0.12);

    Widget line(double width) => Container(
      width: width,
      height: 9,
      decoration: BoxDecoration(
        color: bar,
        borderRadius: BorderRadius.circular(5),
      ),
    );

    Widget row() => Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: bar, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [line(110), const SizedBox(height: 8), line(190)],
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: 'loading'.tr(),
      child: Column(children: [row(), row(), row()]),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
