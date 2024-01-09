import 'package:flutter/material.dart';

class PrimaryTextField extends StatefulWidget {
  final TextEditingController? textController;
  final String hintText;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final Icon? prefixIcon;

  const PrimaryTextField({
    super.key,
    this.textController,
    required this.hintText,
    this.enabled = true,
    this.validator,
    this.obscureText,
    this.prefixIcon,
  });

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  @override
  void dispose() {
    widget.textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.obscureText ?? false,
      controller: widget.textController,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        filled: true,
        prefixIcon: widget.prefixIcon,
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
    );
  }
}
