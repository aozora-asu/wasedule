import 'dart:convert';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class CalendarGptHandler {
  late String token;
  DateTime now = DateTime.now();
  String prompt = "";

  CalendarGptHandler() {
    try {
      token = dotenv.get('OPENAI_PRIVATE_KEY');
    } catch (e) {
      throw Exception("OPENAI_PRIVATE_KEY is not set in .env file.");
    }
    
    prompt = 'この文をJSONのList<Map<String,dynamic>>フォーマット{"subject":予定名,"startDate":日付(例 2024-10-03),"startTime":開始時刻(例 16:20),"endTime":終了時刻}へ変換。変換不可項目はnull。Mapへ変換できない場合は失敗理由のみを出力。今日は${DateFormat("yyyy年M月d日").format(now)}。特記無き場合は今年・今月とする。コードスニペット不使用';

  }


  Future<List<dynamic>?> textToMap(String message,context) async {

    final openAI = OpenAI.instance.build(
      token: token,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 20)),
      enableLog: true
    );


    try {
      final response = await openAI.onChatCompletion(
        request: ChatCompleteText(
          model: ChatModelFromValue(model: "gpt-4o-mini"),
          messages: [
            {
              'role': 'system',
              'content': prompt,
            },
            {
              "role": "user",
              "content": message,
            }
          ],
          maxToken: 1000,
        ),
      );

      String? resultText = response?.choices.last.message?.content;
      print(resultText);
      
      List<dynamic> resultMap = [];
      
      // StringをMapに変換
      try{
        resultMap = jsonDecode(resultText ?? "[]");
      } catch (error){
        SnackBar snackBar = SnackBar(content: Text("変換できませんでした：\n" + (resultText ?? "不明なエラー")));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        print("Error sending message: $error");
      }

      return resultMap;

    } catch (error) {
      print("Error sending message: $error");
      return null;
    }
  }
}