import "package:emailjs/emailjs.dart";

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Message {
  Message({required this.text, this.url});
  String? url;
  final String text;
  Map<String, dynamic> toMap() {
    return {"content": text};
  }

  Future<bool> sedEmail() async {
    try {
      await EmailJS.send(
        dotenv.get("SERVICE_ID"),
        dotenv.get('TEMPLATE_ID'),
        toMap(),
        Options(
          publicKey: dotenv.get('PUBLIC_KEY'),
          privateKey: dotenv.get('PRIVATE_KEY'),
        ),
      );
      print('SUCCESS!');
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }
}
