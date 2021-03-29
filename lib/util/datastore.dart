import 'package:http/http.dart' as http;
import 'package:googleapis/datastore/v1.dart' as v1Api;

mixin PartitionMixin {
  late String _projectId;
  late String _namespace = '';

  v1Api.PartitionId _getPartitionId() => v1Api.PartitionId.fromJson({
        'projectId': _projectId,
        'namespace': _namespace,
      });
}

class Key with PartitionMixin {
  final String _namespace;
  final String _projectId;
  final String _kind;
  final int _id;

  String get kind => _kind;
  int get id => _id;

  Key(String projectId, String kind, int id, {String namespace = ''})
      : _projectId = projectId,
        _namespace = namespace,
        _kind = kind,
        _id = id;

  v1Api.Key toApiKey() {
    return v1Api.Key.fromJson({
      'partitionId': _getPartitionId().toJson(),
      'path': [
        {
          'kind': _kind,
          'id': _id.toString(),
        }
      ]
    });
  }
}

class PropertyValue<T> with PartitionMixin {
  String _projectId;
  String _namespace;
  String _kind;
  String _name;
  T? _value;
  int? _meaning;
  bool? _excludeFromIndexes;

  String get name => _name;
  T? get() => _value;

  PropertyValue(String projectId, String kind, String name, T? value,
      {int? meaning = null,
      bool? excludeFromIndexes = false,
      String namespace = ''})
      : _projectId = projectId,
        _kind = kind,
        _name = name,
        _value = value,
        _meaning = meaning,
        _excludeFromIndexes = excludeFromIndexes,
        _namespace = namespace;

  static PropertyValue fromApiProperty(
      String projectId, String kind, String name, v1Api.Value value,
      {String namespace = ''}) {
    if (value.booleanValue != null) {
      return PropertyValue<bool>(projectId, kind, name, value.booleanValue,
          meaning: value.meaning,
          excludeFromIndexes: value.excludeFromIndexes,
          namespace: namespace);
    }
    if (value.integerValue != null) {
      return PropertyValue<int>(
          projectId, kind, name, int.parse(value.integerValue as String),
          meaning: value.meaning,
          excludeFromIndexes: value.excludeFromIndexes,
          namespace: namespace);
    }
    if (value.doubleValue != null) {
      return PropertyValue<double>(projectId, kind, name, value.doubleValue,
          meaning: value.meaning,
          excludeFromIndexes: value.excludeFromIndexes,
          namespace: namespace);
    }
    if (value.timestampValue != null) {
      return PropertyValue<DateTime>(
          projectId, kind, name, DateTime.parse(value.timestampValue as String),
          meaning: value.meaning,
          excludeFromIndexes: value.excludeFromIndexes,
          namespace: namespace);
    }
    if (value.stringValue != null) {
      return PropertyValue<String>(projectId, kind, name, value.stringValue,
          meaning: value.meaning,
          excludeFromIndexes: value.excludeFromIndexes,
          namespace: namespace);
    }
    if (value.keyValue != null) {}
    return PropertyValue<Object>(projectId, kind, name, null,
        meaning: value.meaning,
        excludeFromIndexes: value.excludeFromIndexes,
        namespace: namespace);
  }

  v1Api.PropertyFilter intEquals(int value) {
    return v1Api.PropertyFilter.fromJson({
      'property': {
        'name': _name,
      },
      'op': 'EQUAL',
      'value': {
        'integerValue': value.toString(),
      }
    });
  }
}

class Entity with PartitionMixin {
  String _projectId;
  String _namespace;
  String _kind;
  Key? _key;
  Map<String, PropertyValue>? _propertyValuesMap;

  Key? get key => _key;
  PropertyValue? getProperty(String name) => _propertyValuesMap?[name];
  Iterable<MapEntry<String, PropertyValue>>? get propertyValuesMapEntries =>
      _propertyValuesMap?.entries;

  Entity(String projectId, String kind, Key? key,
      Map<String, PropertyValue>? propertiesMap,
      {String namespace = ''})
      : _projectId = projectId,
        _kind = kind,
        _key = key,
        _propertyValuesMap = propertiesMap,
        _namespace = namespace;

  static Entity? fromApiEntity(
      String projectId, String kind, v1Api.Entity? apiEntity,
      {String namespace = ''}) {
    if (apiEntity == null) {
      return null;
    }

    var apiKey = apiEntity.key as v1Api.Key;
    Key key = Key(projectId, kind, int.parse(apiKey.path?.last.id as String),
        namespace: namespace);
    var propertiesMap = apiEntity.properties?.map((_key, _value) => MapEntry(
        _key, PropertyValue.fromApiProperty(projectId, kind, _key, _value)));

    return (propertiesMap != null)
        ? Entity(projectId, kind, key, propertiesMap, namespace: namespace)
        : null;
  }
}

class Property {
  String _projectId;
  String _namespace;
  String _kind;
  String _name;
  Type? _type;
  bool? _excludeFromIndexes;

  String get name => _name;
  Type? get type => _type;
  bool? get indexable => !(_excludeFromIndexes ?? false);

