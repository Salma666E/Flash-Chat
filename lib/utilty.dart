import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String txt) {
  Widget okButton = FlatButton(
    child: const Text("OK",
        style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  AlertDialog alert = AlertDialog(
    title: const Text("Hint for you!!",
        style: TextStyle(color: Colors.blueAccent)),
    content: Text(txt),
    actions: [
      okButton,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

onBackPressed(BuildContext ctx, String text, hundler) {
  return showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
            title: Text(text),
            actions: [
              TextButton(
                  child: const Text("No",
                      style: TextStyle(
                          color: Colors.indigo, fontWeight: FontWeight.w700)),
                  onPressed: () => Navigator.pop(context, false)),
              TextButton(
                  child: const Text("Yes",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w700)),
                  onPressed: hundler)
            ],
          ));
}
