import 'package:flutter/material.dart';

void main() {
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

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _textEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Translate App")),
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
                    },
                    child: const Text('変換'))
              ],
            )));
  }

  @override
  void dispose() {
    _textEditController.dispose();
    super.dispose();
  }
}
