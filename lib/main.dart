import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/firebase_options.dart';
import 'package:flutter_recipes/providers/ui/nav_provider.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_filter_provider.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/providers/models/recipes/selected_recipes_provider.dart';
import 'package:flutter_recipes/providers/models/shopping_lists/selected_shopping_list_provider.dart';
import 'package:flutter_recipes/providers/models/shopping_lists/shopping_list_provider.dart';
import 'package:flutter_recipes/providers/ui/showcaseview_provider.dart';
import 'package:flutter_recipes/providers/ui/ui_provider.dart';
import 'package:flutter_recipes/services/business/ad_service.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'package:flutter_recipes/services/business/recipe_service.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Added this line
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:showcaseview/showcaseview.dart'; // Added this line

import 'providers/models/user/user_provider.dart';
import 'routes.dart'; // Import routes.dart
import 'services/firebase/auth_service.dart';
import 'services/logging/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize the Mobile Ads SDK. // Added this line
  MobileAds.instance.initialize(); // Added this line

  // Instantiate Firebase modules
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFunctions functions = FirebaseFunctions.instance;
  AuthenticationService authService = AuthenticationService(auth);

  Logger logger = Logger();
  bool useFirebaseEmulator =
      const bool.fromEnvironment('USE_FIREBASE_EMULATOR');
  logger.log('USE_FIREBASE_EMULATOR is $useFirebaseEmulator');

  if (useFirebaseEmulator) {
    firestore.settings = const Settings(
      host: 'localhost:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );
    auth.useAuthEmulator('localhost', 9099);
    functions.useFunctionsEmulator('localhost', 5001);
    storage.useStorageEmulator('localhost', 9199);

    // Use Firestore emulator
    firestore.useFirestoreEmulator('localhost', 8080);

    // Create a 'session' document with the current timestamp
    firestore.collection('sessions').add({
      'started': Timestamp.now(),
    });
  }

  // Initialize providers with dependencies

  // User Provider
  UserProvider userProvider = UserProvider(); // Added this line

  // Firestore Service
  FirestoreService firestoreService = FirestoreService();

  // Ad Service
  AdService adService = AdService();

  // Recipe Providers
  RecipeProvider recipeProvider = RecipeProvider(userProvider: userProvider);
  RecipeService recipeService = RecipeService(
      firestoreService: firestoreService,
      userProvider: userProvider,
      adService: adService,
      recipeProvider: recipeProvider);
  SelectedRecipeProvider selectedRecipeProvider = SelectedRecipeProvider(
      recipeProvider: recipeProvider, recipeService: recipeService);
  RecipeFilterProvider recipeFilterProvider = RecipeFilterProvider();

  // Shopping List Providers
  ShoppingListProvider shoppingListProvider =
      ShoppingListProvider(userProvider: userProvider);
  SelectedShoppingListProvider selectedShoppingListProvider =
      SelectedShoppingListProvider();

  // UI Provider
  UIProvider uiProvider = UIProvider();

  // Nav
  NavProvider navProvider = NavProvider();

  // Showcase
  ShowcaseProvider showcaseProvider = ShowcaseProvider();

  runApp(
    // COmment
    ShowCaseWidget(
      builder: Builder(
        builder: (context) => MultiProvider(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider(
              create: (context) => userProvider, // Modified this line
            ),
            Provider<AuthenticationService>(
              create: (context) => authService,
            ),
            ChangeNotifierProvider(
              create: (context) => navProvider,
            ),
            ChangeNotifierProvider(
                create: (context) => GlobalState(userProvider)),
            ChangeNotifierProvider(create: (context) => adService),
            ChangeNotifierProvider(
              create: (context) => recipeProvider,
            ),
            ChangeNotifierProvider(
              create: (context) => selectedRecipeProvider,
            ),
            ChangeNotifierProvider(
              create: (context) => recipeFilterProvider,
            ),
            ChangeNotifierProvider(
              create: (context) => shoppingListProvider,
            ),
            ChangeNotifierProvider(
              create: (context) => selectedShoppingListProvider,
            ),
            ChangeNotifierProvider(
              create: (context) => uiProvider,
            ),
            ChangeNotifierProvider(
              create: (context) => showcaseProvider,
            ),
          ],
          child: const MyApp(),
        ),
      ), // Added this line
    ), // Added this line
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: MyTheme.theme,
      initialRoute: '/',
      onGenerateRoute:
          Routes.generateRoute, // Use the Routes.generateRoute function
    );
  }
}

class MyTheme {
  static ThemeData get theme => ThemeData(
      colorScheme: const ColorScheme(
        primary: Color(0xFFff9102),
        secondary: Color(0xFF419D78),
        background: Color(0xFF648DE5),
        surface: Color(0xFFFFFFFF),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      useMaterial3: true);
}
