import 'dart:convert';

import 'package:dirm/screen/detail/detail.dart';
import 'package:dirm/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> categories = ["home", "land", "event"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: MySearchDelegate())
                    .then((property) {
                  if (property != null) {
                    // goto details page
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => DetailPage(
                              property: property, category: property.category)),
                        ));
                  }
                });
              },
              icon: const Icon(Icons.search))
        ],
      ),
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  List<dynamic> suggestions = [];
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = '';
            }
          },
          icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestion =
        suggestions.singleWhere((element) => element._id == query);
    return Center(
        child: GestureDetector(
      onTap: () {
        close(context, suggestion);
      },
      child: Column(
        children: [
          //image
          Image.network(
            "$baseUrl/${suggestion.photos[0]}",
            fit: BoxFit.cover,
            height: 130,
            width: 200,
          ),
          Text(suggestion.category),
          Text(suggestion.name)
        ],
      ),
    ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: searchStream(query),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List bodyList = jsonDecode(snapshot.data);
            suggestions
                .addAll(bodyList.map((suggestion) => json.decode(suggestion)));
            return suggestions.isNotEmpty
                ? ListView.builder(
                    itemCount: suggestions.length,

                    ///shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(suggestion.title),
                            Text(suggestion.address)
                          ],
                        ),
                        onTap: () {
                          query = suggestion._id;
                          showResults(context);
                        },
                      );
                    })
                : Center(
                    child: Text(
                      'Ooops not found',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  IOWebSocketChannel searchChannel = IOWebSocketChannel.connect('$ws/search');

  Stream searchStream(String query) {
    searchChannel.sink.add(jsonEncode({
      "query": query,
    }));
    return searchChannel.stream;
  }
}
