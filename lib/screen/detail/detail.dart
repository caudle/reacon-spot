import 'package:dirm/modal/land.dart';
import 'package:dirm/modal/listing.dart';
import 'package:dirm/modal/venue.dart';
import 'package:dirm/services/api/rest_api.dart';
import 'package:dirm/util/shared.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';

import '../../modal/user.dart';
import '../../util/constants.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.property, required this.category})
      : super(key: key);

  final dynamic property;
  final String category;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  RestApi api = RestApi();
  int imageIndex = 0;
  Future<User>? futureAgent;
  Future<List<Listing>>? moreListingsFuture;
  Future<List<Land>>? moreLandsFuture;
  Future<List<Venue>>? moreVenuesFuture;

  /// get agent total adds

  @override
  void initState() {
    //get agent
    getAgentUser(api);
    if (widget.category == "home") {
      getMoreListings(api, widget.property);
    }
    if (widget.category == "land") {
      getMoreLands(api, widget.property);
    }
    if (widget.category == "event") {
      getMoreVenues(api, widget.property);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          // header
          SliverToBoxAdapter(
            child: Container(
                height: 200,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: widget.property.photos.length,
                      onPageChanged: (index) {
                        setState(() {
                          imageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          "$baseUrl/${widget.property.photos[index]}",
                          fit: BoxFit.cover,
                          height: 150,
                          width: 200,
                        );
                      },
                    ),
                    Positioned(
                      bottom: 5,
                      left: 5,
                      child: Text(
                          '${imageIndex + 1}/${widget.property.photos.length}'),
                    ),
                    Positioned(
                        bottom: 60,
                        right: 8,
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.favorite_border_outlined,
                              size: 35,
                              color: Colors.white,
                            ))),
                    Positioned(
                        bottom: 10,
                        right: 8,
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.share,
                              size: 35,
                              color: Colors.white,
                            ))),
                  ],
                )),
          ),
          // specific property details
          /// listing widget
          if (widget.property is Listing) buildHomesWidget(widget.property),

          /// land widget
          if (widget.property is Land) buildLandsWidget(widget.property),

          /// listing widget
          if (widget.property is Venue) buildVenuesWidget(widget.property),

          /// agent details
          SliverPadding(
            padding: const EdgeInsets.only(left: 18.0, right: 18, top: 8),
            sliver: SliverToBoxAdapter(
              child: Text('Agent Details',
                  style: Theme.of(context).textTheme.titleSmall),
            ),
          ),
          FutureBuilder<User>(
              future: futureAgent,
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  final propsCount = api.countUserProps(user.userId);
                  final month = DateFormat('MMM')
                      .format(DateTime(0, user.createdAt.month));
                  return SliverToBoxAdapter(
                      child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name[0].capitalize()),
                    ),
                    title: Text(user.name),
                    subtitle: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// get agent total ads
                        FutureBuilder(
                            future: propsCount,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final count = snapshot.data!;
                                return Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey[200],
                                    ),
                                    child: Text("$count active Ads"));
                              } else {
                                return Container();
                              }
                            }),
                        const SizedBox(width: 8),
                        Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey[200],
                            ),
                            child: Text(
                                "Joined in $month, ${user.createdAt.year}")),
                      ],
                    ),
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

          // more
          SliverPadding(
            padding: const EdgeInsets.only(
                left: 18.0, right: 18, top: 16, bottom: 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("More Like this",
                      style: Theme.of(context).textTheme.titleSmall),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Theme.of(context).primaryColorDark,
                  )
                ],
              ),
            ),
          ),

          if (widget.property is Listing)
            FutureBuilder<List<Listing>>(
                future: moreListingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final listings = snapshot.data!;
                    return listings.isNotEmpty
                        ? SliverToBoxAdapter(
                            child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 18),
                            height: 200,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: listings.length,
                                itemBuilder: (context, index) {
                                  final listing = listings[index];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        "$baseUrl/${listing.photos[0]}",
                                        fit: BoxFit.cover,
                                        height: 100,
                                        width: 130,
                                      ),
                                      Flexible(
                                          child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child:
                                            Text(listing.category.capitalize()),
                                      )),
                                      Flexible(child: Text(listing.address)),
                                      Flexible(
                                          child: Text(
                                              "${formatCurrency.format(listing.price)} TZS")),
                                    ],
                                  );
                                }),
                          ))
                        : SliverToBoxAdapter(
                            child: Text(
                                "No ${widget.property.category}'s like this found"));
                  } else if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text(snapshot.error.toString())),
                    );
                  } else {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                }),

          if (widget.property is Land)
            FutureBuilder<List<Land>>(
                future: moreLandsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final lands = snapshot.data!;
                    return lands.isNotEmpty
                        ? SliverToBoxAdapter(
                            child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 18),
                            height: 200,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: lands.length,
                                itemBuilder: (context, index) {
                                  final land = lands[index];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        "$baseUrl/${land.photos[0]}",
                                        fit: BoxFit.cover,
                                        height: 100,
                                        width: 130,
                                      ),
                                      Flexible(
                                          child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(land.category.capitalize()),
                                      )),
                                      Flexible(child: Text(land.address)),
                                      Flexible(
                                          child: Text(
                                              "${formatCurrency.format(land.price)} TZS")),
                                    ],
                                  );
                                }),
                          ))
                        : SliverToBoxAdapter(
                            child: Text(
                                "No ${widget.property.category}'s like this found"));
                  } else if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text(snapshot.error.toString())),
                    );
                  } else {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                }),

          if (widget.property is Venue)
            FutureBuilder<List<Venue>>(
                future: moreVenuesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final venues = snapshot.data!;
                    return venues.isNotEmpty
                        ? SliverToBoxAdapter(
                            child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 18),
                            height: 200,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: venues.length,
                                itemBuilder: (context, index) {
                                  final venue = venues[index];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        "$baseUrl/${venue.photos[0]}",
                                        fit: BoxFit.cover,
                                        height: 100,
                                        width: 130,
                                      ),
                                      Flexible(
                                          child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child:
                                            Text(venue.category.capitalize()),
                                      )),
                                      Flexible(child: Text(venue.address)),
                                      Flexible(
                                          child: Text(
                                              "${formatCurrency.format(venue.price)} TZS")),
                                    ],
                                  );
                                }),
                          ))
                        : SliverToBoxAdapter(
                            child: Text(
                                "No ${widget.property.category}'s like this found"));
                  } else if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text(snapshot.error.toString())),
                    );
                  } else {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                }),
        ],
      ),
      bottomNavigationBar: Container(
          height: 40,
          color: Colors.grey[200],
          child: GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.call,
                  color: Theme.of(context).primaryColorDark,
                ),
                const SizedBox(width: 8),
                const Text("Call")
              ],
            ),
          )),
    );
  }

  buildHomesWidget(Listing listing) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // cat
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 5),
              child: Text(
                listing.category.capitalize(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Text(listing.name.capitalize()),
                    ),
                    Wrap(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 16,
                        ),
                        Text(listing.address.capitalize(),
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(fontSize: 13)),
                      ],
                    )
                  ],
                ),
                Text("${formatCurrency.format(listing.price)} TZS",
                    style: Theme.of(context).textTheme.bodyText1)
              ],
            ),

            const SizedBox(height: 20),

            ///details
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Property Details',
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            // size
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Property Size',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontSize: 13),
                  ),
                  Text("${listing.size} sqm"),
                ],
              ),
            ),
            if (listing.category != "flat")
              // beds
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bedrooms',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontSize: 13),
                    ),
                    Text(listing.beds.toString()),
                  ],
                ),
              ),
            if (listing.category != "flat")
              // baths
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bathrooms',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontSize: 13),
                    ),
                    Text(listing.baths.toString()),
                  ],
                ),
              ),
            // furnished
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Furnished',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontSize: 13),
                  ),
                  Text(listing.isfurnished ? "Furnished" : "Unfurnished"),
                ],
              ),
            ),
            if (listing.category != "flat")
              // pets
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pets',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontSize: 13),
                    ),
                    Text(listing.ispets ? "Pets Allowed" : "Pets Not Allowed"),
                  ],
                ),
              ),

            // contract
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contract Type',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontSize: 13),
                  ),
                  Text(listing.nature),
                ],
              ),
            ),

            if (listing.nature == "rent")
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Duration',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontSize: 13),
                    ),
                    Text(listing.duration),
                  ],
                ),
              ),

            // negotiable
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Price negotiable',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontSize: 13),
                  ),
                  Text(listing.isnegotiable ? "Yes" : "No"),
                ],
              ),
            ),

            //  dalali fee
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Agency Fee',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontSize: 13),
                  ),
                  Text("${formatCurrency.format(listing.dalaliFee)} TZS"),
                ],
              ),
            ),

            // amenities
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("Amenities",
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            Wrap(
              children: listing.amenities
                  .map(
                    (amenity) => Container(
                        margin: const EdgeInsets.only(right: 18),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                        ),
                        child: Text(
                          amenity,
                        )),
                  )
                  .toList(),
            ),

            const SizedBox(height: 20),
            // desc
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text('Description',
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            Text(listing.description),
          ],
        ),
      ),
    );
  }

  buildLandsWidget(Land land) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // cat
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 5),
              child: Text(
                land.category.capitalize(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Text(land.title),
                    ),
                    Wrap(
                      children: [
                        const Icon(Icons.place, size: 16),
                        Text(land.address.capitalize(),
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(fontSize: 13)),
                      ],
                    )
                  ],
                ),
                Text("${formatCurrency.format(land.price)} TZS",
                    style: Theme.of(context).textTheme.bodyText1)
              ],
            ),

            const SizedBox(height: 20),

            ///details
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Property Details',
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            // size
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Property Size',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontSize: 13),
                  ),
                  Text("${land.size} sqm"),
                ],
              ),
            ),

            // contract
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Contract Type',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontSize: 13)),
                  Text(land.nature),
                ],
              ),
            ),

            // negotiable
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Price negotiable',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontSize: 13)),
                  Text(land.isnegotiable ? "Yes" : "No"),
                ],
              ),
            ),

            //  dalali fee
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Agency Fee',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontSize: 13)),
                  Text("${formatCurrency.format(land.dalaliFee)} TZS")
                ],
              ),
            ),

            const SizedBox(height: 20),
            // desc
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text('Description',
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            Text(land.description),
          ],
        ),
      ),
    );
  }

  buildVenuesWidget(Venue venue) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // cat
          Text(venue.category),
          Row(
            children: [
              Column(
                children: [
                  Text(venue.title),
                  Row(
                    children: [
                      const Icon(Icons.place),
                      Text(venue.address),
                    ],
                  )
                ],
              ),
              Text(venue.price.toString()),
            ],
          ),

          const SizedBox(height: 20),

          ///details
          Text('Property Details'),
          // size
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Property Size'),
              Text("${venue.capacity} people"),
            ],
          ),

          // contract
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Contract Type'),
              Text(venue.nature),
            ],
          ),

          // negotiable
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price negotiable'),
              Text(venue.isnegotiable ? "Yes" : "No"),
            ],
          ),

          //  dalali fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Agency Fee'),
              Text("${formatCurrency.format(venue.dalaliFee)} TZS"),
            ],
          ),

          const SizedBox(height: 20),
          // desc
          Text('Description'),
          Text(venue.description),
        ],
      ),
    );
  }

  // get agent user
  void getAgentUser(RestApi api) {
    final futureUser = api.getUser(widget.property.hostId);
    setState(() {
      futureAgent = futureUser;
    });
  }

  // get more listings
  void getMoreListings(RestApi api, Listing listing) {
    final future =
        api.getMoreListings(id: listing.listingId, category: listing.category);
    setState(() {
      moreListingsFuture = future;
    });
  }

  void getMoreLands(RestApi api, Land land) {
    final future = api.getMoreLands(id: land.landId, category: land.category);
    setState(() {
      moreLandsFuture = future;
    });
  }

  void getMoreVenues(RestApi api, Venue venue) {
    final future =
        api.getMoreVenues(id: venue.venueId, category: venue.category);
    setState(() {
      moreVenuesFuture = future;
    });
  }
}
