import 'package:flutter/material.dart';
import 'package:go/core/error_handling/app_error.dart';

class ErrorPage extends StatelessWidget {
  final AppError error;
  const ErrorPage(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("An error occurred: ${error.message}"),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Go back"),
            ),
          ],
        ),
      ),
    );
  }
}
