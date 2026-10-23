import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:island/core/session_cookie.dart';

/// Points a browser visitor at the console's shared sign-in page.
///
/// The web build shares the `solian.app` cookie with `id.solian.app`, so a
/// person who signs in there comes back already signed in here. That page also
/// carries the factors this in-app form does not — QR approval from a phone,
/// third-party identities, account recovery — which makes it the better door
/// for someone who does not have a password handy. Native builds never show
/// this: they have no cookie jar to share.
class SharedSignInCard extends StatelessWidget {
  const SharedSignInCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.secondaryContainer,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.open_in_new,
              size: 20,
              color: scheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    'loginSharedSignInTitle'.tr(),
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'loginSharedSignInDescription'.tr(),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSecondaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: openSharedSignIn,
              style: TextButton.styleFrom(
                foregroundColor: scheme.onSecondaryContainer,
                visualDensity: VisualDensity.compact,
              ),
              child: Text('loginSharedSignInAction'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
