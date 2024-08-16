import 'package:flutter/material.dart';

class GlobalTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final bool isAdminLogin;

  const GlobalTextFormField({
    super.key,
    required this.controller,
    this.isAdminLogin = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: isAdminLogin
            ? const Icon(Icons.admin_panel_settings)
            : const Icon(Icons.person_rounded),
        labelText: "Enter your name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      style: const TextStyle(fontSize: 16),
      textInputAction: TextInputAction.done,
    );
  }
}
