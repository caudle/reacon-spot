import 'dart:io';

import 'package:dirm/modal/land.dart';
import 'package:dirm/modal/listing.dart';
import 'package:dirm/modal/user.dart';
import 'package:dirm/modal/venue.dart';
import 'package:dirm/services/api/rest_api.dart';
import 'package:dirm/services/storage/database_service.dart';
import 'package:dirm/util/shared.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect/multiselect.dart';

import '../../modal/subcategory.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> with AutomaticKeepAliveClientMixin {
  RestApi api = RestApi();
  DatabaseService dB = DatabaseService();
  Future<User>? futureUser;
  //User? currentUser;
  File? idCard;
  ImagePicker picker = ImagePicker();
  List<XFile>? photos = [];
  bool isloading = false;
  Future<bool>? futureSubscriptionStatus;
  Future<List<Subcategory>>? _futureListingSubCats;
  Future<List<Subcategory>>? _futureLandSubCats;
  Future<List<Subcategory>>? _futureVenueSubCats;
  List<String> categories = [
    "home",
    "land",
    "event"
  ]; // for alternating in tabbar ontap fxn
  List<String> amenitiesOptions = [
    "parking",
    "electric fence",
    "swimming pool"
  ];
  List<String> durationsOptions = ["any", "per hour", "daily", "per week"];

  String durationDropdownValue = "any";

  List<String> selectedAmenities = [];
  String currentCat = "home";
  String listingDropdownValue = "apartment";
  String landDropdownValue = "commercial";
  String venueDropdownValue = "multipurpose hall";
  List<String> natures = ["rent", "sale"];
  String naturesDropdownValue = "rent";
  List<String> isValues = ["yes", "no"]; // for isfurnished,ispet & isnego
  String isfurnishedDropdownValue = "no";
  String ispetsDropdownValue = "no";
  String isnegotiableDropdownValue = "no";
  //controllers
  TextEditingController addressController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController bedsController = TextEditingController();
  TextEditingController bathsController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController dalaliController = TextEditingController();
  TextEditingController descController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    checkUserType();
    checkSubscription();
    // get all subcats
    loadListingSubCats();
    loadLandSubCats();
    loadVenueSubCats();
    super.initState();
  }

  void loadListingSubCats() {
    final subcats = dB.getSubcatsByCat("home");
    setState(() {
      _futureListingSubCats = subcats;
    });
  }

  void loadLandSubCats() {
    final subcats = dB.getSubcatsByCat("land");
    setState(() {
      _futureLandSubCats = subcats;
    });
  }

  void loadVenueSubCats() {
    final subcats = dB.getSubcatsByCat("event");
    setState(() {
      _futureVenueSubCats = subcats;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
      ),
      body: FutureBuilder<User>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //chek user typs
            final user = snapshot.data!;
            if (user.type == 'customer') {
              /// cutomer widget
              return Column(children: [
                const Text('Register'),
                const Text('Upload ID card for verification'),
                const Text(
                    'Allowed ID cards are NIDA, Driving license and Voters Card'),
                Row(
                  children: [
                    const Text('ID card'),
                    IconButton(
                        onPressed: onCameraIconPressed,
                        icon: const Icon(Icons.camera)),
                  ],
                ),
                const Text('Only .jpg,.jpeg and .png file types are allowed'),
                Offstage(
                  offstage: isloading,
                  child: ElevatedButton(
                      onPressed: idCard != null
                          ? () {
                              // start loading
                              setState(() {
                                isloading = true;
                              });
                              onSendPressed(user.userId).then((_) {
                                // check user type
                                final futureUResult = api.getUser(user.userId);
                                setState(() {
                                  isloading = false;
                                  futureUser = futureUResult;
                                });
                              }, onError: (e) {
                                setState(() {
                                  isloading = false;
                                });
                                showSnackBar(
                                    context: context, message: e.toString());
                              });
                            }
                          : null,
                      child: const Text('Send')),
                ),
                if (isloading) const CircularProgressIndicator()
              ]);
            } else if (user.type == 'pending') {
              /// pending widget
              return const Center(child: Text('Pending confirmation'));
            } else if (user.type == 'seller') {
              /// seller widget
              return FutureBuilder<bool>(
                  future: futureSubscriptionStatus,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final isSub = snapshot.data!;
                      if (isSub) {
                        // show widget based on cat
                        return isloading
                            ? const Center(child: CircularProgressIndicator())
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 18),
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  child: CustomScrollView(
                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 16),
                                          child: Text('Property Type',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall),
                                        ),
                                      ),

                                      /// cats dropdown
                                      SliverToBoxAdapter(
                                        child: DropdownButtonFormField<String>(
                                          items: categories
                                              .map((cat) => DropdownMenuItem(
                                                  value: cat,
                                                  child: Text('${cat}s')))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              currentCat = value!;
                                            });
                                          },
                                          value: currentCat,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .primaryColorLight)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .primaryColorLight)),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.red)),
                                            errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: Colors.red)),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 15),
                                          ),
                                        ),
                                      ),
                                      const SliverToBoxAdapter(
                                        child: SizedBox(height: 16),
                                      ),

                                      /// subcats dropdown
                                      /// home sucats
                                      if (currentCat == "home")
                                        FutureBuilder<List<Subcategory>>(
                                            key: ValueKey(currentCat),
                                            future: _futureListingSubCats,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                final cats = snapshot.data!;
                                                return cats.isNotEmpty
                                                    ? SliverToBoxAdapter(
                                                        child:
                                                            DropdownButtonFormField<
                                                                String>(
                                                          items: cats
                                                              .map((cat) =>
                                                                  DropdownMenuItem(
                                                                      value: cat
                                                                          .name,
                                                                      child: Text(
                                                                          cat.name)))
                                                              .toList(),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              listingDropdownValue =
                                                                  value!;
                                                            });
                                                          },
                                                          value:
                                                              listingDropdownValue,
                                                          decoration:
                                                              InputDecoration(
                                                            enabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide: BorderSide(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorLight)),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide: BorderSide(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorLight)),
                                                            focusedErrorBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red)),
                                                            errorBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red)),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        15,
                                                                    horizontal:
                                                                        15),
                                                          ),
                                                        ),
                                                      )
                                                    : const SliverToBoxAdapter(
                                                        child: Text('empty'));
                                              } else if (snapshot.hasError) {
                                                return SliverToBoxAdapter(
                                                  child: Center(
                                                      child: Text(
                                                          'from cats: ${snapshot.error.toString()}')),
                                                );
                                              } else {
                                                return const SliverToBoxAdapter(
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                );
                                              }
                                            }),

                                      /// land subcats
                                      if (currentCat == "land")
                                        FutureBuilder<List<Subcategory>>(
                                            key: ValueKey(currentCat),
                                            future: _futureLandSubCats,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                final cats = snapshot.data!;
                                                return cats.isNotEmpty
                                                    ? SliverToBoxAdapter(
                                                        child:
                                                            DropdownButtonFormField<
                                                                String>(
                                                          items: cats
                                                              .map((cat) =>
                                                                  DropdownMenuItem(
                                                                      value: cat
                                                                          .name,
                                                                      child: Text(
                                                                          cat.name)))
                                                              .toList(),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              landDropdownValue =
                                                                  value!;
                                                            });
                                                          },
                                                          value:
                                                              landDropdownValue,
                                                          decoration:
                                                              InputDecoration(
                                                            enabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide: BorderSide(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorLight)),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide: BorderSide(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorLight)),
                                                            focusedErrorBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red)),
                                                            errorBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red)),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        15,
                                                                    horizontal:
                                                                        15),
                                                          ),
                                                        ),
                                                      )
                                                    : const SliverToBoxAdapter();
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                    child: Text(
                                                        'from cats: ${snapshot.error.toString()}'));
                                              } else {
                                                return const SliverToBoxAdapter(
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                );
                                              }
                                            }),

                                      /// venue subcats
                                      if (currentCat == "event")
                                        FutureBuilder<List<Subcategory>>(
                                            key: ValueKey(currentCat),
                                            future: _futureVenueSubCats,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                final cats = snapshot.data!;
                                                return cats.isNotEmpty
                                                    ? SliverToBoxAdapter(
                                                        child:
                                                            DropdownButtonFormField<
                                                                String>(
                                                          items: cats
                                                              .map((cat) =>
                                                                  DropdownMenuItem(
                                                                      value: cat
                                                                          .name,
                                                                      child: Text(
                                                                          cat.name)))
                                                              .toList(),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              venueDropdownValue =
                                                                  value!;
                                                            });
                                                          },
                                                          value:
                                                              venueDropdownValue,
                                                          decoration:
                                                              InputDecoration(
                                                            enabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide: BorderSide(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorLight)),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide: BorderSide(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorLight)),
                                                            focusedErrorBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red)),
                                                            errorBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red)),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        15,
                                                                    horizontal:
                                                                        15),
                                                          ),
                                                        ),
                                                      )
                                                    : const SliverToBoxAdapter();
                                              } else if (snapshot.hasError) {
                                                return SliverToBoxAdapter(
                                                  child: Center(
                                                      child: Text(snapshot.error
                                                          .toString())),
                                                );
                                              } else {
                                                return const SliverToBoxAdapter(
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                );
                                              }
                                            }),
                                      const SliverToBoxAdapter(
                                        child: SizedBox(height: 16),
                                      ),

                                      ///natures drop down
                                      SliverToBoxAdapter(
                                        child: DropdownButtonFormField<String>(
                                          items: natures
                                              .map((value) => DropdownMenuItem(
                                                  value: value,
                                                  child: Text(value)))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              naturesDropdownValue = value!;
                                            });
                                          },
                                          value: naturesDropdownValue,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .primaryColorLight)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .primaryColorLight)),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.red)),
                                            errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: Colors.red)),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 15),
                                          ),
                                        ),
                                      ),

                                      const SliverToBoxAdapter(
                                        child: SizedBox(height: 16),
                                      ),
                                      // images
                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 5),
                                          child: Text('Photos',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall),
                                        ),
                                      ),
                                      const SliverToBoxAdapter(
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 8.0),
                                          child: Text(
                                              'Add six (6) images of your property'),
                                        ),
                                      ),
                                      SliverToBoxAdapter(
                                          child: Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 10),
                                            height: 40,
                                            width: 90,
                                            color: Colors.grey[200],
                                            child: IconButton(
                                                onPressed: getImages,
                                                icon: const Icon(Icons.add)),
                                          ),
                                        ],
                                      )),
                                      if (photos!.isNotEmpty)
                                        SliverToBoxAdapter(
                                            child: Container(
                                          margin: const EdgeInsets.only(
                                              right: 5, bottom: 8),
                                          height: 70,
                                          width: 110,
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: List.generate(
                                                photos!.length, (index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: Image.file(
                                                    File(photos![index].path)),
                                              );
                                            }).toList(),
                                          ),
                                        )),

                                      //txt
                                      SliverToBoxAdapter(
                                        child: Text(
                                            "First image is the title image",
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption),
                                      ),
                                      SliverToBoxAdapter(
                                        child: Text(
                                            """Supported formats are .jpg, .jpeg and.png""",
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption),
                                      ),

                                      /// omly use if stats to diff

                                      // address
                                      SliverPadding(
                                        padding: const EdgeInsets.only(
                                            top: 16.0, bottom: 8),
                                        sliver: SliverToBoxAdapter(
                                          child: TextFormField(
                                            controller: addressController,
                                            decoration: InputDecoration(
                                              label: const Text(
                                                  'Property address*'),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.red)),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color: Colors.red)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 15),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "field is required";
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      // name
                                      SliverPadding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 8),
                                        sliver: SliverToBoxAdapter(
                                          child: TextFormField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                              label: Text(currentCat == "home"
                                                  ? "Property name*"
                                                  : "Property title*"),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.red)),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color: Colors.red)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 15),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "field is required";
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      // baths
                                      if (currentCat == "home" &&
                                          listingDropdownValue != "flat")
                                        SliverPadding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          sliver: SliverToBoxAdapter(
                                            child: TextFormField(
                                              controller: bathsController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                label: const Text('Bathrooms*'),
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .red)),
                                                errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.red)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 15),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return "field is required";
                                                } else {
                                                  return null;
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      // bed
                                      if (currentCat == "home" &&
                                          listingDropdownValue != "flat")
                                        SliverPadding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 8),
                                          sliver: SliverToBoxAdapter(
                                            child: TextFormField(
                                              controller: bedsController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                label: const Text('Bedrooms*'),
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .red)),
                                                errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.red)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 15),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return "field is required";
                                                } else {
                                                  return null;
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      // size
                                      if (currentCat == "home" ||
                                          currentCat == "land")
                                        SliverPadding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 8),
                                          sliver: SliverToBoxAdapter(
                                            child: TextFormField(
                                              controller: sizeController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                label:
                                                    const Text('Size in sqm*'),
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .red)),
                                                errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.red)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 15),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return "field is required";
                                                } else {
                                                  return null;
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      // capacity
                                      if (currentCat == "event")
                                        SliverPadding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 8),
                                          sliver: SliverToBoxAdapter(
                                            child: TextFormField(
                                              controller: capacityController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                label: Text('Capacity*'),
                                                hintText: "200 people",
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .red)),
                                                errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.red)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 15),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return "field is required";
                                                } else {
                                                  return null;
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      // amenities
                                      if (currentCat == "home")
                                        SliverPadding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 8),
                                          sliver: SliverToBoxAdapter(
                                            child: DropDownMultiSelect(
                                              options: amenitiesOptions,
                                              selectedValues: selectedAmenities,
                                              onChanged: (values) {
                                                setState(() {
                                                  selectedAmenities = values;
                                                });
                                              },
                                              //whenEmpty: "Amenities*",
                                              decoration: InputDecoration(
                                                labelText: 'Amenities',
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .red)),
                                                errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.red)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 15),
                                              ),
                                            ),
                                          ),
                                        ),

                                      // furnished
                                      if (currentCat == "home")
                                        SliverPadding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 8),
                                          sliver: SliverToBoxAdapter(
                                            child:
                                                DropdownButtonFormField<String>(
                                              items: isValues
                                                  .map((isValue) =>
                                                      DropdownMenuItem(
                                                          value: isValue,
                                                          child: Text(isValue)))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  isfurnishedDropdownValue =
                                                      value!;
                                                });
                                              },
                                              value: isfurnishedDropdownValue,
                                              decoration: InputDecoration(
                                                labelText: 'Furnished',
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .red)),
                                                errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.red)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 15),
                                              ),
                                            ),
                                          ),
                                        ),
                                      // pets
                                      if (currentCat == "home")
                                        SliverPadding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 8),
                                          sliver: SliverToBoxAdapter(
                                            child:
                                                DropdownButtonFormField<String>(
                                              items: isValues
                                                  .map((isValue) =>
                                                      DropdownMenuItem(
                                                          value: isValue,
                                                          child: Text(isValue)))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  ispetsDropdownValue = value!;
                                                });
                                              },
                                              value: ispetsDropdownValue,
                                              decoration: InputDecoration(
                                                labelText: 'Pets',
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .red)),
                                                errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.red)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 15),
                                              ),
                                            ),
                                          ),
                                        ),
                                      // price
                                      SliverPadding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 8),
                                        sliver: SliverToBoxAdapter(
                                          child: TextFormField(
                                            controller: priceController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              label: Text(
                                                  naturesDropdownValue == "rent"
                                                      ? "Price*"
                                                      : "Price*"),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.red)),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color: Colors.red)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 15),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "field is required";
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      // furnished
                                      if (currentCat == "event" &&
                                          naturesDropdownValue == "rent")
                                        SliverPadding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 8),
                                          sliver: SliverToBoxAdapter(
                                            child:
                                                DropdownButtonFormField<String>(
                                              items: durationsOptions
                                                  .map((duration) =>
                                                      DropdownMenuItem(
                                                          value: duration,
                                                          child:
                                                              Text(duration)))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  durationDropdownValue =
                                                      value!;
                                                });
                                              },
                                              value: durationDropdownValue,
                                              decoration: InputDecoration(
                                                labelText: 'Duration',
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .red)),
                                                errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.red)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 15),
                                              ),
                                            ),
                                          ),
                                        ),
                                      // negotiable
                                      SliverPadding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 8),
                                        sliver: SliverToBoxAdapter(
                                          child:
                                              DropdownButtonFormField<String>(
                                            items: isValues
                                                .map((isValue) =>
                                                    DropdownMenuItem(
                                                        value: isValue,
                                                        child: Text(isValue)))
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                isnegotiableDropdownValue =
                                                    value!;
                                              });
                                            },
                                            value: isnegotiableDropdownValue,
                                            decoration: InputDecoration(
                                              labelText: 'Negotiable',
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.red)),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color: Colors.red)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // dalali fee
                                      SliverPadding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 8),
                                        sliver: SliverToBoxAdapter(
                                          child: TextFormField(
                                            controller: dalaliController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              label: const Text('Dalali fee*'),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.red)),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color: Colors.red)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 15),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "field is required";
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      // descr
                                      SliverPadding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 8),
                                        sliver: SliverToBoxAdapter(
                                          child: TextFormField(
                                            controller: descController,
                                            maxLines: 3,
                                            decoration: InputDecoration(
                                              label: const Text('Description*'),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.red)),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color: Colors.red)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 15),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "field is required";
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ),

                                      // send btn
                                      SliverPadding(
                                        padding: const EdgeInsets.only(
                                            top: 18.0, bottom: 8),
                                        sliver: SliverToBoxAdapter(
                                          child: ElevatedButton(
                                              onPressed: () {
                                                //start loading
                                                setState(() {
                                                  isloading = true;
                                                });
                                                onAddPressed().then((value) {
                                                  if (value != null) {
                                                    // unvalidate
                                                    setState(() {
                                                      isloading = false;
                                                    });
                                                    showSnackBar(
                                                      context: context,
                                                      message: value,
                                                    );
                                                  } else {
                                                    setState(() {
                                                      isloading = false;
                                                    });
                                                    showSnackBar(
                                                      context: context,
                                                      message:
                                                          "Ad successful added",
                                                    );
                                                    clearValues();
                                                  }
                                                }, onError: (error) {
                                                  setState(() {
                                                    isloading = false;
                                                  });
                                                  showSnackBar(
                                                    context: context,
                                                    message: error.toString(),
                                                  );
                                                });
                                              },
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Theme.of(context)
                                                              .primaryColorDark),
                                                  fixedSize:
                                                      MaterialStateProperty.all(
                                                          Size(
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width,
                                                              50))),
                                              child: const Text('Send')),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                      } else {
                        return Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              RichText(
                                  text: const TextSpan(
                                      text: "You are currently not subscribed ",
                                      children: [
                                    TextSpan(
                                        text: """Press the button below to pay 
                                        for subscription""")
                                  ])),
                              ElevatedButton(
                                  onPressed: () {},
                                  child: const Text('Subscribe')),
                            ],
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                          child:
                              Text('from subs: ${snapshot.error.toString()}'));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  });
            } else {
              return Container();
            }
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> checkUserType() async {
    // get userid
    final user = await dB.getUser();
    final future = api.getUser(user!.userId);
    setState(() {
      futureUser = future;
    });
  }

  Future<void> checkSubscription() async {
    // get userid
    final user = await dB.getUser();
    final future = api.checkSubscription(user!.userId);
    setState(() {
      futureSubscriptionStatus = future;
    });
  }

  onCameraIconPressed() {
    // set up the buttons
    Widget galleryBtn = TextButton(
      child: const Text("Gallery"),
      onPressed: () {
        getIdCardFromGallery().then((_) => Navigator.of(context).pop());
      },
    );
    Widget cameraBtn = ElevatedButton(
      child: const Text("Camera"),
      onPressed: () {
        getIdCardFromCamera().then((_) => Navigator.of(context).pop());
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Take image"),
      actions: [galleryBtn, const SizedBox(width: 20), cameraBtn],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // get idcard from gallery
  Future getIdCardFromGallery() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          idCard = File(pickedFile.path);
        });
      } else {
        print('failed to get image from gallery');
      }
    } catch (e) {
      showSnackBar(context: context, message: e.toString());
    }
  }

  // get idcard from gallery
  Future getIdCardFromCamera() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          idCard = File(pickedFile.path);
        });
      } else {
        print('failed to get image from camera ');
      }
    } catch (e) {
      showSnackBar(context: context, message: e.toString());
    }
  }

  // get images
  Future getImages() async {
    try {
      var images = await picker.pickMultiImage();
      if (images != null) {
        if (images.isNotEmpty) {
          setState(() {
            photos!.addAll(images);
          });
        } else {
          print('failed to get images');
        }
      } else {
        print('failed to get images');
      }
    } catch (e) {
      showSnackBar(context: context, message: e.toString());
    }
  }

