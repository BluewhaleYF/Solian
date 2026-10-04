import 'package:auto_route/auto_route.dart';
import 'package:island/route.gr.dart';
import 'package:material_ui/material_ui.dart';

class AccountPfcRegion extends StatelessWidget {
  final String? uname;
  final Widget child;

  const AccountPfcRegion({super.key, required this.uname, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (uname != null) {
          showAccountProfileCard(context, uname!);
        }
      },
      child: child,
    );
  }
}

Future<void> showAccountProfileCard(BuildContext context, String uname) async {
  await context.router.push(AccountProfileRoute(name: uname));
}
