import "package:emailjs/emailjs.dart";

import 'package:flutter_dotenv/flutter_dotenv.dart';
import "./DB/handler/user_info_db_handler.dart";

class Message {
  Message({required this.content, this.url});
  String? url;
  final String content;
  Future<Map<String, dynamic>> toMap() async {
    url = await UserDatabaseHelper().getUrl();
    return {"content": content, "url": url};
  }

  Future<bool> sendEmail() async {
    try {
      await EmailJS.send(
        dotenv.get("SERVICE_ID"),
        dotenv.get('TEMPLATE_ID'),
        await toMap(),
        Options(
          publicKey: dotenv.get('PUBLIC_KEY'),
          privateKey: dotenv.get('PRIVATE_KEY'),
        ),
      );
      print('SUCCESS!');
      return true;
    } catch (error) {
      if (error is EmailJSResponseStatus) {
        print('ERROR... ${error.status}: ${error.text}');
      }
      print(error.toString());
      return false;
    }
  }
}
