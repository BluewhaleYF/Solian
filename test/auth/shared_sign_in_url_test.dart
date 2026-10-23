import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/shared_sign_in_url.dart';

/// The console signs a person in and then hands the browser back to the address
/// it was given. That address is the only thing tying the two origins together,
/// so it has to be exact: a wrong one drops the person on the console's account
/// page with the app still signed out.
void main() {
  const page = 'https://id.solian.app/sign-in';

  test('hands the page being left to the console as redirectUri', () {
    final url = Uri.parse(
      buildSharedSignInUrl(page, Uri.parse('https://web.solian.app/home?x=1')),
    );
    expect(url.origin, 'https://id.solian.app');
    expect(url.path, '/sign-in');
    expect(
      url.queryParameters['redirectUri'],
      'https://web.solian.app/home?x=1',
    );
  });

  test('keeps the page address when the return address is not absolute', () {
    expect(
      buildSharedSignInUrl(page, Uri.parse('relative/path')),
      'https://id.solian.app/sign-in',
    );
  });

  test('survives a malformed page address instead of throwing', () {
    expect(buildSharedSignInUrl('not a url', Uri.parse('https://a.example')), 'not a url');
  });
}
