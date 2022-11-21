import 'dart:convert';

import 'package:dirm/modal/land.dart';
import 'package:dirm/modal/venue.dart';
import 'package:dirm/services/api/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import '../../modal/listing.dart';
import '../../modal/user.dart';
import '../../services/storage/database_service.dart';
import '../../util/constants.dart';

class FavPage extends StatefulWidget {
  const FavPage({Key? key}) : super(key: key);

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  RestApi api = RestApi();
  DatabaseService dbService = DatabaseService();
  IOWebSocketChannel homeSavedChannel =
      IOWebSocketChannel.connect('$ws/user/saved/home');
  IOWebSocketChannel landSavedChannel =
      IOWebSocketChannel.connect('$ws/user/saved/land');
  IOWebSocketChannel venueSavedChannel =
      IOWebSocketChannel.connect('$ws/user/saved/venue');
  User? loggedUser;

  @override
  void initState() {
    getLoggedUser(dbService).then((user) => setState(() {
          loggedUser = user;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favourites")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18.0, left: 18, right: 18),
            child: Text('Homes and Flats'),
          ),
          StreamBuilder<dynamic>(
              stream: homeSavedStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Listing> listings = <Listing>[];
                  List bodyList = jsonDecode(snapshot.data);
                  listings.addAll(bodyList.map(
                      (listing) => Listing.fromJson(json.encode(listing))));
                  //listings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  return listings.isNotEmpty
                      ? ListView.builder(
                          itemCount: listings.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return buildItem(listings[index]);
                          })
                      : Center(
                          child: Text(
                            'You have no saved homes and flats yet. Start by pressing the like icon on your favourite listings.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Container();
                }
              }),

          // lands
          Padding(
            padding: const EdgeInsets.only(top: 18.0, left: 18, right: 18),
            child: Text('Lands'),
          ),
          StreamBuilder<dynamic>(
              stream: landSavedStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Land> lands = <Land>[];
                  List bodyList = jsonDecode(snapshot.data);
                  lands.addAll(
                      bodyList.map((land) => Land.fromJson(json.encode(land))));
                  //listings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  return lands.isNotEmpty
                      ? ListView.builder(
                          itemCount: lands.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return buildItem(lands[index]);
                          })
                      : Center(
                          child: Text(
                            'You have no saved lands yet. Start by pressing the like icon on your favourite listings.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Container();
                }
              }),

          // venues
          Padding(
            padding: const EdgeInsets.only(top: 18.0, left: 18, right: 18),
            child: Text('Venues'),
          ),
          StreamBuilder<dynamic>(
              stream: venueSavedStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Venue> venues = <Venue>[];
                  List bodyList = jsonDecode(snapshot.data);
                  venues.addAll(bodyList
                      .map((venue) => Venue.fromJson(json.encode(venue))));
                  //listings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  return venues.isNotEmpty
                      ? ListView.builder(
                          itemCount: venues.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return buildItem(venues[index]);
                          })
                      : Center(
                          child: Text(
                            'You have no saved venues yet. Start by pressing the like icon on your favourite listings.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Container();
                }
              }),
        ],
      ),
    );
  }

  buildItem(dynamic property) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          //image
          Image.network(
            "$baseUrl/${property.photos[0]}",
            fit: BoxFit.cover,
            height: 130,
            width: 200,
          ),
          Text(property.category),
          Text(property.name)
        ],
      ),
    );
  }

  Stream homeSavedStream() {
    homeSavedChannel.sink.add(jsonEncode({
      "userId": loggedUser == null ? "" : loggedUser!.userId,
    }));
    return homeSavedChannel.stream;
  }

  Stream landSavedStream() {
    landSavedChannel.sink.add(jsonEncode({
      "userId": loggedUser == null ? "" : loggedUser!.userId,
    }));
    return landSavedChannel.stream;
  }

  Stream venueSavedStream() {
    venueSavedChannel.sink.add(jsonEncode({
      "userId": loggedUser == null ? "" : loggedUser!.userId,
    }));
    return venueSavedChannel.stream;
  }

  Future<User?> getLoggedUser(DatabaseService dbService) {
    return dbService.getUser();
  }
}
