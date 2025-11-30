import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  const CustomErrorWidget({Key? key, required this.errorDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text('Bir hata oluştu', style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 8),
              Text(errorDetails.exception.toString(), style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
