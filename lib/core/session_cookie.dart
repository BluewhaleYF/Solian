/// Browser cookie-jar support for the shared Solar Network sign-in.
///
/// On the web the console at `id.solian.app` signs a person in and sets the
/// `AuthToken` cookie for the whole `solian.app` domain, so this app's API
/// already answers the cookie. These helpers opt a Dio client into sending
/// that cookie, trade it for the token pair this client uses everywhere else,
/// and end it on sign-out. A native build has no such jar, so every helper is
/// a no-op there and the app keeps its own in-app sign-in.
library;

export 'session_cookie_stub.dart'
    if (dart.library.html) 'session_cookie_web.dart';
