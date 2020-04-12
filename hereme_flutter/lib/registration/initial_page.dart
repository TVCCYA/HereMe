import 'package:flutter/material.dart';
import 'log_in.dart';
import 'sign_up.dart';
import 'package:hereme_flutter/constants.dart';

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorRed,
      appBar: AppBar(
        backgroundColor: kColorRed,
        elevation: 0.0,
        centerTitle: false,
        title: Text(
          'Spred',
          textAlign: TextAlign.left,
          style: kAppBarTextStyle.copyWith(
            color: kColorOffWhite,
            fontSize: 25.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Connect with\nPeople Nearby',
                textAlign: TextAlign.left,
                style: kAppBarTextStyle.copyWith(
                  color: kColorOffWhite,
                  fontSize: 32.0
                ),
              ),
              SizedBox(
                height: 36.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: 125.0,
                    child: FlatButton(
                      child: Text(
                        'Sign Up',
                        style: kAppBarTextStyle.copyWith(
                            fontSize: 16.0, color: Colors.white),
                      ),
                      color: Colors.transparent,
                      onPressed: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.white),
                      ),
                      splashColor: kColorDarkRed,
                      highlightColor: Colors.transparent,
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 125.0,
                    child: FlatButton(
                      child: Text(
                        'Log In',
                        style: kAppBarTextStyle.copyWith(
                            fontSize: 16.0, color: Colors.white),
                      ),
                      color: Colors.transparent,
                      onPressed: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LogIn()),
                          ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.white),
                      ),
                      splashColor: kColorDarkRed,
                      highlightColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
