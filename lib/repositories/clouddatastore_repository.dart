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
