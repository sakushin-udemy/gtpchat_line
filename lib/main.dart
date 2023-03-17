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

  Message.waitResponse(DateTime now)
      : this('', DateTime.now(), fromChatGpt: true);
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: AppBarTheme(color: _MyHomePageState.colorBackground),
        scaffoldBackgroundColor: Colors.white,
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
  final _scrollController = ScrollController();

  bool _isLoading = false;
  final _messages = <Message>[];

  static Color colorBackground = Color.fromARGB(0xFF, 0x90, 0xac, 0xd7);
  static Color colorMyMessage = Color.fromARGB(0xFF, 0x8a, 0xe1, 0x7e);
  static Color colorOthersMessage = Color.fromARGB(0xFF, 0xff, 0xff, 0xff);
  static Color colorTime = Color.fromARGB(0xFF, 0x72, 0x88, 0xa8);
  static Color colorAvatar = Color.fromARGB(0xFF, 0x76, 0x5a, 0x44);
  static Color colorInput = Color.fromARGB(0xFF, 0xf5, 0xf5, 0xf5);

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
                child: ColoredBox(
              color: colorBackground,
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final showLoadingIcon =
                        _isLoading && index == _messages.length - 1;

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
                              if (!message.fromChatGpt)
                                Text(
                                  _formatDateTime(message.sendTime),
                                  style: TextStyle(color: colorTime),
                                ),
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
                                    child: showLoadingIcon
                                        ? const CircularProgressIndicator()
                                        : Text(
                                            message.message,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                  ),
                                ),
                              ),
                              if (message.fromChatGpt)
                                Text(
                                  _formatDateTime(message.sendTime),
                                  style: TextStyle(color: colorTime),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
            )),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    style: TextStyle(fontSize: 14),
                    controller: _textEditingController,
                    decoration: InputDecoration(
                        fillColor: colorInput,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  )),
                  IconButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              _onTapSend(_textEditingController.text);
                            },
                      icon: Icon(
                        Icons.send,
                        color: _isLoading ? Colors.grey : Colors.black,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _onTapSend(String userMessage) {
    setState(() {
      _isLoading = true;
      _messages.addAll([
        Message(userMessage, DateTime.now(), fromChatGpt: false),
        Message.waitResponse(DateTime.now()),
      ]);
      _scrollDown();
    });

    _sendMessage(userMessage).then((chatGptMessage) {
      setState(() {
        _messages.last =
            Message(chatGptMessage.trim(), DateTime.now(), fromChatGpt: true);
        _isLoading = false;
      });
      _scrollDown();
    });
  }

  Future<String> _sendMessage(String message) async {
    final request =
        CompleteText(prompt: message, model: kTextDavinci3, maxTokens: 200);

    final response = await openAI.onCompletion(request: request);
    return response!.choices.first.text;
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    });
  }
}
