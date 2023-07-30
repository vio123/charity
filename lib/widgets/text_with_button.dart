
import 'package:flutter/material.dart';

class TextWithButton extends StatelessWidget {
  const TextWithButton({
    super.key,
    required this.text,
    required this.btnText,
    required this.btnFun,
    this.textColor = Colors.white,
    required this.btnColor,
  });

  final String text;
  final String btnText;
  final Function btnFun;
  final Color textColor;
  final Color btnColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(color: textColor, fontSize: 15),
        ),
        TextButton(
          onPressed: () {
            btnFun();
          },
          child: Text(
            btnText,
            style:  TextStyle(color: btnColor, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
