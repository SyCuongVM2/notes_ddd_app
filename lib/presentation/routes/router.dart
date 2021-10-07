import 'package:auto_route/auto_route.dart';

import '../pages/splash/splash_page.dart';
import '../pages/sign_in/sign_in_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute> [
    AutoRoute(page: SplashPage, initial: true),
    AutoRoute(page: SignInPage),
  ],
)
class $AppRouter {}