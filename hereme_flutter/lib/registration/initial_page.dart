import 'package:flutter/material.dart';
import 'log_in.dart';
import 'sign_up.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/utils/reusable_button.dart';

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bubbly.png"),
            fit: BoxFit.none,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 225.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(const Radius.circular(10.0)),
                    boxShadow: [
                      BoxShadow(
                        color: kColorOffBlack,
                        blurRadius: 5.0,
                        spreadRadius: 2.0,
                        offset: Offset(
                          8.0, // horizontal, move right 10
                          8.0, // vertical, move down 10
                        ),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'HereMe',
                          textAlign: TextAlign.center,
                          style: kAppBarTextStyle.copyWith(
                            fontSize: 28.0,
                            color: kColorPurple,
                          ),
                        ),
                        Text(
                          'Connect with people nearby',
                          textAlign: TextAlign.center,
                          style: kDefaultTextStyle.copyWith(
                            color: kColorPurple,
                            fontSize: 18.0
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            ReusableButton(
                              title: 'Log In',
                              textColor: kColorDarkThistle,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LogIn()),
                                );
                              },
                            ),
                            Container(
                              width: 1.0,
                              height: 40.0,
                              color: kColorPurple,
                            ),
                            ReusableButton(
                              title: 'Sign Up',
                              textColor: kColorDarkThistle,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUp()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ].toList(),
            ),
          ),
        ),
      ),
    );
  }
}
