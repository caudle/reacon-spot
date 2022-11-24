import 'package:dirm/modal/land.dart';
import 'package:dirm/modal/subcategory.dart';
import 'package:dirm/modal/venue.dart';
import 'package:dirm/screen/detail/detail.dart';
import 'package:dirm/util/constants.dart';
import 'package:flutter/material.dart';

import '../../modal/listing.dart';
import '../../services/api/rest_api.dart';
import '../../services/storage/database_service.dart';
import '../../util/shared.dart';

/// get listings by subcat store in var
/// get lands by subcat store in var
/// get events by subcat store in var
/// get @each subcat by cat store in var
/// store current cat in var
/// store current subcat in var
/// use current cat and subcat to show required content.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  Future<List<Listing>>? _futureListings;
  Future<List<Land>>? _futureLands;
  Future<List<Venue>>? _futureVenues;
  Future<List<Subcategory>>? _futureListingSubCats;
  Future<List<Subcategory>>? _futureLandSubCats;
  Future<List<Subcategory>>? _futureVenueSubCats;
  List<String> cats = [
    "home",
    "land",
    "event"
  ]; // for alternating in tabbar ontap fxn
  String currentCat = "home";
  String currentSubcat = "apartment";
  DatabaseService databaseService = DatabaseService();
  RestApi api = RestApi();
  //TextEditingController searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    //get data frm api
    getSubCats(api).then((value) {
      print('get subcats success');
      // get all subcats
      loadListingSubCats();
      loadLandSubCats();
      loadVenueSubCats();
      // get listings by cat
      getListingsByCat("apartment");
      getLandsByCat("commercial");
      getVenuesByCat("multipurpose hall");
    }, onError: (error) {
      showSnackBar(context: context, message: error.toString());
    });

    super.initState();
  }

  // get listings by cat
  void getListingsByCat(String cat) {
    final listings = api.getListingsByCat(cat);
    setState(() {
      _futureListings = listings;
    });
  }

  // load listing subcats by cat
  // eg apt,house
  void loadListingSubCats() {
    final subcats = databaseService.getSubcatsByCat("home");
    setState(() {
      _futureListingSubCats = subcats;
    });
  }

  // get lands
  void getLandsByCat(String cat) {
    final lands = api.getLandsByCat(cat);
    setState(() {
      _futureLands = lands;
    });
  }

  // load land subcats by cat
  // eg commercial
  void loadLandSubCats() {
    final subcats = databaseService.getSubcatsByCat("land");
    setState(() {
      _futureLandSubCats = subcats;
    });
  }

  // get venues
  void getVenuesByCat(String cat) {
    final venues = api.getVenuesByCat(cat);
    setState(() {
      _futureVenues = venues;
    });
  }

  // load venues subcats by cat
  // eg wedding halls
  void loadVenueSubCats() {
    final subcats = databaseService.getSubcatsByCat("event");
    setState(() {
      _futureVenueSubCats = subcats;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 3,
      child: CustomScrollView(
        slivers: [
          /// app bar
          SliverAppBar(
            title: const Text('Reacon Spot'),
            bottom: TabBar(
              isScrollable: true,
              physics: const BouncingScrollPhysics(),
              tabs: const [
                Tab(text: "Homes and Flats"),
                Tab(text: "Land and Plots"),
                Tab(text: "Events and Venues")
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    {
                      setState(() {
                        currentCat = "home";
                        currentSubcat = "apartment";
                      });
                    }
                    break;
                  case 1:
                    {
                      setState(() {
                        currentCat = "land";
                        currentSubcat = "commercial";
                      });
                    }
                    break;
                  case 2:
                    {
                      setState(() {
                        currentCat = "event";
                        currentSubcat = "multipurpose hall";
                      });
                    }
                    break;
                  default:
                    {
                      setState(() {
                        currentCat = cats[index];
                        currentSubcat = "apartment";
                      });
                    }
                    break;
                }
                setState(() {
                  currentCat = cats[index];
                });
              },
            ),
          ),

          /// listing/home cats
          if (currentCat == "home")
            SliverPadding(
              padding: const EdgeInsets.only(
                  left: 12, right: 12, top: 20, bottom: 8),
              sliver: FutureBuilder<List<Subcategory>>(
                  future: _futureListingSubCats,
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      final cats = snapshot.data!;
                      return cats.isNotEmpty
                          ? SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                mainAxisExtent: 40,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return TextButton(
                                    onPressed: () {
                                      setState(() {
                                        currentSubcat = cats[index].name;
                                      });
                                      getListingsByCat(cats[index].name);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              cats[index].name == currentSubcat
                                                  ? Colors.grey
                                                  : Colors.white),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        side: BorderSide(
                                            color: cats[index].name ==
                                                    currentSubcat
                                                ? Colors.grey
                                                : Colors.black),
                                      )),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              cats[index].name == currentSubcat
                                                  ? Colors.white
                                                  : Colors.black),
                                    ),
                                    child: Text(cats[index].name),
                                  );
                                },
                                childCount: cats.length,
                              ),
                            )
                          : const SliverToBoxAdapter(
                              child: Text('No categories found'),
                            );
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  })),
            ),

          /// land cats
          if (currentCat == "land")
            SliverPadding(
              padding: const EdgeInsets.only(
                  left: 12, right: 12, top: 20, bottom: 8),
              sliver: FutureBuilder<List<Subcategory>>(
                  future: _futureLandSubCats,
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      final cats = snapshot.data!;
                      return cats.isNotEmpty
                          ? SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                mainAxisExtent: 40,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return TextButton(
                                    onPressed: () {
                                      setState(() {
                                        currentSubcat = cats[index].name;
                                      });
                                      getLandsByCat(cats[index].name);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              cats[index].name == currentSubcat
                                                  ? Colors.grey
                                                  : Colors.white),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        side: BorderSide(
                                            color: cats[index].name ==
                                                    currentSubcat
                                                ? Colors.grey
                                                : Colors.black),
                                      )),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              cats[index].name == currentSubcat
                                                  ? Colors.white
                                                  : Colors.black),
                                    ),
                                    child: Text(cats[index].name),
                                  );
                                },
                                childCount: cats.length,
                              ),
                            )
                          : const SliverToBoxAdapter(
                              child: Text('No categories found'),
                            );
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  })),
            ),

          /// listing/home cats
          if (currentCat == "event")
            SliverPadding(
              padding: const EdgeInsets.only(
                  left: 12, right: 12, top: 20, bottom: 8),
              sliver: FutureBuilder<List<Subcategory>>(
                  future: _futureVenueSubCats,
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      final cats = snapshot.data!;
                      return cats.isNotEmpty
                          ? SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                mainAxisExtent: 45,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return TextButton(
                                    onPressed: () {
                                      setState(() {
                                        currentSubcat = cats[index].name;
                                      });
                                      getVenuesByCat(cats[index].name);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              cats[index].name == currentSubcat
                                                  ? Colors.grey
                                                  : Colors.white),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        side: BorderSide(
                                            color: cats[index].name ==
                                                    currentSubcat
                                                ? Colors.grey
                                                : Colors.black),
                                      )),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              cats[index].name == currentSubcat
                                                  ? Colors.white
                                                  : Colors.black),
                                    ),
                                    child: Text(cats[index].name),
                                  );
                                },
                                childCount: cats.length,
                              ),
                            )
                          : const SliverToBoxAdapter(
                              child: Text('No categories found'),
                            );
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  })),
            ),

          // cat name
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                right: 12,
                top: 10,
                bottom: 3,
              ),
              child: Text("${currentSubcat.capitalize()}s",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 16)),
            ),
          ),

          // listings
          if (currentCat == "home")
            SliverPadding(
              padding: const EdgeInsets.only(
                  left: 12, right: 12, top: 10, bottom: 8),
              sliver: FutureBuilder<List<Listing>>(
                  future: _futureListings,
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      final listings = snapshot.data!;
                      return listings.isNotEmpty
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final listing = listings[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  height: 130,
                                  child: Card(
                                    elevation: 2,
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) => DetailPage(
                                                  property: listing,
                                                  category: "home")))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: Image.network(
                                              "$baseUrl/${listing.photos[0]}",
                                              fit: BoxFit.cover,
                                              height: 130,
                                              width: 200,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              //mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Flexible(
                                                    child: Text(
                                                        listing.title
                                                            .capitalize(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2!
                                                            .copyWith(
                                                                fontSize: 13))),
                                                Wrap(
                                                  children: [
                                                    const Icon(
                                                      Icons.place,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                        listing.address
                                                            .capitalize(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption)
                                                  ],
                                                ),
                                                Flexible(
                                                    child: Text(
                                                  "${formatCurrency.format(listing.price)} TZS",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1,
                                                )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: listings.length,
                            ))
                          : const SliverToBoxAdapter(
                              child: Align(
                              alignment: Alignment.center,
                              child: Text('No listings found'),
                            ));
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  })),
            ),

          // land
          if (currentCat == "land")
            SliverPadding(
              padding: const EdgeInsets.only(
                  left: 12, right: 12, top: 10, bottom: 8),
              sliver: FutureBuilder<List<Land>>(
                  future: _futureLands,
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      final lands = snapshot.data!;
                      return lands.isNotEmpty
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final land = lands[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  height: 130,
                                  child: Card(
                                    elevation: 2,
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) => DetailPage(
                                                  property: land,
                                                  category: "land")))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: Image.network(
                                              "$baseUrl/${land.photos[0]}",
                                              fit: BoxFit.cover,
                                              height: 130,
                                              width: 200,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              //mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Flexible(
                                                    child: Text(
                                                        land.title.capitalize(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2!
                                                            .copyWith(
                                                                fontSize: 13))),
                                                Wrap(
                                                  children: [
                                                    const Icon(
                                                      Icons.place,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                        land.address
                                                            .capitalize(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption),
                                                  ],
                                                ),
                                                Flexible(
                                                    child: Text(
                                                        "${formatCurrency.format(land.price)} TZS",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: lands.length,
                            ))
                          : const SliverToBoxAdapter(
                              child: Align(
                              alignment: Alignment.center,
                              child: Text('No lands and plots found'),
                            ));
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  })),
            ),

          // venue
          if (currentCat == "event")
            SliverPadding(
              padding: const EdgeInsets.only(
                  left: 12, right: 12, top: 10, bottom: 8),
              sliver: FutureBuilder<List<Venue>>(
                  future: _futureVenues,
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      final venues = snapshot.data!;
                      return venues.isNotEmpty
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final venue = venues[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  height: 130,
                                  child: Card(
                                    elevation: 2,
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) => DetailPage(
                                                  property: venue,
                                                  category: "event")))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: Image.network(
                                              "$baseUrl/${venue.photos[0]}",
                                              fit: BoxFit.cover,
                                              height: 130,
                                              width: 200,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              //mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Flexible(
                                                    child: Text(
                                                        venue.title
                                                            .capitalize(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2!
                                                            .copyWith(
                                                                fontSize: 13))),
                                                Wrap(
                                                  children: [
                                                    const Icon(
                                                      Icons.place,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                        venue.address
                                                            .capitalize(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption),
                                                  ],
                                                ),
                                                Flexible(
                                                    child: Text(
                                                        "${formatCurrency.format(venue.price)} TZS",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: venues.length,
                            ))
                          : const SliverToBoxAdapter(
                              child: Align(
                              alignment: Alignment.center,
                              child: Text('No events and venues found'),
                            ));
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  })),
            ),
        ],
      ),
    );
  }
}

Future getSubCats(RestApi api) async {
  try {
    await api.getSubcats();
  } catch (e) {
    throw Exception(e);
  }
}