// reg seller
  Future onSendPressed(String userId) async {
    try {
      await api.registerSeller(userId: userId, image: idCard!);
    } catch (e) {
      throw Exception(e);
    }
  }

  // send btn
  Future<String?> onAddPressed() async {
    final user = await futureUser;
    // validation
    if (_formKey.currentState!.validate() && photos!.length == 6) {
      final filePhotos = photos!.map((xFile) => File(xFile.path)).toList();
      try {
        print('switching');
        switch (currentCat) {
          case "home":
            {
              print('home');
              //create listing model
              final listing = createListing(user!);
              final listingId = await api.addListing(listing);
              await api.addListingImages(listingId, filePhotos);
              return null;
            }
          case "land":
            {
              print('land');
              //create land model
              final land = createLand(user!);
              final landId = await api.addLand(land);
              await api.addLandImages(landId, filePhotos);
              return null;
            }
          case "event":
            {
              print('event');
              //create land model
              final venue = createVenue(user!);
              final venueId = await api.addVenue(venue);
              await api.addVenueImages(venueId, filePhotos);
              return null;
            }
          default:
            {
              print('default');
              return "error from default";
            }
        }
      } catch (e) {
        print("error occured: ${e.toString()}");
        throw Exception(e);
      }
    } else {
      return "* fields are required and images should be 6";
    }
  }

  Listing createListing(User user) {
    print("name: ${nameController.value.text}");
    return Listing(
      listingId: "",
      title: nameController.value.text,
      category: listingDropdownValue,
      nature: naturesDropdownValue,
      hostId: user.userId,
      baths: int.parse(bathsController.value.text.trim()),
      beds: int.parse(bedsController.value.text.trim()),
      size: double.parse(sizeController.value.text.trim()),
      address: addressController.value.text,
      amenities: selectedAmenities,
      isfurnished: isfurnishedDropdownValue == "yes",
      ispets: ispetsDropdownValue == "yes",
      isnegotiable: isnegotiableDropdownValue == "yes",
      photos: [],
      price: double.parse(priceController.value.text),
      description: descController.value.text,
      dalaliFee: double.parse(dalaliController.value.text),
      duration: "per month",
      createdAt: DateTime.now(),
    );
  }

  Land createLand(User user) {
    print('title ${nameController.value.text}');
    return Land(
      landId: "",
      title: nameController.value.text,
      category: landDropdownValue,
      nature: naturesDropdownValue,
      hostId: user.userId,
      size: double.parse(sizeController.value.text.trim()),
      address: addressController.value.text,
      photos: [],
      price: double.parse(priceController.value.text),
      isnegotiable: isnegotiableDropdownValue == "yes",
      description: descController.value.text,
      dalaliFee: double.parse(dalaliController.value.text),
      createdAt: DateTime.now(),
    );
  }

  Venue createVenue(User user) {
    return Venue(
      venueId: "",
      title: nameController.value.text,
      category: venueDropdownValue,
      nature: naturesDropdownValue,
      hostId: user.userId,
      capacity: int.parse(capacityController.value.text.trim()),
      address: addressController.value.text,
      photos: [],
      price: double.parse(priceController.value.text),
      isnegotiable: isnegotiableDropdownValue == "yes",
      description: descController.value.text,
      duration: durationDropdownValue,
      dalaliFee: double.parse(dalaliController.value.text),
      createdAt: DateTime.now(),
    );
  }

  void clearValues() {
    nameController.clear();
    bathsController.clear();
    bedsController.clear();
    sizeController.clear();
    addressController.clear();
    photos!.clear();
    priceController.clear();
    descController.clear();
    dalaliController.clear();
  }
}

//steps
//1 check what type of user
// if buyer show register as seller
// if pending show pending confirmation
// if seller check subscription
// if subscription ended show subscribe
// if subscribed show add listings options

//widgets
// show register as seller
// pending confirmation
// subscribe
// add listings
