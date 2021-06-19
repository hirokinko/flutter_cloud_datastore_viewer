import 'package:meta/meta.dart';
import 'package:flutter_cloud_datastore_viewer/patched_datastore/v1.dart';

@immutable
class ToValueTestFixture<T> {
  final Type type;
  final String? value;
  final T? expectedValue;

  ToValueTestFixture(this.type, this.value, this.expectedValue);
}

@immutable
class ToPropertyFilterFixture {
  final String name;
  final String op;
  final Type type;
  final String? value;
  final Map<String, dynamic> expectedPropertyFilter;

  ToPropertyFilterFixture(
    this.name,
    this.op,
    this.type,
    this.value,
    this.expectedPropertyFilter,
  );
}

@immutable
class ToRangeFilterFixture {
  final String name;
  final Type type;
  final String maxValue;
  final String minValue;
  final bool containsMax;
  final bool containsMin;
  final Map<String, dynamic> expectedPropertyFilter;

  ToRangeFilterFixture(
    this.name,
    this.type,
    this.maxValue,
    this.minValue,
    this.containsMax,
    this.containsMin,
    this.expectedPropertyFilter,
  );
}

final toValueTestFixtures = [
  ToValueTestFixture(bool, null, {"nullValue": "NULL_VALUE"}),
  ToValueTestFixture(int, null, {"nullValue": "NULL_VALUE"}),
  ToValueTestFixture(double, null, {"nullValue": "NULL_VALUE"}),
  ToValueTestFixture(String, null, {"nullValue": "NULL_VALUE"}),
  ToValueTestFixture(bool, 'True', {"booleanValue": true}),
  ToValueTestFixture(bool, 'False', {"booleanValue": false}),
  ToValueTestFixture(bool, 'Hoge', {"booleanValue": false}),
  ToValueTestFixture(int, "1", {"integerValue": "1"}),
  ToValueTestFixture(int, "-1", {"integerValue": "-1"}),
  ToValueTestFixture(double, "1.0", {"doubleValue": 1.0}),
  ToValueTestFixture(double, "-1.0", {"doubleValue": -1.0}),
  ToValueTestFixture(double, "1.0E03", {"doubleValue": 1.0E03}),
  ToValueTestFixture(double, "1.0E-03", {"doubleValue": 1.0E-03}),
  ToValueTestFixture(String, "Hoge", {"stringValue": "Hoge"}),
  ToValueTestFixture(String, "", {"stringValue": ""}),
];

final toPropertyFilterFixtures = [
  ToPropertyFilterFixture(
    "boolProperty",
    "EQUAL",
    bool,
    "True",
    {
      "property": {
        "name": "boolProperty",
      },
      "op": "EQUAL",
      "value": {
        "booleanValue": true,
      },
    },
  ),
  ToPropertyFilterFixture(
    "boolProperty",
    "EQUAL",
    bool,
    "False",
    {
      "property": {
        "name": "boolProperty",
      },
      "op": "EQUAL",
      "value": {
        "booleanValue": false,
      },
    },
  ),
  ToPropertyFilterFixture(
    "integerProperty",
    "EQUAL",
    int,
    "1",
    {
      "property": {
        "name": "integerProperty",
      },
      "op": "EQUAL",
      "value": {
        "integerValue": "1",
      },
    },
  ),
  ToPropertyFilterFixture(
    "integerProperty",
    "EQUAL",
    int,
    "-1",
    {
      "property": {
        "name": "integerProperty",
      },
      "op": "EQUAL",
      "value": {
        "integerValue": "-1",
      },
    },
  ),
  ToPropertyFilterFixture(
    "doubleProperty",
    "EQUAL",
    double,
    "1.0",
    {
      "property": {
        "name": "doubleProperty",
      },
      "op": "EQUAL",
      "value": {
        "doubleValue": 1.0,
      },
    },
  ),
  ToPropertyFilterFixture(
    "doubleProperty",
    "EQUAL",
    double,
    "-1.0",
    {
      "property": {
        "name": "doubleProperty",
      },
      "op": "EQUAL",
      "value": {
        "doubleValue": -1.0,
      },
    },
  ),
  ToPropertyFilterFixture(
    "doubleProperty",
    "EQUAL",
    double,
    "1.0E03",
    {
      "property": {
        "name": "doubleProperty",
      },
      "op": "EQUAL",
      "value": {
        "doubleValue": 1.0E03,
      },
    },
  ),
  ToPropertyFilterFixture(
    "doubleProperty",
    "EQUAL",
    double,
    "1.0E-03",
    {
      "property": {
        "name": "doubleProperty",
      },
      "op": "EQUAL",
      "value": {
        "doubleValue": 1.0E-03,
      },
    },
  ),
  ToPropertyFilterFixture(
    "stringProperty",
    "EQUAL",
    String,
    "",
    {
      "property": {
        "name": "stringProperty",
      },
      "op": "EQUAL",
      "value": {
        "stringValue": "",
      },
    },
  ),
  ToPropertyFilterFixture(
    "stringProperty",
    "EQUAL",
    String,
    "Spam",
    {
      "property": {
        "name": "stringProperty",
      },
      "op": "EQUAL",
      "value": {
        "stringValue": "Spam",
      },
    },
  ),
];

