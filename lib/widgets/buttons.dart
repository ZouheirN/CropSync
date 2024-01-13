import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

// class PrimaryButton extends StatelessWidget {
//   final String text;
//   final Function onPressed;
//   final bool isLoading;
//
//   const PrimaryButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.isLoading = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () => onPressed(),
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.green,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         textStyle: const TextStyle(
//           fontSize: 20,
//         ),
//         minimumSize: const Size(double.infinity, 60),
//       ),
//       child: isLoading
//           ? const CircularProgressIndicator(color: Colors.white)
//           : Text(text),
//     );
//   }
// }

class SecondaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isLoading;
  final void Function()? onPressed;
  final Color loadingColor;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.loadingColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 10,
        backgroundColor: Colors.grey.shade200,
        shape: const StadiumBorder(),
        minimumSize: const Size(double.infinity, 60),
      ),
      child: isLoading
          ? CircularProgressIndicator(color: loadingColor)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.black,
                ),
                const Gap(14),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                )
              ],
            ),
    );
  }
}

class CommonButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final void Function()? onPressed;
  final bool isLoading;
  final Color loadingColor;

  const CommonButton({
    super.key,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.onPressed,
    this.isLoading = false,
    this.loadingColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 10,
        backgroundColor: backgroundColor,
        shape: const StadiumBorder(),
        minimumSize: const Size(double.infinity, 60),
      ),
      child: isLoading
          ? CircularProgressIndicator(color: loadingColor)
          : Text(
              text,
              style: TextStyle(color: textColor, fontSize: 18),
            ),
    );
  }
}

class DialogButton extends StatelessWidget {
  final String text;
  final Color? color;
  final VoidCallback onPressed;
  final bool isLoading;

  const DialogButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 45),
        backgroundColor: color ?? Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
