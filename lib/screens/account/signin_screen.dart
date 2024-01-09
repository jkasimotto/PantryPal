import 'package:flutter/material.dart';
import 'package:flutter_recipes/services/firebase/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recipes/services/logging/logger.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Added this import

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
                    child: Image.asset(
                        'assets/emojis/smiling-dog-wearing-chefs-hat.png'),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Fridge Friend',
                  style: GoogleFonts.roboto(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimary,
                  ),
                ), // Added this line
                const SizedBox(height: 20),
                if (_showEmailSignIn) ...[
                  _buildTextField(_emailController, 'Email'),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, 'Password',
                      obscureText: true),
                  const SizedBox(height: 20),
                  _buildButton('Sign In', _signIn),
                  const SizedBox(height: 20),
                  _buildButton(
                      "Back", () => setState(() => _showEmailSignIn = false),
                      icon: Icons.arrow_back),
                ] else ...[
                  _buildButton('Sign In with Apple', _signInWithApple,
                      icon: FontAwesomeIcons.apple), // Added this line
                  const SizedBox(height: 20),
                  _buildButton('Sign In with Google', _signInWithGoogle,
                      icon: FontAwesomeIcons.google),
                  const SizedBox(height: 20),
                  _buildButton('Sign In with Email',
                      () => setState(() => _showEmailSignIn = true)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
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

  Widget _buildButton(String label, void Function()? onPressed,
      {IconData? icon}) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    return Container(
      width: 300, // specify the width
      height: 50, // specify the height
      child: ElevatedButton.icon(
        icon:
            Icon(icon ?? Icons.check), // use the provided icon or a default one
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

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      Logger().log("Attempting to sign in");
      String result = await context.read<AuthenticationService>().signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            context: context,
          );
      Logger().log("Sign in result: $result");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }
  }

  void _signInWithGoogle() async {
    Logger().log("Attempting to sign in with Google");
    String result = await context
        .read<AuthenticationService>()
        .signInWithGoogle(context: context);
    Logger().log("Sign in with Google result: $result");
  }

  void _signInWithApple() async {
    Logger().log("Attempting to sign in with Apple");
    String result = await context.read<AuthenticationService>().signInWithApple(
        context:
            context); // You need to implement this method in your AuthenticationService
    Logger().log("Sign in with Apple result: $result");
  }
}
