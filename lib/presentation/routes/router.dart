import 'package:auto_route/auto_route.dart';

import '../pages/notes/note_form/note_form_page.dart';
import '../pages/notes/notes_overview/notes_overview_page.dart';
import '../pages/splash/splash_page.dart';
import '../pages/sign_in/sign_in_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute> [
    AutoRoute(page: SplashPage, initial: true),
    AutoRoute(page: SignInPage),
    AutoRoute(page: NotesOverviewPage),
    AutoRoute(page: NoteFormPage, fullscreenDialog: true),
  ],
)
class $AppRouter {}