import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'definition.dart';
import 'definition_card.dart';

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
        _definitions.clear(); // Clear previous definitionse
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
    return Scaffold(
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
    );
  }
}
