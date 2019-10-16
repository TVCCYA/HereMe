import 'package:flutter/material.dart';
import 'log_in.dart';
import 'sign_up.dart';
import 'package:hereme_flutter/contants/constants.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
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
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 250.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(const Radius.circular(10.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[800],
                        blurRadius: 5.0, // has the effect of softening the shadow
                        spreadRadius: 2.0, // has the effect of extending the shadow
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
                          'Welcome to HereMe',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Berlin-Sans',
                            fontSize: 32.0,
                            color: kColorPurple,
                          ),
                        ),
                        Text(
                          'Discover the social media presence\n of people nearby',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            color: kColorPurple,
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
                              textColor: Color.fromRGBO(154, 138, 212, 1.0),
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
                              textColor: Color.fromRGBO(154, 138, 212, 1.0),
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
