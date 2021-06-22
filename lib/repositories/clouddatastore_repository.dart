import '../patched_datastore/v1.dart' as datastore_api;
import '../models/connection.dart' as connections;
import '../models/entities.dart' as models;

class CloudDatastoreUtils {
  static datastore_api.Value toValue(Type type, String? value) {
    if (value == null) {
      return datastore_api.Value()..nullValue = "NULL_VALUE";
    }
    switch (type) {
      case bool:
        return datastore_api.Value()
          ..booleanValue = value.toLowerCase() == 'true';
      case int:
        return datastore_api.Value()..integerValue = value;
      case double:
        return datastore_api.Value()..doubleValue = double.parse(value);
      case String:
        return datastore_api.Value()..stringValue = value;
      default:
        throw UnimplementedError();
    }
  }

  static datastore_api.PropertyFilter toPropertyFilter(
    String name,
    String op,
    Type type,
    String? value,
  ) {
    return datastore_api.PropertyFilter()
      ..property = (datastore_api.PropertyReference()..name = name)
      ..op = op
      ..value = CloudDatastoreUtils.toValue(type, value);
  }

  static datastore_api.CompositeFilter toRangeFilter(
    String name,
    Type type,
    String maxValue,
    String minValue, {
    bool containsMaxValue: false,
    bool containsMinValue: false,
  }) {
    return datastore_api.CompositeFilter()
      ..op = "AND"
      ..filters = [
        datastore_api.Filter()
          ..propertyFilter = CloudDatastoreUtils.toPropertyFilter(
            name,
            "LESS_THAN" + (containsMaxValue ? "_OR_EQUAL" : ""),
            type,
            maxValue,
          ),
        datastore_api.Filter()
          ..propertyFilter = CloudDatastoreUtils.toPropertyFilter(
            name,
            "GREATER_THAN" + (containsMinValue ? "_OR_EQUAL" : ""),
            type,
            minValue,
          ),
      ];
  }
}

class CloudDatastoreRepostiry {
  datastore_api.DatastoreApi client;
  String projectId;

  CloudDatastoreRepostiry(this.client, this.projectId);

  Future<List<String?>> namespaces() async {
    final response = await this._runQuery(
      '__namespace__',
      null,
      null,
      limit: 0,
    );
    return response.batch?.entityResults?.map((
          datastore_api.EntityResult entityResult,
        ) {
          return entityResult.entity?.key?.path?[0].name;
        }).toList(growable: false) ??
        [];
  }

  Future<List<String>> kinds(String? namespace) async {
    final response = await this._runQuery(
      '__kind__',
      namespace,
      null,
      limit: 0,
    );
    return response.batch?.entityResults?.map((
          datastore_api.EntityResult entityResult,
        ) {
          return entityResult.entity?.key?.path?[0].name ?? '';
        }).toList(growable: false) ??
        [];
  }

  Future<connections.CloudDatastoreMetadata> getMetadata(
    String? namespace,
  ) async {
    List<String?> namespaces = await this.namespaces();
    List<String> kinds = await this.kinds(namespace);
    return connections.CloudDatastoreMetadata(namespaces, kinds);
  }

  Future<models.EntityList> find(
    String kindName,
    String? namespace,
    String? startCursor,
    String? previousPageStartCursor, {
    int limit = 50,
  }) async {
    // TODO filter
    // TODO ordering
    final response = await this._runQuery(
      kindName,
      namespace,
      startCursor,
      limit: limit,
    );

    final entities = response.batch?.entityResults
            ?.map((datastore_api.EntityResult entityResult) =>
                this._toModelEntity(entityResult.entity))
            .toList(growable: false) ??
        [];

    final endCursor = this._getEndCursor(response.batch);

    return models.EntityList(
      entities,
      limit,
      startCursor,
      endCursor,
      previousPageStartCursor,
    );
  }

