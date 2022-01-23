import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:chaleno/chaleno.dart';
import 'package:dictionary_scrapping/animated_color_loader.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

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
  bool loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String urlInput = '';

  LinkedHashMap<String, int> allSortedWords = LinkedHashMap();
  Map<String, int> wordCount = {};

  getCommonWords() {
    //convert the values of the map to a list first
    var sortedKeys = wordCount.keys.toList(growable: false)
      //sort the list of values of the map in an ascending manner by starting with k2,k1
      ..sort((k2, k1) => wordCount[k1]!.compareTo(wordCount[k2]!));
    // The new value of  commonWords is map where the values are mapped to the respective keys
    allSortedWords = LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => wordCount[k]!);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
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
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    hintStyle: TextStyle(color: Colors.white),
                    hintText: 'Enter the Url here',
                  ),
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
                  setState(() {
                    loading = true;
                  });
                  if (_formKey.currentState!.validate()) {
                    //declaring the variable
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
                        //get the count of the words and store in a map
                        for (var word in words) {
                          if (words.contains(word)) {
                            wordCount.update(word, (value) => value + 1);
                          } else {
                            wordCount.update(word, (value) => 1);
                          }
                        }
                      }
                      //refresh the user interface and populate the words and count
                      setState(() {
                        getCommonWords();
                        loading = false;
                      });

                      print(allSortedWords);
                    });
                  } else {
                    print('not valid');
                  }
                },
                child: const Text('Submit'),
              ),
              const Text(
                'Words scrapped from the website and their frequencies sorted in ascending order',
                style: TextStyle(color: Colors.white30),
              ),
              loading
                  ? Center(
                      child: ColorLoader(
                      color3: Colors.blueAccent,
                    ))
                  : allSortedWords.isEmpty
                      ? const SizedBox()
                      : Container(
                          height: screenHeight - 200,
                          width: screenWidth - 10,
                          child: ResponsiveGridList(
                            horizontalGridMargin: 10,
                            verticalGridMargin: 10,
                            minItemWidth: 160,
                            children: List.generate(
                              allSortedWords.length,
                              (index) {
                                String key =
                                    allSortedWords.keys.elementAt(index);
                                int value =
                                    allSortedWords.values.elementAt(index);
                                return Tooltip(
                                  message: key,
                                  child: Chip(
                                    elevation: 15,
                                    padding: const EdgeInsets.all(6),
                                    backgroundColor: Colors.greenAccent[100],
                                    shadowColor: Colors.black,
                                    avatar: CircleAvatar(
                                      child: Text(value.toString()),
                                    ), //CircleAvatar
                                    label: Text(
                                      key,
                                      style: const TextStyle(fontSize: 20),
                                    ), //Text
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
