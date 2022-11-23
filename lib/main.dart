import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future main() async {
  await dotenv.load(fileName: '../.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Translate App', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _Loading extends StatelessWidget {
  const _Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _Result extends StatelessWidget {
  const _Result({
    super.key,
    required this.sentence,
    required this.onTapBack,
  });

  final String sentence;
  final void Function() onTapBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(sentence),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onTapBack, child: const Text('再入力'))
        ],
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _textEditController = TextEditingController();

  String? _result;
  bool _isLoading = false;

  Future<void> _translate(String sentence) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://labs.goo.ne.jp/api/hiragana');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'app_id': '${dotenv.get('APP_ID')}',
      'sentence': sentence,
      'output_type': 'hiragana'
    });
    final response = await http.post(url, headers: headers, body: body);

    final responseJson = json.decode(response.body) as Map<String, dynamic>;

    setState(() {
      _result = responseJson['converted'];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Translate App")),
        body: _body(context));
  }

  Widget _body(BuildContext context) {
    final result = _result;
    if (result != null) {
      return _Result(
          sentence: result,
          onTapBack: () {
            setState(() {
              _result = null;
            });
          });
    } else if (_isLoading) {
      return const _Loading();
    } else {
      return Scaffold(
          body: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                        controller: _textEditController,
                        maxLines: 5,
                        decoration:
                            const InputDecoration(hintText: '文章を入力してください'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '文章が入力されていません';
                          }
                          return null;
                        }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        final formState = _formKey.currentState!;
                        if (!formState.validate()) {
                          return;
                        }

                        debugPrint('text = ${_textEditController.text}');
                        _translate(_textEditController.text);
                      },
                      child: const Text('変換'))
                ],
              )));
    }
  }

  @override
  void dispose() {
    _textEditController.dispose();
    super.dispose();
  }
}
