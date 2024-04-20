import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrimaryTextField extends StatefulWidget {
  final TextEditingController? textController;
  final String? hintText;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final Function()? onEditingComplete;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const PrimaryTextField({
    super.key,
    this.textController,
    this.hintText,
    this.enabled = true,
    this.validator,
    this.obscureText,
    this.prefixIcon,
    this.suffixIcon,
    this.autofillHints,
    this.textInputAction,
    this.onEditingComplete,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.obscureText ?? false,
      controller: widget.textController,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        filled: true,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        // fillColor: ,
        hintText: widget.hintText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: Color(0xFFDEE3EB), width: 1),
        ),
      ),
      enabled: widget.enabled,
      validator: widget.validator,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      inputFormatters: widget.inputFormatters,
    );
  }
}
