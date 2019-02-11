import 'package:flutter/material.dart';
import 'dart:async';

import 'package:path/path.dart';

class Alert_Dialog {


  static Future<void> show(BuildContext context, Text main, Text sub) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: main,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                sub,

              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}

