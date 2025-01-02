import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/auth/sign_up_provider.dart';

class MyTextFormField extends StatelessWidget {
  const MyTextFormField(
      {super.key,
      required this.controller,
      required this.validator,
      required this.hintText,
      this.enabled = true,
      this.onTap});

  final TextEditingController controller;
  final String? Function(String?) validator;
  final String hintText;
  final bool enabled;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      onTap: onTap,
      validator: validator,
      
      textInputAction: TextInputAction.done,
      cursorColor: context.theme.colorScheme.tertiary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: context.textTheme.titleMedium,
        border: InputBorder.none,
        filled: true,
        fillColor: context.theme.colorScheme.secondary,
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.textInputType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  //  = ;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      cursorColor: context.theme.colorScheme.tertiary,
      keyboardType: textInputType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        filled: true,
        fillColor: context.theme.colorScheme.secondary,
      ),
    );
  }
}
