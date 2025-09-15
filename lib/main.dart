import 'package:flutter/material.dart';
import 'package:new_recipe_app/di/di.dart';
import 'package:new_recipe_app/models/recipe.dart';
import 'package:new_recipe_app/models/recipetype.dart';
import 'package:new_recipe_app/pages/recipe_edit_page.dart';
import 'package:new_recipe_app/providers/user_provider.dart';
import 'package:new_recipe_app/theme/main_theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'services/hive_service.dart';
import 'providers/recipe_provider.dart';
import 'pages/recipe_list_page.dart';
import 'pages/login_page.dart';
import 'pages/recipe_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await setupDependencies();

  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: Builder(builder: (context) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        final GoRouter router = GoRouter(
          refreshListenable: userProvider,
          initialLocation: '/',
          // redirect: (context, state) {
          //   final loggedIn = userProvider.isLoggedIn;
          //   final loggingIn = state.matchedLocation == '/login';

          //   if (!loggedIn && !loggingIn) return '/login';
          //   if (loggedIn && loggingIn) return '/';
          //   return null;
          // },
          routes: [
            GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => RecipeListPage()),
            GoRoute(
              path: '/recipe/detail/:id',
              builder: (context, state) {
                final recipeId = state.pathParameters['id']!;
                final types = state.extra as List<RecipeType>;
                return RecipeDetailPage(recipeId: recipeId, types: types);
              },
            ),
            GoRoute(
              path: '/recipe/edit',
              builder: (context, state) {
                final extras = state.extra as Map<String, dynamic>;
                final types = extras['types'] as List<RecipeType>;
                final recipe = extras['recipe'] as Recipe?;
                return RecipeEditPage(recipe: recipe, types: types);
              },
            ),
            GoRoute(path: '/login', builder: (context, state) => LoginPage()),
          ],
        );

        return MaterialApp.router(
          theme: recipeAppTheme,
          routerConfig: router,
        );
      }),
    );
  }
}