  Future<datastore_api.RunQueryResponse> _runQuery(
    String kindName,
    String? namespace,
    String? startCursor, {
    int limit = 50,
  }) async {
    final partitionId = datastore_api.PartitionId()
      ..projectId = this.projectId
      ..namespaceId = namespace;
    final kind = datastore_api.KindExpression()..name = kindName;
    final query = datastore_api.Query()..kind = [kind];
    if (limit > 0) {
      query..limit = limit;
    }
    if (startCursor != null) {
      query..startCursor = startCursor;
    }
    final request = datastore_api.RunQueryRequest()
      ..partitionId = partitionId
      ..query = query;
    return await client.projects.runQuery(request, this.projectId);
  }

  models.Key? _toModelKey(datastore_api.Key? datastoreKey) {
    final partitionId = datastoreKey?.partitionId;
    final path = datastoreKey?.path;

    if ((partitionId == null || partitionId.projectId == null) &&
        (path == null || path.isEmpty)) {
      return null;
    }

    final modelKeys = path!
        .map(
          (datastore_api.PathElement e) => models.Key(
            partitionId!.projectId!,
            partitionId.namespaceId,
            e.kind ?? '',
            int.tryParse(e.id ?? ''),
            e.name,
            [],
          ),
        )
        .toList(growable: false);

    return models.Key(
      modelKeys[0].projectId,
      modelKeys[0].namespaceId,
      modelKeys[0].kind,
      modelKeys[0].id,
      modelKeys[0].name,
      modelKeys.length > 1 ? modelKeys.sublist(1) : [],
    );
  }

  // FIXME それぞれの型で返したい
  Object? _toValue(datastore_api.Value datastoreValue) {
    if (datastoreValue.booleanValue != null) {
      return datastoreValue.booleanValue;
    }
    if (datastoreValue.integerValue != null) {
      return int.tryParse(datastoreValue.integerValue!);
    }
    if (datastoreValue.doubleValue != null) {
      return datastoreValue.doubleValue;
    }
    // TODO timestampValue
    if (datastoreValue.keyValue != null) {
      return this._toModelKey(datastoreValue.keyValue);
    }
    if (datastoreValue.stringValue != null) {
      return datastoreValue.stringValue;
    }
    // TODO blobValue
    // TODO geoPointValue
    if (datastoreValue.entityValue != null) {
      return this._toModelEntity(datastoreValue.entityValue);
    }
    if (datastoreValue.arrayValue != null &&
        datastoreValue.arrayValue!.values != null) {
      final values = datastoreValue.arrayValue!.values!
          .map((v) => this._toValue(v))
          .toList(growable: false);
      return values;
    }
    return null;
  }

  // FIXME それぞれのプロパティのGenericsがdynamicになるのをなんとかしたい
  models.Entity? _toModelEntity(datastore_api.Entity? datastoreEntity) {
    final modelKey = this._toModelKey(datastoreEntity?.key);
    final properties = datastoreEntity?.properties?.entries
            .map<models.Property>(
          (
            MapEntry<String, datastore_api.Value> entry,
          ) {
            final indexed = !(entry.value.excludeFromIndexes ?? false);
            final value = this._toValue(entry.value);
            if (value == null) {
              return models.SingleProperty(entry.key, String, indexed, null);
            }
            // FIXME もっとスマートにListと認識する方法を知りたい
            if (value.runtimeType.toString() == 'List<Object?>' &&
                (value as List).isNotEmpty) {
              final type = value[0].runtimeType;
              return models.ListProperty(entry.key, type, indexed, value);
            }
            return models.SingleProperty(
              entry.key,
              value.runtimeType,
              indexed,
              value,
            );
          },
        ).toList(growable: false) ??
        [];

    return properties.isNotEmpty ? models.Entity(modelKey, properties) : null;
  }

  String? _getEndCursor(datastore_api.QueryResultBatch? batch) {
    return ((batch?.moreResults == 'MORE_RESULTS_AFTER_LIMIT' ||
                batch?.moreResults == 'MORE_RESULTS_AFTER_CURSOR') &&
            batch?.endCursor != null)
        ? batch?.endCursor
        : null;
  }
}
