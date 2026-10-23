/// The identity console's shared sign-in page.
///
/// Kept apart from the browser plumbing so the address can be built — and
/// tested — without a browser: the console hands a finished sign-in back to
/// whatever address it was given, so the query has to be assembled exactly
/// once, in one place.
library;

/// Where the console serves the shared sign-in page.
///
/// It is a different origin from the API, so it cannot be derived from the
/// configured server. A self-hosted pair points it elsewhere at build time:
/// `--dart-define=SHARED_SIGN_IN_URL=https://id.example.com/sign-in`.
const String kSharedSignInPage = String.fromEnvironment(
  'SHARED_SIGN_IN_URL',
  defaultValue: 'https://id.solian.app/sign-in',
);

/// [page] with `redirectUri` set to [returnTo].
///
/// A relative return address cannot be handed to another origin, so it is
/// dropped rather than guessed at; the console then falls back to its own
/// account page.
String buildSharedSignInUrl(String page, Uri returnTo) {
  final target = Uri.tryParse(page);
  if (target == null || !target.hasScheme || target.host.isEmpty) {
    return page;
  }
  if (!returnTo.hasScheme || returnTo.host.isEmpty) {
    return target.toString();
  }
  return target
      .replace(
        queryParameters: {
          ...target.queryParameters,
          'redirectUri': returnTo.toString(),
        },
      )
      .toString();
}
