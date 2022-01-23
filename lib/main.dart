import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:chaleno/chaleno.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter web scrapper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Dictionary web scrapper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String urlInput = '';

  LinkedHashMap<String, int> commonWords = LinkedHashMap();
  Map<String, int> wordCount = {};

  getCommonWords() {
    //convert the values of the map to a list first
    var sortedKeys = wordCount.keys.toList(growable: false)
      //sort the list of values of the map in an ascending manner by starting with k2,k1
      ..sort((k2, k1) => wordCount[k1]!.compareTo(wordCount[k2]!));
    // The new value of  commonWords is map where the values are mapped to the respective keys
    commonWords = LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => wordCount[k]!);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff064DAE),
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  validator: (value) {
                    if ((Uri.parse(value!).hasAbsolutePath) &&
                        (value.isNotEmpty)) {
                      return null;
                    } else {
                      return 'input the correct url';
                    }
                  },
                  onChanged: (value) {
                    urlInput = value;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  var symbols = "!@#\$%^&*()_-+={[}]|\\;:\"<>?/., ";

                  if (_formKey.currentState!.validate()) {
                    //declaring the variables

                    List words = [];
                    //using the chaleno package to load the url
                    Chaleno().load(urlInput).then((value) {
                      //get elements in the div tag
                      List<Result>? result =
                          value?.getElementsByTagName('body');
                      // iterate through them to get the text
                      for (var item in result!) {
                        String content = item.text.toString();
                        words = content.toLowerCase().split(' ');
                        wordCount = Map<String, int>.fromIterable(words,
                            key: (item) => item.toString(), value: (item) => 0);
                        for (var word in words) {
                          if (words.contains(word)) {
                            wordCount.update(word, (value) => value + 1);
                          } else {
                            wordCount.update(word, (value) => 1);
                          }
                        }
                      }
                      // print('______---------------------------------________');
                      // print(wordCount);
                      // print('_____-------------------------------_________');
                      getCommonWords();
                      print(commonWords);
                    });
                  } else {
                    print('not valid');
                  }
                },
                child: const Text('Submit'),
              ),
              commonWords.isEmpty
                  ? SizedBox()
                  : Container(
                      height: screenHeight - 200,
                      width: screenWidth - 10,
                      child: ListView.builder(
                        itemCount: commonWords.length,
                        itemBuilder: (BuildContext context, int index) {
                          String key = commonWords.keys.elementAt(index);
                          int value = commonWords.values.elementAt(index);
                          return Wrap(children: [
                            ListTile(
                              title: Text(key),
                              subtitle: Text("$value"),
                            ),
                          ]);
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
