import 'dart:io';
import 'package:dirm/modal/land.dart';
import 'package:dirm/modal/listing.dart';
import 'package:dirm/modal/subcategory.dart';
import 'package:dirm/modal/user.dart';
import 'package:dirm/modal/venue.dart';
import 'package:dirm/services/storage/database_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:path/path.dart';

import '../../util/constants.dart';

class RestApi {
  final dbClient = DatabaseService();

  // register
  Future<Map<String, dynamic>> register(User user) async {
    const String url = "/auth/register";
    final jsonBody = {
      "name": user.name,
      "phone": user.phone,
      "email": user.email,
      "password": user.password,
    };
    try {
      final response = await http.post(Uri.parse(baseUrl + url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 201) {
        final resultMap = jsonDecode(response.body);
        // return user and token
        final token = resultMap['token'];
        final user = User.fromJson(jsonEncode(resultMap['user']));

        return <String, dynamic>{
          'user': user,
          'token': token,
        };
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('registration failed, try again: ${e.toString()}');
    }
  }

  //login
  Future<Map<String, dynamic>> login(
      {required String email, required String password}) async {
    const String loginUrl = "/auth/login";
    final jsonBody = {"email": email, "password": password};
    try {
      final response = await http.post(Uri.parse(baseUrl + loginUrl),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 201) {
        final resultMap = jsonDecode(response.body);
        // return user and token
        final token = resultMap['token'];
        final user = User.fromJson(jsonEncode(resultMap['user']));
        return <String, dynamic>{
          'user': user,
          'token': token,
        };
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('log in failed, try again: ${e.toString()}');
    }
  }

  // send otp
  Future<String> fetchOtp(
      {required String userId, required String phone}) async {
    final String url = "/auth/send-otp/$userId";
    final jsonBody = {"phone": phone};
    try {
      final response = await http.post(Uri.parse(baseUrl + url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 201 || response.statusCode == 200) {
        final map = jsonDecode(response.body);
        final otp = map['otp'];
        print("otp: $otp");
        // return otp
        return otp;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('sending OTP failed due to: ${e.toString()}, try again');
    }
  }

  // vrf otp
  Future<void> verifyOtp({required String userId, required String otp}) async {
    final String url = "/auth/verify-otp/$userId";
    final jsonBody = {"otp": otp};
    try {
      final response = await http.post(Uri.parse(baseUrl + url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("otp: ${jsonDecode(response.body)}");
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception(
          'phone verification failed due to: ${e.toString()}, try again');
    }
  }

  // check phn
  Future<User> checkPhone(String phone) async {
    final String url = "/auth/check-phone/$phone";
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resultMap = jsonDecode(response.body);
        // return user and token
        final user = User.fromJson(jsonEncode(resultMap['user']));
        return user;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Failed due to: ${e.toString()}, try again');
    }
  }

  // chng pass
  Future<void> changePassword(
      {required String userId, required String password}) async {
    final String url = "/auth/change-password/$userId";
    final jsonBody = {"password": password};
    try {
      final response = await http.post(Uri.parse(baseUrl + url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("status: ${jsonDecode(response.body)}");
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception(
          'password change failed due to: ${e.toString()}, try again');
    }
  }

// get all listings
  Future<List<Listing>> getListings() async {
    const String url = "/listings";
    List<Listing> listings = <Listing>[];
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        List bodyList = json.decode(response.body);
        print("result: $bodyList");
        // add response to listings
        listings.addAll(
            bodyList.map((listing) => Listing.fromJson(json.encode(listing))));
        return listings;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  //get listings by cat
  Future<List<Listing>> getListingsByCat(String cat) async {
    String url = "/listings/$cat";
    List<Listing> listings = <Listing>[];
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        List bodyList = json.decode(response.body);
        print("result: $bodyList");
        // add response to listings
        listings.addAll(
            bodyList.map((listing) => Listing.fromJson(json.encode(listing))));

        return listings;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

// get more listings
  Future<List<Listing>> getMoreListings(
      {required String id, required String category}) async {
    const String url = "/listings/more";
    List<Listing> listings = <Listing>[];
    final jsonBody = {"id": id, "category": category};
    try {
      final response = await http.post(Uri.parse(baseUrl + url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 201 || response.statusCode == 200) {
        List bodyList = json.decode(response.body);
        print("result: $bodyList");
        listings.addAll(
            bodyList.map((listing) => Listing.fromJson(json.encode(listing))));
        return listings;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

// get all lands
  Future<List<Land>> getLands() async {
    const String url = "/plots";
    List<Land> lands = <Land>[];
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        List bodyList = json.decode(response.body);
        print("result: $bodyList");
        // add response to listings
        lands.addAll(bodyList.map((land) => Land.fromJson(json.encode(land))));
        return lands;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  Future<List<Land>> getMoreLands(
      {required String id, required String category}) async {
    const String url = "/plots/more";
    List<Land> lands = <Land>[];
    final jsonBody = {"id": id, "category": category};
    try {
      final response = await http.post(Uri.parse(baseUrl + url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 201 || response.statusCode == 200) {
        List bodyList = json.decode(response.body);
        print("result: $bodyList");
        lands.addAll(bodyList.map((land) => Land.fromJson(json.encode(land))));
        return lands;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  // get  lands
  Future<List<Land>> getLandsByCat(String cat) async {
    String url = "/plots/$cat";
    List<Land> lands = <Land>[];
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        List bodyList = json.decode(response.body);
        print("result: $bodyList");
        // add response to listings
        lands.addAll(bodyList.map((land) => Land.fromJson(json.encode(land))));
        return lands;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  // get all venues
  Future<List<Venue>> getVenues() async {
    const String url = "/venues";
    List<Venue> venues = <Venue>[];
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        List bodyList = json.decode(response.body);
        print("result: $bodyList");
        // add response to listings
        venues.addAll(
            bodyList.map((venue) => Venue.fromJson(json.encode(venue))));
        return venues;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  Future<List<Venue>> getMoreVenues(
      {required String id, required String category}) async {
    const String url = "/plots/more";
    List<Venue> venues = <Venue>[];
    final jsonBody = {"id": id, "category": category};
    try {
      final response = await http.post(Uri.parse(baseUrl + url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 201 || response.statusCode == 200) {
        List bodyList = json.decode(response.body);
        print("result: $bodyList");
        venues.addAll(
            bodyList.map((venue) => Venue.fromJson(json.encode(venue))));
        return venues;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  // get all venues
  Future<List<Venue>> getVenuesByCat(String cat) async {
    String url = "/venues/$cat";
    List<Venue> venues = <Venue>[];
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        List bodyList = json.decode(response.body);
        print("result: $bodyList");
        // add response to listings
        venues.addAll(
            bodyList.map((venue) => Venue.fromJson(json.encode(venue))));
        return venues;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  // get subcats
  Future<void> getSubcats() async {
    const String url = "/subcategories";
    List<Subcategory> subcats = <Subcategory>[];
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        List bodyList = json.decode(response.body);
        print("result: $bodyList");
        // add response to cats
        subcats.addAll(bodyList
            .map((subcat) => Subcategory.fromJson(json.encode(subcat))));
        // save to db
        for (int i = 0; i < subcats.length; i++) {
          await dbClient.saveSubcat(subcats[i]);
        }
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  // get user
  Future<User> getUser(String userId) async {
    final String url = "/user/$userId";
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        print("result: $body");
        final user = User.fromJson(response.body);
        return user;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  // count user properties
  Future<int> countUserProps(String userId) async {
    final String url = "/user/$userId/count-props";
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        print("result: $body");
        final count = body;
        return count;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  // reg seller
  Future registerSeller({required String userId, required File image}) async {
    //create url
    const String url = "/seller";
    try {
      // create a multpart request
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(baseUrl + url));
      // multipartfiles
      http.MultipartFile multipartFile = http.MultipartFile(
          'image', image.readAsBytes().asStream(), image.lengthSync(),
          filename: basename(image.path));
      // add file
      request.files.add(multipartFile);
      // add id field
      request.fields.addAll({"userId": userId});
      // send req
      var response = await request.send();
      // fetch body
      String body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        print('success');
      }
      // bad response 400
      else {
        final result = jsonDecode(body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  // get user subs
  Future<bool> checkSubscription(String userId) async {
    final String url = "/user/$userId/subscription-status";
    try {
      final response = await http.get(Uri.parse(baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        print("result: $body");
        return body;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  // add listing
  Future<String> addListing(Listing listing) async {
    const String url = "/listings";
    final jsonBody = listing.toJson();
    print(jsonBody);
    try {
      final response = await http.post(Uri.parse(baseUrl + url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 201) {
        final id = jsonDecode(response.body);
        print("status: $id");
        return id;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}, try again');
    }
  }

  // add listing images
  Future addListingImages(String listingId, List<File> photos) async {
    //create url
    final String url = "/listings/$listingId/images";
    try {
      // create a multpart request
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(baseUrl + url));
      // create  multipartfiles
      Iterable<http.MultipartFile> multipartFiles = photos.map(
        (file) => http.MultipartFile(
          'photos',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: basename(file.path),
        ),
      );
      //add files
      request.files.addAll(multipartFiles);
      // send req
      var response = await request.send();
      // fetch body
      String body = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        print('listing images uploaded');
        print('body output: $body');
      }
      // bad response 400
      else {
        print('listing images failed to upload');
        final result = jsonDecode(body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  // add land
  Future<String> addLand(Land land) async {
    const String url = "/plots";
    final jsonBody = land.toJson();
    print(jsonBody);
    try {
      final response = await http.post(Uri.parse(baseUrl + url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 201) {
        final id = jsonDecode(response.body);
        print("status: $id");
        return id;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}, try again');
    }
  }

  // add land images
  Future addLandImages(String landId, List<File> photos) async {
    //create url
    final String url = "/plots/$landId/images";
    try {
      // create a multpart request
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(baseUrl + url));
      // create  multipartfiles
      Iterable<http.MultipartFile> multipartFiles = photos.map(
        (file) => http.MultipartFile(
          'photos',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: basename(file.path),
        ),
      );
      //add files
      request.files.addAll(multipartFiles);
      // send req
      var response = await request.send();
      // fetch body
      String body = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        print('images uploaded');
        print('body output: $body');
      }
      // bad response 400
      else {
        print('images failed to upload');
        final result = jsonDecode(body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }

  // add venue
  Future<String> addVenue(Venue venue) async {
    const String url = "/venues";
    final jsonBody = venue.toJson();
    try {
      final response = await http.post(Uri.parse(baseUrl + url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 201) {
        final id = jsonDecode(response.body);
        print("status: $id");
        return id;
      } else {
        final result = jsonDecode(response.body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}, try again');
    }
  }

  // add venue images
  Future addVenueImages(String venueId, List<File> photos) async {
    //create url
    final String url = "/venues/$venueId/images";
    try {
      // create a multpart request
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(baseUrl + url));
      // create  multipartfiles
      Iterable<http.MultipartFile> multipartFiles = photos.map(
        (file) => http.MultipartFile(
          'photos',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: basename(file.path),
        ),
      );
      //add files
      request.files.addAll(multipartFiles);
      // send req
      var response = await request.send();
      // fetch body
      String body = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        print('images uploaded');
        print('body output: $body');
      }
      // bad response 400
      else {
        print('images failed to upload');
        final result = jsonDecode(body);
        throw Exception('${result['error']}');
      }
    } catch (e) {
      throw Exception('Oops something went wrong: ${e.toString()}');
    }
  }
}
