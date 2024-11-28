import 'package:flutter/material.dart';
import 'sign_up_widget.dart';

class SignUpView extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onConfirmPasswordVisibilityToggle;
  final FormFieldValidator<String> validator;
  final VoidCallback onSignUpPressed;
  final GlobalKey<FormState> formKey;

  final ValueChanged<String?> onRoleChanged;

  const SignUpView({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.passwordVisible,
    required this.confirmPasswordVisible,
    required this.onPasswordVisibilityToggle,
    required this.onConfirmPasswordVisibilityToggle,
    required this.formKey,
    required this.validator,
    required this.onSignUpPressed,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildSignUpForm(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: ClipPath(
        clipper: CustomShapeSignUp(),
        child: Container(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "Buat Akun Kamu",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        Form(
          key: formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: nameController,
                hintText: "Nama",
                prefixIcon: Icons.person,
                validator: (value) => validator("Nama"),
              ),
              CustomTextField(
                controller: emailController,
                hintText: "Email",
                prefixIcon: Icons.email,
                validator: (value) => validator("Email"),
              ),
              CustomDropdown(
                hintText: "Pilih Peran",
                prefixIcon: Icons.person,
                validator: (value) => validator("Role"),
                items: ["Siswa", "Guru"],
                onChanged: (value) {
                  onRoleChanged(value);
                },
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
              CustomTextField(
                controller: confirmPasswordController,
                hintText: "Konfirmasi Kata Sandi",
                prefixIcon: Icons.lock,
                isPassword: true,
                isPasswordVisible: confirmPasswordVisible,
                onVisibilityToggle: onConfirmPasswordVisibilityToggle,
                validator: (value) => validator("Konfirmasi Kata Sandi"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SignUpButton(onPressed: onSignUpPressed),
      ],
    );
  }
}
