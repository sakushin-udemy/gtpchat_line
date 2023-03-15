import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';

import 'api_key.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final openAI = OpenAI.instance.build(
    token: writeYourOpenAPIKey,
    isLogger: true,
  );

  final _textEditingController = TextEditingController(
    text: 'What is Flutter?',
  );

  var _answer = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _textEditingController,
                )),
                IconButton(
                    onPressed: () async {
                      final answer =
                          await _sendMessage(_textEditingController.text);
                      setState(() {
                        _answer = answer;
                      });
                    },
                    icon: Icon(Icons.send)),
              ],
            ),
            Text(_answer),
          ],
        ),
      ),
    );
  }

  Future<String> _sendMessage(String message) async {
    final request =
        CompleteText(prompt: message, model: kTextDavinci3, maxTokens: 200);

    final response = await openAI.onCompletion(request: request);
    return response!.choices.first.text;
  }
}
