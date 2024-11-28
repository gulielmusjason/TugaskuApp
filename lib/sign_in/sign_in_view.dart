import 'package:flutter/material.dart';
import 'sign_in_widget.dart';

class SignInView extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool passwordVisible;
  final VoidCallback onPasswordVisibilityToggle;
  final FormFieldValidator<String> validator;
  final VoidCallback onSignInPressed;
  final VoidCallback onSignUpPressed;
  final GlobalKey<FormState> formKey;

  const SignInView({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.passwordVisible,
    required this.onPasswordVisibilityToggle,
    required this.validator,
    required this.onSignInPressed,
    required this.onSignUpPressed,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildLoginForm(context),
            _buildSignUpLink(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 250,
      width: MediaQuery.of(context).size.width,
      child: ClipPath(
        clipper: CustomShape(),
        child: Container(color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      children: [
        Text(
          "LOGIN",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        Form(
          key: formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: emailController,
                hintText: "Email",
                prefixIcon: Icons.email,
                validator: (value) => validator("Email"),
              ),
              CustomTextField(
                controller: passwordController,
                hintText: "Kata Sandi",
                prefixIcon: Icons.lock,
                isPassword: true,
                isPasswordVisible: passwordVisible,
                onVisibilityToggle: onPasswordVisibilityToggle,
                validator: (value) => validator("Kata Sandi"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LoginButton(onPressed: onSignInPressed),
      ],
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Tidak Punya Akun?",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: onSignUpPressed,
          child: Text(
            "Daftar",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      ],
    );
  }
}