  Property(String projectId, String kind, String name, Type? type,
      {String namespace = '', bool? excludeFromIndexes})
      : _projectId = projectId,
        _kind = kind,
        _name = name,
        _type = type,
        _namespace = namespace,
        _excludeFromIndexes = excludeFromIndexes;

  @override
  bool operator ==(Object other) =>
      other is Property &&
      _projectId == other._projectId &&
      _namespace == other._namespace &&
      _kind == other._kind &&
      _name == other._name;
}

class Entities {
  final List<Property> properties = [];
  final List<Entity> entities = [];

  Entities append(Entity? entity) {
    if (entity == null) return this;
    entities.add(entity);

    entity.propertyValuesMapEntries?.forEach((element) {
      var _propValue = element.value;
      var property = Property(
        _propValue._projectId,
        _propValue._kind,
        _propValue._name,
        _propValue._value.runtimeType,
        namespace: _propValue._namespace,
        excludeFromIndexes: _propValue._excludeFromIndexes,
      );
      if (!properties.contains(property)) {
        properties.add(property);
      }
    });
    return this;
  }
}

class DatastoreClient with PartitionMixin {
  final v1Api.DatastoreApi _datastoreApi;
  final String _projectId;

  v1Api.KindExpression _getKind(String kind) =>
      v1Api.KindExpression.fromJson({'name': kind});

  DatastoreClient(http.Client httpClient, String projectId,
      {String rootUrl = 'https://datastore.googleapis.com',
      String servicePath = ''})
      : _datastoreApi = v1Api.DatastoreApi(httpClient,
            rootUrl: rootUrl, servicePath: servicePath),
        _projectId = projectId;

  Future<List<String?>> getNamespaces() async {
    var request = v1Api.RunQueryRequest.fromJson({
      'query': {
        'kind': [_getKind('__namespace__').toJson()],
      }
    });
    v1Api.RunQueryResponse response =
        await _datastoreApi.projects.runQuery(request, _projectId);
    var entities = response.batch?.entityResults?.map((e) => e.entity);
    return (entities != null)
        ? entities.map((e) => e?.key?.path?[0].name).toList()
        : [];
  }

  Future<List<String?>> getKinds({String namespace = ''}) async {
    var request = v1Api.RunQueryRequest.fromJson({
      'partitionId': _getPartitionId().toJson(),
      'query': {
        'kind': [_getKind('__kind__').toJson()],
      }
    });
    v1Api.RunQueryResponse response =
        await _datastoreApi.projects.runQuery(request, _projectId);
    var entities = response.batch?.entityResults?.map((e) => e.entity);
    return (entities != null)
        ? entities.map((e) => e?.key?.path?[0].name).toList()
        : [];
  }

  Future<void> getKindIndexedProperties(String kind,
      {String namespace = ''}) async {
    // var property = Property()..name = '__key__';
    var request = v1Api.RunQueryRequest.fromJson({
      'partitionId': _getPartitionId().toJson(),
      'query': {
        'kind': [
          _getKind('__property__').toJson(),
        ],
        // 'filter': {
        //   'propertyFilter': property
        //       .hasAncestor(_projectId, '__kind__',
        //           pathName: kind, namespace: namespace)
        //       .toJson(),
        // }
      }
    });
    v1Api.RunQueryResponse response =
        await _datastoreApi.projects.runQuery(request, _projectId);
    var entities = response.batch?.entityResults?.map((e) => e.entity);
    if (entities != null) {
      for (var entity in entities) {
        print(entity?.toJson());
      }
    }
  }

  Future<Entities> runQuery(String kind, {String namespace = ''}) async {
    var request = v1Api.RunQueryRequest.fromJson({
      'partitionId': _getPartitionId().toJson(),
      'query': {
        'kind': [_getKind(kind).toJson()],
      }
    });
    v1Api.RunQueryResponse response =
        await _datastoreApi.projects.runQuery(request, _projectId);

    return response.batch?.entityResults?.fold<Entities>(
            Entities(),
            (previousValue, element) => previousValue.append(
                Entity.fromApiEntity(_projectId, kind, element.entity))) ??
        Entities();

    // return response.batch?.entityResults
    //         ?.map((e) => Entity.fromApiEntity(_projectId, kind, e.entity,
    //             namespace: _namespace))
    //         .toList() ??
    //     [];
  }

  Future<Entity?> getEntity(Key key) async {
    var request = v1Api.LookupRequest.fromJson({
      'keys': [
        key.toApiKey().toJson(),
      ]
    });
    v1Api.LookupResponse response =
        await _datastoreApi.projects.lookup(request, _projectId);
    var propertyValuesMap = response.found?.first.entity?.properties?.map(
        (_key, _value) => MapEntry(
            _key,
            PropertyValue.fromApiProperty(
                key._projectId, key._kind, _key, _value)));

    return (propertyValuesMap != null)
        ? Entity(key._projectId, key._kind, key, propertyValuesMap,
            namespace: key._namespace)
        : null;
  }
}