final toRangeFilterFixtures = [
  ToRangeFilterFixture(
    "integerProperty",
    int,
    "1",
    "0",
    false,
    false,
    {
      "op": "AND",
      "filters": [
        {
          "propertyFilter": {
            "property": {
              "name": "integerProperty",
            },
            "op": "LESS_THAN",
            "value": {"integerValue": "1"}
          }
        },
        {
          "propertyFilter": {
            "property": {
              "name": "integerProperty",
            },
            "op": "GREATER_THAN",
            "value": {"integerValue": "0"}
          }
        },
      ],
    },
  ),
  ToRangeFilterFixture(
    "integerProperty",
    int,
    "1",
    "0",
    true,
    true,
    {
      "op": "AND",
      "filters": [
        {
          "propertyFilter": {
            "property": {
              "name": "integerProperty",
            },
            "op": "LESS_THAN_OR_EQUAL",
            "value": {"integerValue": "1"}
          }
        },
        {
          "propertyFilter": {
            "property": {
              "name": "integerProperty",
            },
            "op": "GREATER_THAN_OR_EQUAL",
            "value": {"integerValue": "0"}
          }
        },
      ],
    },
  ),
  ToRangeFilterFixture(
    "doubleProperty",
    double,
    "1.0",
    "0.0",
    false,
    false,
    {
      "op": "AND",
      "filters": [
        {
          "propertyFilter": {
            "property": {
              "name": "doubleProperty",
            },
            "op": "LESS_THAN",
            "value": {"doubleValue": 1.0}
          }
        },
        {
          "propertyFilter": {
            "property": {
              "name": "doubleProperty",
            },
            "op": "GREATER_THAN",
            "value": {"doubleValue": 0.0}
          }
        },
      ],
    },
  ),
  ToRangeFilterFixture(
    "doubleProperty",
    double,
    "1.0",
    "0.0",
    true,
    true,
    {
      "op": "AND",
      "filters": [
        {
          "propertyFilter": {
            "property": {
              "name": "doubleProperty",
            },
            "op": "LESS_THAN_OR_EQUAL",
            "value": {"doubleValue": 1.0}
          }
        },
        {
          "propertyFilter": {
            "property": {
              "name": "doubleProperty",
            },
            "op": "GREATER_THAN_OR_EQUAL",
            "value": {"doubleValue": 0.0}
          }
        },
      ],
    },
  ),
  ToRangeFilterFixture(
    "stringProperty",
    String,
    "ん",
    "あ",
    false,
    false,
    {
      "op": "AND",
      "filters": [
        {
          "propertyFilter": {
            "property": {
              "name": "stringProperty",
            },
            "op": "LESS_THAN",
            "value": {"stringValue": "ん"}
          }
        },
        {
          "propertyFilter": {
            "property": {
              "name": "stringProperty",
            },
            "op": "GREATER_THAN",
            "value": {"stringValue": "あ"}
          }
        },
      ],
    },
  ),
  ToRangeFilterFixture(
    "stringProperty",
    String,
    "ん",
    "あ",
    true,
    true,
    {
      "op": "AND",
      "filters": [
        {
          "propertyFilter": {
            "property": {
              "name": "stringProperty",
            },
            "op": "LESS_THAN_OR_EQUAL",
            "value": {"stringValue": "ん"}
          }
        },
        {
          "propertyFilter": {
            "property": {
              "name": "stringProperty",
            },
            "op": "GREATER_THAN_OR_EQUAL",
            "value": {"stringValue": "あ"}
          }
        },
      ],
    },
  ),
];

final namespacesRunQueryResponse = RunQueryResponse()
  ..batch = (QueryResultBatch()
    ..entityResults = [
      EntityResult()
        ..entity = (Entity()
          ..key = (Key()
            ..partitionId = (PartitionId()
              ..projectId = 'test-project'
              ..namespaceId = null)
            ..path = [
              PathElement()
                ..kind = '__namespace__'
                ..id = '1'
                ..name = null,
            ])),
      EntityResult()
        ..entity = (Entity()
          ..key = (Key()
            ..partitionId = (PartitionId()
              ..projectId = 'test-project'
              ..namespaceId = null)
            ..path = [
              PathElement()
                ..kind = '__namespace__'
                ..id = null
                ..name = 'development',
            ])),
    ]);

final expectedNamespacesRunQueryRequest = RunQueryRequest()
  ..query = (Query()..kind = [KindExpression()..name = '__namespace__'])
  ..partitionId = (PartitionId()..projectId = 'test-project');

final kindRunQueryResponse = RunQueryResponse()
  ..batch = (QueryResultBatch()
    ..entityResults = [
      EntityResult()
        ..entity = (Entity()
          ..key = (Key()
            ..partitionId = (PartitionId()
              ..projectId = 'test-project'
              ..namespaceId = null)
            ..path = [
              PathElement()
                ..kind = '__kind__'
                ..name = 'Spam'
                ..id = null,
            ])),
      EntityResult()
        ..entity = (Entity()
          ..key = (Key()
            ..partitionId = (PartitionId()
              ..projectId = 'test-project'
              ..namespaceId = null)
            ..path = [
              PathElement()
                ..kind = '__kind__'
                ..name = 'Ham'
                ..id = null,
            ])),
      EntityResult()
        ..entity = (Entity()
          ..key = (Key()
            ..partitionId = (PartitionId()
              ..projectId = 'test-project'
              ..namespaceId = null)
            ..path = [
              PathElement()
                ..kind = '__kind__'
                ..name = 'Egg'
                ..id = null,
            ])),
    ]);
