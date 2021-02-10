import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SwipeToRefreshExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SwipeToRefreshState();
  }
}

class _SwipeToRefreshState extends State<SwipeToRefreshExample> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  User user = User("Default Value", "Default Date");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Swipe To Refresh"),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              }),
        ],
      ),
      body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 24),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(user.date),
                  ],
                ),
              ),
            )
          ])),
    );
  }

  Future<User> getUser() async {
    final response = await http.get(
        "https://api.thingspeak.com/channels/1238514/feeds.json?api_key=MGC9OCN3W1D71VBD&results=2");
    final responseJson = json.decode(response.body);
    return User.fromJson(responseJson);
  }

  Future<Null> _refresh() {
    return getUser().then((_user) {
      setState(() => user = _user);
    });
  }
}

class User {
  final String name, date;

  User(this.name, this.date);

  factory User.fromJson(Map<String, dynamic> json) {
    json = json['feeds'][1];
    String name = json['field1'];
    String date = json['created_at'];
    print(name);
    return User(name, date);
  }
}
