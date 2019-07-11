import 'package:flutter/material.dart';
import 'package:hereme_flutter/TabController.dart';
import 'package:hereme_flutter/UserProfile/ProfilePage/UserProfilePage.dart';
import '../SignUp&In/InitialPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

//import 'package:flutter_geofire/flutter_geofire.dart';
//import 'package:location/location.dart';

class GridFindCollectionPage extends StatefulWidget {
  @override
  _GridFindCollectionPageState createState() => _GridFindCollectionPageState();
}

class _GridFindCollectionPageState extends State<GridFindCollectionPage>
    with RouteAware, AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _isUserLoggedIn();
    _getFirebaseProfiles();
  }

//  @override
//  void didChangeAppLifecycleState(AppLifecycleState state) {
//    setState(() { _getFirebaseProfiles(); });
//  }
  @override
  bool get wantKeepAlive => true;

//  bool get wantKeepAlive => keepGridAlive == null ? true : keepGridAlive;

  Widget build(BuildContext context) {
    void _onTileClicked(int index) async {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserProfile(
                  passedProfile: firebaseProfiles[index],
                )),
      );
    }

    List<Widget> _getTiles() {
      final List<Widget> tiles = <Widget>[];
      for (int i = 0; i < firebaseProfiles.length; i++) {
        tiles.add(new GridTile(
            child: new InkResponse(
          enableFeedback: true,
          child: new Card(
            margin: EdgeInsets.all(0.0),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: new ClipRRect(
              borderRadius: new BorderRadius.circular(15.0),
              child: new CachedNetworkImage(
                imageUrl: firebaseProfiles[i].profileImageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          onTap: () => _onTileClicked(i),
        )));
      }
      return tiles;
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
//          elevation: 5.0,
          brightness: Brightness.light,
          backgroundColor: Colors.offWhite,
          title: new Text(
            "HereMe",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.mainPurple,
              fontStyle: FontStyle.normal,
              fontSize: 24.0,
//            fontFamily: 'Avenir-Heavy',
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: new RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: new GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.all(1.0),
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 1.0,
              children: _getTiles(),
            ),
        ));
  }

  _refresh() {
    print("printy boi");
  }

  void _isUserLoggedIn() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.currentUser().then((value) {
      if (value == null) {
        var route = new MaterialPageRoute(
            builder: (BuildContext context) => new InitialPage());
        Navigator.of(context).push(route);
      } else {
        //Todo successful user log in
      }
    });
  }

  void _getFirebaseProfiles() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final socialMediasReference = await Firestore.instance.collection("users");

    socialMediasReference.snapshots().listen((media) {
      for (int i = 0; i < media.documents.length; i++) {
        firebaseProfiles.add(Profiles(
            profileImageUrl: media.documents[i].data["profileImageUrl"],
            uid: media.documents[i].data["uid"],
            username: media.documents[i].data["username"]));
      }
    });
  }
}

class Profiles {
  Profiles({this.profileImageUrl, this.uid, this.username});

  final String profileImageUrl;
  final String uid;
  final String username;
}

List<Profiles> firebaseProfiles = [];
