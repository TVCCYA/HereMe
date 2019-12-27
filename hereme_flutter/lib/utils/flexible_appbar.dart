import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/utils/reusable_profile_card.dart';

class FlexibleAppBar extends StatelessWidget {
  final double appBarHeight = 66.0;

  const FlexibleAppBar(
      {@required this.userPhotoUrl,
        this.changeUserPhoto,
        this.topProfileContainerHeight});

  final String userPhotoUrl;
  final Function changeUserPhoto;
  final double topProfileContainerHeight;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;

    return new Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight + appBarHeight,
      child: new Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: topProfileContainerHeight,
                      width: screenWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ReusableProfileCard(
                                imageUrl: userPhotoUrl,
                                cardSize: topProfileContainerHeight,
                                onTap: changeUserPhoto,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 24.0, right: 4.0, top: 24.0),
                                  child: Container(
                                    height: topProfileContainerHeight / 2,
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Visits this week: 10k',
                                            style: kAppBarTextStyle),
                                        Text('Total Visits: 100k',
                                            style: kAppBarTextStyle),
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              FontAwesomeIcons.mapMarkerAlt,
                                              color: kColorRed,
                                              size: 14.0,
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(
                                              'Here',
                                              style: kAppBarTextStyle,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 24.0, bottom: 8.0, right: 24.0),
                            child: Container(
                              color: kColorLightGray,
                              height: 1.5,
                              width: screenWidth,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
            ],
          )),
      decoration: BoxDecoration(
        color: kColorOffWhite,
      ),
    );
  }
}