import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartButton extends StatelessWidget {
  final String title;
  final Color color;
  final Function action;

  const StartButton({
    Key? key,
    required this.title,
    required this.color,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: OutlinedButton(
        onPressed: () => action(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: GoogleFonts.wendyOne(
                  textStyle: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.normal,
                    color: Color.fromARGB(255, 0, 26, 47),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
