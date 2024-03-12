import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(DictionaryApp());
}

class DictionaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dictionary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading data for 5 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DictionaryScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD7DAF3), // Set background color to #d7daf3
      body: Center(
        child: Image.network(
          'https://i.redd.it/0g30oqtpiyd51.gif', // Replace with your GIF URL
          width: 200.0,
          height: 200.0,
          // You can adjust width and height according to your preference
        ),
      ),
    );
  }
}

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  List<Definition> _definitions = [];
  bool _wordNotFound = false;

  Future<void> _searchWord() async {
    final String apiUrl =
        'https://api.dictionaryapi.dev/api/v2/entries/en/$_searchTerm';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        _definitions.clear(); // Clear previous definitions
        _definitions = responseData
            .map((json) => Definition.fromJson(json))
            .toList();
        _wordNotFound = false;
      });
    } else {
      setState(() {
        _wordNotFound = true;
        _definitions.clear(); // Clear previous definitions
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Center(child: Text('Dictionary')),
            backgroundColor: Color(0xFFFBF7E8), // Set app bar color to #d7daf3
          ),
          backgroundColor: Color(0xFFC9D1F2), // Set background color to #c9d1f2
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10.0),
                Image.network(
                  'https://media4.giphy.com/media/2nciPKoj5DerEKmEq9/giphy.gif?cid=6c09b9526ovfnqmhlora1yzw6w8wl2kl5ifo52l4muhbuo1h&ep=v1_internal_gif_by_id&rid=giphy.gif&ct=s',
                  width: double.infinity,
                  height: 150.0,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Welcome to the Dictionary!',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) {
                      setState(() {
                        _searchTerm = _searchController.text.trim();
                      });
                      _searchWord();
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter a word',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                if (_definitions.isNotEmpty)
                  Column(
                    children: _definitions
                        .map((definition) => DefinitionCard(definition: definition))
                        .toList(),
                  ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
        if (_wordNotFound)
          GestureDetector(
            onTap: () {},
            child: Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  width: 400.0, // Set a fixed width for the dialog box
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: SingleChildScrollView( // Wrap the dialog content with SingleChildScrollView
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _wordNotFound = false;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 30.0,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              'Word Not Found',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20.0),
                            Image.network(
                              'https://media2.giphy.com/media/EENmvrF7a5X5s98pqM/giphy.gif?cid=6c09b952y1yptz0bp776htlb34rp2h2mf1yiqej27f281pwm&ep=v1_internal_gif_by_id&rid=giphy.gif&ct=s',
                              width: 150.0,
                              height: 150.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class Definition {
  final String word;
  final String phonetic;
  final List<Meaning> meanings;

  Definition({required this.word, required this.phonetic, required this.meanings});

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      word: json['word'],
      phonetic: json['phonetic'],
      meanings: List<Meaning>.from(json['meanings'].map((meaning) => Meaning.fromJson(meaning))),
    );
  }
}

class Meaning {
  final String partOfSpeech;
  final List<String> definitions;

  Meaning({required this.partOfSpeech, required this.definitions});

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'],
      definitions: List<String>.from(json['definitions'].map((definition) => definition['definition'])),
    );
  }
}

class DefinitionCard extends StatelessWidget {
  final Definition definition;

  const DefinitionCard({Key? key, required this.definition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Word: ${definition.word}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5.0),
            Text(
              'Phonetic: ${definition.phonetic}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Meanings:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            ...definition.meanings.map((meaning) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Part of Speech: ${meaning.partOfSpeech}',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5.0),
                  ...meaning.definitions.map((definition) {
                    return Text(
                      '- $definition',
                      style: TextStyle(fontSize: 16.0),
                    );
                  }).toList(),
                  SizedBox(height: 10.0),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
