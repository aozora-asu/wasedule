import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart'; // 追加
import './backend/temp_file.dart';
import 'package:flutter/material.dart';

void main() async {
  // Flutterアプリケーションの初期化
  WidgetsFlutterBinding.ensureInitialized();

  String s = await _getTask(url_t);
  Future<File> file = getFilePath();
  getFilePath().then((File file) {
    file.writeAsString(s);
  });
}

Future<File> getFilePath() async {
  final directory = await getTemporaryDirectory();
  return File(directory.path + '/test.txt');
}

Future<String> _getTask(String urlString) async {
  Uri url = Uri.parse(urlString);
  var response = await http.post(url);
  print(response.body);
  return response.body;
}

// class TextFileViewer extends StatelessWidget {
//   Future<String> readFileContents() async {
//     try {
//       final directory = await getTemporaryDirectory(); // ディレクトリを取得
//       final file = File('${directory.path}/test.txt'); // ファイルを指定のディレクトリ内に作成
//       final contents = await file.readAsString();
//       return contents;
//     } catch (e) {
//       return "Error reading file: $e";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Text File Viewer'),
//       ),
//       body: FutureBuilder(
//         future: readFileContents(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return CircularProgressIndicator();
//           } else if (snapshot.hasError) {
//             return Text("Error: ${snapshot.error}");
//           } else {
//             return SingleChildScrollView(
//               child: Text(
//                 snapshot.data ?? "No data",
//                 style: TextStyle(fontSize: 16),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// void main() => runApp(MaterialApp(home: TextFileViewer()));
