import 'package:flutter/material.dart';

class GridFindCollectionPage extends StatefulWidget {
  @override
  _GridFindCollectionPageState createState() => _GridFindCollectionPageState();
}

class _GridFindCollectionPageState extends State<GridFindCollectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // this will be set when a new tab is tapped
        fixedColor: Colors.offWhite,
        items: [
          BottomNavigationBarItem(
              icon: new Icon(Icons.home,
                color: Colors.mainPurple,
              ),
              title: new Text('Find Them', style: TextStyle(color: Colors.mainPurple,),),
              ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.mail, color: Colors.mainPurple),
            title: new Text('Photos'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.mail, color: Colors.mainPurple),
            title: new Text('Knocks'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.mainPurple), title: Text('Profile'))
        ],
      ),
      body: ListView(children: _getListData()),
    );
  }

  _getListData() {
    List<Widget> widgets = [];
    for (int i = 0; i < 100; i++) {
      widgets
          .add(Padding(padding: EdgeInsets.all(10.0), child: Text("Row $i")));
    }
    return widgets;
  }
}
