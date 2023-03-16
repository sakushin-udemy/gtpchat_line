import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';

import 'api_key.dart';

void main() {
  runApp(MyApp());
}

class Message {
  const Message(
    this.message,
    this.sendTime, {
    required this.fromChatGpt,
  });
  final String message;
  final bool fromChatGpt;
  final DateTime sendTime;
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _MyHomePageState.colorBackground,
      ),
      home: const MyHomePage(title: 'Talk with ChatGPT'),
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

  final _messages = <Message>[
    Message("こんにちは！", DateTime(2023, 4, 1, 9, 5, 0), fromChatGpt: false),
    Message("こんにちは！お元気ですか？", DateTime(2023, 4, 1, 9, 59, 0), fromChatGpt: true),
    Message("はい、元気です。あなたは何ができますか？", DateTime(2023, 4, 1, 10, 2, 0),
        fromChatGpt: false),
    Message("私はあなたの悩みを聞いたり、おすすめのレストランを教えたり、天気予報を教えたりすることができます。何かお探しですか？",
        DateTime(2023, 4, 1, 10, 3, 0),
        fromChatGpt: true),
    Message("今日の天気はどうですか？", DateTime(2023, 4, 1, 10, 4, 0), fromChatGpt: false),
    Message("今日の天気は晴れで、最高気温は20度、最低気温は10度の予想です。お出かけの際はお気をつけください。",
        DateTime(2023, 4, 1, 10, 0, 0),
        fromChatGpt: true),
    Message("ありがとうございます。今度、美味しいレストランを教えてください。", DateTime(2023, 4, 1, 10, 5, 0),
        fromChatGpt: false),
    Message("もちろんです！どのような種類のレストランがお好みですか？イタリアン、和食、中華料理、その他ですか？",
        DateTime(2023, 4, 1, 10, 6, 0),
        fromChatGpt: true),
    Message("今日はイタリアンが食べたいです。", DateTime(2023, 4, 1, 10, 0, 0),
        fromChatGpt: false),
    Message(
        "おすすめのイタリアンレストランは、近くにある「La Piazza」です。おいしいパスタやピザが評判で、雰囲気も良いですよ。行ってみてはいかがでしょうか？",
        DateTime(2023, 4, 1, 10, 17, 0),
        fromChatGpt: true),
    Message("素晴らしいアドバイスですね。行ってみます！", DateTime(2023, 4, 1, 12, 8, 0),
        fromChatGpt: false),
    Message(
        "是非お楽しみください！また何かありましたら、いつでもご相談ください。", DateTime(2023, 4, 1, 13, 0, 0),
        fromChatGpt: true),
  ];

  static Color colorBackground = Color.fromARGB(0xFF, 0x90, 0xac, 0xd7);
  static Color colorMyMessage = Color.fromARGB(0xFF, 0x8a, 0xe1, 0x7e);
  static Color colorOthersMessage = Color.fromARGB(0xFF, 0xff, 0xff, 0xff);
  static Color colorTime = Color.fromARGB(0xFF, 0x72, 0x88, 0xa8);
  static Color colorAvatar = Color.fromARGB(0xFF, 0x76, 0x5a, 0x44);

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: message.fromChatGpt
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.fromChatGpt)
                              SizedBox(
                                  width: deviceWidth * 0.1,
                                  child: CircleAvatar(
                                      backgroundColor: colorAvatar,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.asset(
                                            'assets/images/openai.png'),
                                      ))),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth: deviceWidth * 0.7),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: message.fromChatGpt
                                          ? colorOthersMessage
                                          : colorMyMessage,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        message.message,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(_formatDateTime(message.sendTime)),
                              ],
                            ),
                          ],
                        ),
                      );
                    })),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<String> _sendMessage(String message) async {
    final request =
        CompleteText(prompt: message, model: kTextDavinci3, maxTokens: 200);

    final response = await openAI.onCompletion(request: request);
    return response!.choices.first.text;
  }
}
