import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/user_model.dart';
import 'package:flutter_recipes/providers/user_provider.dart';
import 'package:flutter_recipes/services/auth_service.dart';
import 'package:flutter_recipes/services/recipe_extraction_service.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recipes/services/logger.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_recipes/services/firestore_service.dart'; // Added this import
import 'package:showcaseview/showcaseview.dart'; // Added this import

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showEmailSignIn = false; // Add this line

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final backgroundColor = theme.colorScheme.background;
    final surfaceColor = theme.colorScheme.surface;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: primaryColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/emojis/smiling-dog-wearing-chefs-hat.png'),
                  ),
                ),
                const SizedBox(height: 20),
                if (_showEmailSignIn) ...[
                  _buildTextField(_emailController, 'Email'),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, 'Password', obscureText: true),
                  const SizedBox(height: 20),
                  _buildButton('Sign In', _signIn),
                  const SizedBox(height: 20),
                  _buildButton("Back", () => setState(() => _showEmailSignIn = false), icon: Icons.arrow_back),
                ] else ...[
                  _buildButton('Sign In with Google', _signInWithGoogle, icon: FontAwesomeIcons.google),
                  const SizedBox(height: 20),
                  _buildButton('Sign In with Email', () => setState(() => _showEmailSignIn = true)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.background;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: backgroundColor,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  Widget _buildButton(String label, void Function()? onPressed, {IconData? icon}) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    return Container(
      width: 300, // specify the width
      height: 50, // specify the height
      child: ElevatedButton.icon(
        icon: Icon(icon ?? Icons.check), // use the provided icon or a default one
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceColor,
          foregroundColor: onSurfaceColor,
          alignment: Alignment.center
          // padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
      ),
    );
  }

  void _handleFirstTimeSignIn(UserModel userModel) async {
    // If it's the user's first time signing in, alter the GlobalState
    final globalState = Provider.of<GlobalState>(context, listen: false);
    // Perform your operations on globalState here...

    // Moved from HomeScreen
    await RecipeExtractionService()
        .createInitialRecipes(userModel.id, FirestoreService());
    await Future.delayed(const Duration(milliseconds: 200));
    await globalState.selectDefaultRecipes();
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      Logger().log("Attempting to sign in");
      String result = await context.read<AuthenticationService>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        context: context,
      );
      Logger().log("Sign in result: $result");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));

      // After signing in, check if it's the user's first time signing in
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userModel = userProvider.user;
      if (userModel != null && userModel.metadata.signInCount == 0) {
        _handleFirstTimeSignIn(userModel);
      }
    }
  }

  void _signInWithGoogle() async {
    Logger().log("Attempting to sign in with Google");
    String result = await context.read<AuthenticationService>().signInWithGoogle(context: context);
    Logger().log("Sign in with Google result: $result");

    // After signing in, check if it's the user's first time signing in
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userModel = userProvider.user;
    if (userModel != null && userModel.metadata.signInCount == 0) {
      _handleFirstTimeSignIn(userModel);
    }
  }
}