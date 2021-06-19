import '../patched_datastore/v1.dart' as datastore_api;

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
    final response = await this._runQuery('__namespace__', null);
    return response.batch?.entityResults?.map((
          datastore_api.EntityResult entityResult,
        ) {
          return entityResult.entity?.key?.path?[0].name;
        }).toList(growable: false) ??
        [];
  }

  Future<List<String>> kinds(String? namespace) async {
    final response = await this._runQuery('__kind__', namespace);
    return response.batch?.entityResults?.map((
          datastore_api.EntityResult entityResult,
        ) {
          return entityResult.entity?.key?.path?[0].name ?? '';
        }).toList(growable: false) ??
        [];
  }

  Future<void> find(String kindName, String? namespace) async {
    // TODO filter
    // TODO ordering
    final response = await this._runQuery(kindName, namespace);
    response.batch?.entityResults
        ?.forEach((datastore_api.EntityResult entityResult) {
      final entity = entityResult.entity;
      final key = entity?.key;
      final keyPartitionId = key?.partitionId;
      final keyPath = key?.path;
      print(
        'namespace: ${keyPartitionId?.namespaceId}, projectId: ${keyPartitionId?.projectId}',
      );
      keyPath?.forEach((datastore_api.PathElement pathElement) {
        print(
          'kind: ${pathElement.kind}, id: ${pathElement.id}, name: ${pathElement.name}',
        );
      });
      entity?.properties?.forEach((
        String propertyKey,
        datastore_api.Value propertyValue,
      ) {
        print(
          'property key: $propertyKey, value: ${propertyValue.toJson().toString()}',
        );
      });
    });
  }

  Future<datastore_api.RunQueryResponse> _runQuery(
    String kindName,
    String? namespace,
  ) async {
    final partitionId = datastore_api.PartitionId()
      ..projectId = this.projectId
      ..namespaceId = namespace;
    final kind = datastore_api.KindExpression()..name = kindName;
    final query = datastore_api.Query()..kind = [kind];
    final request = datastore_api.RunQueryRequest()
      ..partitionId = partitionId
      ..query = query;
    return await client.projects.runQuery(request, this.projectId);
  }
}
