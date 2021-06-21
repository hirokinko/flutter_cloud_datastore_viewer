import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_cloud_datastore_viewer/patched_datastore/v1.dart'
    as v1Api;
import 'package:ordered_set/ordered_set.dart';

@deprecated
enum SortDirection {
  ASCENDING,
  DESCENDING,
}

@deprecated
class ColumnModel implements Comparable {
  late String name;
  late bool sortable;
  late Type type;

  @override
  int compareTo(other) => this.name.compareTo(other.name);
}

@deprecated
class EntitiesDatatableModel {
  late OrderedSet<ColumnModel> columns;
  late List<v1Api.Entity?> entities;

  bool containsKey(String key) => this.columns.any((c) => c.name == key);
}

@deprecated
class ConnectionModel {
  String? keyFilePath = '';
  String? rootUrl = 'http://0.0.0.0:8081/';
  String? projectId = 'test-project';
  String namespaceId = 'development';
  String? currentSelectedKind = 'User';
  late String? sortKey;
  late SortDirection? sortDirection;
  late v1Api.PropertyFilter? propertyFilter;

  ConnectionModel()
      : sortKey = null,
        sortDirection = null,
        propertyFilter = null;

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

    if (this.propertyFilter != null) {
      query.filter = v1Api.Filter()..propertyFilter = this.propertyFilter;
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
      if (entity == null) return previousValue;

      if (!previousValue!.containsKey('__key__')) {
        previousValue.columns.add(ColumnModel()
          ..name = '__key__'
          ..sortable = true
          ..type = v1Api.Key);
      }
      for (final propertyEntry in entity.properties == null
          ? <MapEntry<String, v1Api.Value>>[]
          : entity.properties!.entries) {
        final key = propertyEntry.key;
        final value = propertyEntry.value;
        final type = this._getValueType(value);
        if (!previousValue.containsKey(key)) {
          previousValue.columns.add(ColumnModel()
            ..name = key
            ..sortable = (value.excludeFromIndexes == null)
                ? true
                : !(value.excludeFromIndexes!)
            ..type = type);
        }
      }
      previousValue.entities.add(entity);
      return previousValue;
    });
    return model;
  }

  Type _getValueType(v1Api.Value value) {
    if (value.arrayValue != null) {
      // TODO: get inner type
      return v1Api.ArrayValue;
    }
    // if (value.blobValue != null) {
    //   return String;
    // }
    if (value.booleanValue != null) {
      return bool;
    }
    if (value.doubleValue != null) {
      return double;
    }
    if (value.entityValue != null) {
      // TODO: get inner type
      return v1Api.Entity;
    }
    if (value.geoPointValue != null) {
      // TODO: get inner type
      return v1Api.LatLng;
    }
    if (value.integerValue != null) {
      return int;
    }
    if (value.keyValue != null) {
      return v1Api.Key;
    }
    if (value.stringValue != null) {
      return String;
    }
    if (value.timestampValue != null) {
      return DateTime;
    }
    return Null;
  }
}
