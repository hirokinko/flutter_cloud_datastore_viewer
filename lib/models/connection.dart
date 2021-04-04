import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_cloud_datastore_viewer/patched_datastore/v1.dart'
    as v1Api;
import 'package:ordered_set/ordered_set.dart';

enum SortDirection {
  ASCENDING,
  DESCENDING,
}

class ColumnModel implements Comparable {
  late String name;
  late bool sortable;

  @override
  int compareTo(other) => this.name.compareTo(other.name);
}

class EntitiesDatatableModel {
  late OrderedSet<ColumnModel> columns;
  late List<v1Api.Entity?> entities;

  bool containsKey(String key) => this.columns.any((c) => c.name == key);
}

class ConnectionModel {
  String? keyFilePath = '';
  String? rootUrl = 'http://0.0.0.0:8081/';
  String? projectId = 'test-project';
  String namespaceId = 'development';
  String? currentSelectedKind = 'User';
  late String? sortKey;
  late SortDirection? sortDirection;

  ConnectionModel()
      : sortKey = null,
        sortDirection = null;

  v1Api.DatastoreApi? _getDatastoreApi() {
    if (this.projectId == null &&
        (this.keyFilePath == null || this.rootUrl == null)) {
      return null;
    }
    final client = auth.clientViaApiKey(this.keyFilePath ?? '');
    return v1Api.DatastoreApi(client,
        rootUrl: rootUrl ?? 'https://datastore.googleapis.com/');
  }

  Future<EntitiesDatatableModel?> runQuery() async {
    final _datastoreApi = this._getDatastoreApi();
    if (_datastoreApi == null) return null;

    final partitionId = v1Api.PartitionId()
      ..namespaceId = this.namespaceId
      ..projectId = this.projectId;
    final query = v1Api.Query()
      ..kind = [v1Api.KindExpression()..name = this.currentSelectedKind];

    if (this.sortKey != null) {
      query
        ..order = [
          v1Api.PropertyOrder()
            ..property = (v1Api.PropertyReference()..name = sortKey)
            ..direction = (sortDirection == null ||
                    sortDirection == SortDirection.ASCENDING)
                ? 'ASCENDING'
                : 'DESCENDING',
        ];
    }

    final request = v1Api.RunQueryRequest()
      ..partitionId = partitionId
      ..query = query;
    final response = await _datastoreApi.projects
        .runQuery(request, this.projectId as String);

    final EntitiesDatatableModel? model = response.batch?.entityResults?.fold(
        EntitiesDatatableModel()
          ..columns = OrderedSet<ColumnModel>()
          ..entities = <v1Api.Entity>[], (previousValue, element) {
      final entity = element.entity;
      if (entity == null || entity.properties == null) return previousValue;

      for (final propertyEntry in entity.properties!.entries) {
        final key = propertyEntry.key;
        final value = propertyEntry.value;
        if (!previousValue!.containsKey(key)) {
          previousValue.columns.add(ColumnModel()
            ..name = key
            ..sortable = (value.excludeFromIndexes == null)
                ? true
                : !(value.excludeFromIndexes!));
        }
      }
      previousValue!.entities.add(entity);
      return previousValue;
    });
    return model;
  }
}
