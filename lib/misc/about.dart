import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/misc/about_content.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/page_app_bar.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusTop = MediaQuery.paddingOf(context).top;
    // The pill always floats over the content (see [AppScaffold]): its
    // `preferredSize` already includes the status-bar inset, so the scaffold
    // must not reserve a second one. [AboutContent] scrolls, so it starts
    // below the bar's band and slides up under the glass as it scrolls.
    return AppScaffold(
      isNoBackground: false,
      appBarOverContent: true,
      appBar: PillAppBar(
        statusTop: statusTop,
        child: Row(
          children: [
            const SolDrawerButton(),
            const Gap(SolSpace.sm),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'about'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        // The pill floats over the page, so the band it occupies is taken out
        // of the content by hand.
        padding: EdgeInsets.only(top: statusTop + kPillAppBarHeight),
        child: const AboutContent(),
      ),
    );
  }
}
