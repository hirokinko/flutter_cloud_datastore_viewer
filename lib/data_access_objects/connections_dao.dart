import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/connection.dart';

const _CONNECTIONS_KEY = 'connections';
const _CURRENT_SHOWING_KEY = 'currentShowing';

class ConnectionDao {
  Future<List<CloudDatastoreConnection>> getCloudDatastoreConnections() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final connectionsJson =
        prefs.getStringList(_CONNECTIONS_KEY)?.map((p) => jsonDecode(p)) ?? [];
    return connectionsJson
        .map((j) => CloudDatastoreConnection.fromJson(j))
        .toList(growable: false);
  }

  Future<void> putCloudDatastoreConnectionsToPref(
    List<CloudDatastoreConnection> connections,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final connectionsJson =
        connections.map((c) => c.toJson()).toList(growable: false);
    prefs.setStringList(_CONNECTIONS_KEY, connectionsJson);
  }

  Future<CurrentShowing> getCurrentShowing() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final currentShowingJson = jsonDecode(
        prefs.getString(_CURRENT_SHOWING_KEY) ??
            '{"namespace": null, "kind": null}');
    return CurrentShowing.fromJson(currentShowingJson);
  }

  Future<void> putCurrentShowing(CurrentShowing currentShowing) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_CURRENT_SHOWING_KEY, currentShowing.toString());
  }
}
