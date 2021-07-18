import 'package:flutter_cloud_datastore_viewer/models/entities.dart' as models;
import 'package:flutter_cloud_datastore_viewer/models/filters.dart' as filters;
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
  final filters.Property property;
  final String op;
  final String? value;
  final Map<String, dynamic> expectedPropertyFilter;

  ToPropertyFilterFixture(
    this.property,
    this.op,
    this.value,
    this.expectedPropertyFilter,
  );
}

@immutable
class ToRangeFilterFixture {
  final filters.Property property;
  final String maxValue;
  final String minValue;
  final bool containsMax;
  final bool containsMin;
  final Map<String, dynamic> expectedPropertyFilter;

  ToRangeFilterFixture(
    this.property,
    this.maxValue,
    this.minValue,
    this.containsMax,
    this.containsMin,
    this.expectedPropertyFilter,
  );
}

@immutable
class ToPropertyOrderFixture {
  final models.SortOrder? order;
  final String? filteredProperty;
  final List<Map<String, dynamic>>? expectedPropertyOrder;

  ToPropertyOrderFixture(
    this.order,
    this.filteredProperty,
    this.expectedPropertyOrder,
  );
}

@immutable
class CreateFilterFixture {
  final filters.Filter filter;
  final Map<String, dynamic>? expectedDatastoreApiFilter;

  CreateFilterFixture(this.filter, this.expectedDatastoreApiFilter);
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
    filters.Property('boolProperty', bool),
    "EQUAL",
    "True",
    {
      "propertyFilter": {
        "property": {
          "name": "boolProperty",
        },
        "op": "EQUAL",
        "value": {
          "booleanValue": true,
        },
      },
    },
  ),
  ToPropertyFilterFixture(
    filters.Property('boolProperty', bool),
    "EQUAL",
    "False",
    {
      "propertyFilter": {
        "property": {
          "name": "boolProperty",
        },
        "op": "EQUAL",
        "value": {
          "booleanValue": false,
        },
      },
    },
  ),
  ToPropertyFilterFixture(
    filters.Property('integerProperty', int),
    "EQUAL",
    "1",
    {
      "propertyFilter": {
        "property": {
          "name": "integerProperty",
        },
        "op": "EQUAL",
        "value": {
          "integerValue": "1",
        },
      },
    },
  ),
  ToPropertyFilterFixture(
    filters.Property('integerProperty', int),
    "EQUAL",
    "-1",
    {
      "propertyFilter": {
        "property": {
          "name": "integerProperty",
        },
        "op": "EQUAL",
        "value": {
          "integerValue": "-1",
        },
      },
    },
  ),
  ToPropertyFilterFixture(
    filters.Property('doubleProperty', double),
    "EQUAL",
    "1.0",
    {
      "propertyFilter": {
        "property": {
          "name": "doubleProperty",
        },
        "op": "EQUAL",
        "value": {
          "doubleValue": 1.0,
        },
      },
    },
  ),
  ToPropertyFilterFixture(
    filters.Property('doubleProperty', double),
    "EQUAL",
    "-1.0",
    {
      "propertyFilter": {
        "property": {
          "name": "doubleProperty",
        },
        "op": "EQUAL",
        "value": {
          "doubleValue": -1.0,
        },
      },
    },
  ),
  ToPropertyFilterFixture(
    filters.Property('doubleProperty', double),
    "EQUAL",
    "1.0E03",
    {
      "propertyFilter": {
        "property": {
          "name": "doubleProperty",
        },
        "op": "EQUAL",
        "value": {
          "doubleValue": 1.0E03,
        },
      },
    },
  ),
  ToPropertyFilterFixture(
    filters.Property('doubleProperty', double),
    "EQUAL",
    "1.0E-03",
    {
      "propertyFilter": {
        "property": {
          "name": "doubleProperty",
        },
        "op": "EQUAL",
        "value": {
          "doubleValue": 1.0E-03,
        },
      }
    },
  ),
  ToPropertyFilterFixture(
    filters.Property('stringProperty', String),
    "EQUAL",
    "",
    {
      "propertyFilter": {
        "property": {
          "name": "stringProperty",
        },
        "op": "EQUAL",
        "value": {
          "stringValue": "",
        },
      }
    },
  ),
  ToPropertyFilterFixture(
    filters.Property('stringProperty', String),
    "EQUAL",
    "Spam",
    {
      "propertyFilter": {
        "property": {
          "name": "stringProperty",
        },
        "op": "EQUAL",
        "value": {
          "stringValue": "Spam",
        },
      },
    },
  ),
  ToPropertyFilterFixture(
    filters.Property('timestampProperty', DateTime),
    "EQUAL",
    "2014-10-02T15:01:23.045123456Z",
    {
      "propertyFilter": {
        "property": {
          "name": "timestampProperty",
        },
        "op": "EQUAL",
        "value": {
          "timestampValue": "2014-10-02T15:01:23.045123456Z",
        },
      }
    },
  ),
];

final toRangeFilterFixtures = [
  ToRangeFilterFixture(
    filters.Property("integerProperty", int),
    "1",
    "0",
    false,
    false,
    {
      "compositeFilter": {
        "op": "AND",
        "filters": [
          {
            "propertyFilter": {
              "property": {
                "name": "integerProperty",
              },
              "op": "GREATER_THAN",
              "value": {"integerValue": "0"}
            }
          },
          {
            "propertyFilter": {
              "property": {
                "name": "integerProperty",
              },
              "op": "LESS_THAN",
              "value": {"integerValue": "1"}
            }
          },
        ],
      },
    },
  ),
  ToRangeFilterFixture(
    filters.Property("integerProperty", int),
    "1",
    "0",
    true,
    true,
    {
      "compositeFilter": {
        "op": "AND",
        "filters": [
          {
            "propertyFilter": {
              "property": {
                "name": "integerProperty",
              },
              "op": "GREATER_THAN_OR_EQUAL",
              "value": {"integerValue": "0"}
            }
          },
          {
            "propertyFilter": {
              "property": {
                "name": "integerProperty",
              },
              "op": "LESS_THAN_OR_EQUAL",
              "value": {"integerValue": "1"}
            }
          },
        ],
      },
    },
  ),
  ToRangeFilterFixture(
    filters.Property("doubleProperty", double),
    "1.0",
    "0.0",
    false,
    false,
    {
      "compositeFilter": {
        "op": "AND",
        "filters": [
          {
            "propertyFilter": {
              "property": {
                "name": "doubleProperty",
              },
              "op": "GREATER_THAN",
              "value": {"doubleValue": 0.0}
            }
          },
          {
            "propertyFilter": {
              "property": {
                "name": "doubleProperty",
              },
              "op": "LESS_THAN",
              "value": {"doubleValue": 1.0}
            }
          },
        ],
      },
    },
  ),
  ToRangeFilterFixture(
    filters.Property("doubleProperty", double),
    "1.0",
    "0.0",
    true,
    true,
    {
      "compositeFilter": {
        "op": "AND",
        "filters": [
          {
            "propertyFilter": {
              "property": {
                "name": "doubleProperty",
              },
              "op": "GREATER_THAN_OR_EQUAL",
              "value": {"doubleValue": 0.0}
            }
          },
          {
            "propertyFilter": {
              "property": {
                "name": "doubleProperty",
              },
              "op": "LESS_THAN_OR_EQUAL",
              "value": {"doubleValue": 1.0}
            }
          },
        ],
      },
    },
  ),
  ToRangeFilterFixture(
    filters.Property("stringProperty", String),
    "ん",
    "あ",
    false,
    false,
    {
      "compositeFilter": {
        "op": "AND",
        "filters": [
          {
            "propertyFilter": {
              "property": {
                "name": "stringProperty",
              },
              "op": "GREATER_THAN",
              "value": {"stringValue": "あ"}
            }
          },
          {
            "propertyFilter": {
              "property": {
                "name": "stringProperty",
              },
              "op": "LESS_THAN",
              "value": {"stringValue": "ん"}
            }
          },
        ],
      },
    },
  ),
  ToRangeFilterFixture(
    filters.Property("stringProperty", String),
    "ん",
    "あ",
    true,
    true,
    {
      "compositeFilter": {
        "op": "AND",
        "filters": [
          {
            "propertyFilter": {
              "property": {
                "name": "stringProperty",
              },
              "op": "GREATER_THAN_OR_EQUAL",
              "value": {"stringValue": "あ"}
            }
          },
          {
            "propertyFilter": {
              "property": {
                "name": "stringProperty",
              },
              "op": "LESS_THAN_OR_EQUAL",
              "value": {"stringValue": "ん"}
            }
          },
        ],
      },
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

final findRunQueryResponse = RunQueryResponse()
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
                ..kind = 'MontyPython'
                ..name = 'Spam'
                ..id = null,
              PathElement()
                ..kind = 'MontyPython'
                ..name = 'Ham'
                ..id = null,
              PathElement()
                ..kind = 'MontyPython'
                ..name = 'Egg'
                ..id = null,
            ])
          ..properties = {
            'booleanProperty': Value()..booleanValue = true,
            'integerProperty': Value()..integerValue = '1',
            'doubleProperty': Value()..doubleValue = 3.141592,
            'keyProperty': Value()
              ..keyValue = (Key()
                ..partitionId = (PartitionId()
                  ..projectId = 'test-project'
                  ..namespaceId = null)
                ..path = [
                  PathElement()
                    ..kind = 'FlyingCircus'
                    ..name = null
                    ..id = '1',
                  PathElement()
                    ..kind = 'FlyingCircus'
                    ..name = null
                    ..id = '2'
                ]),
            'stringProperty': Value()
              ..stringValue = "NOBODY expects the Spanish Inquisition!!!!!",
            'childEntityProperty': Value()
              ..entityValue = (Entity()
                ..key = null
                ..properties = {
                  'inner1': Value()..integerValue = "1",
                  'inner2': Value()..doubleValue = 42,
                }),
            'arrayProperty': Value()
              ..arrayValue = (ArrayValue()
                ..values = [
                  Value()..integerValue = '1',
                  Value()..integerValue = '2',
                  Value()..integerValue = '3'
                ]),
            'timestampProperty': Value()
              ..timestampValue = "2014-10-02T15:01:23.045123456Z",
          }),
    ]);

final toPropertyOrderFixtures = [
  ToPropertyOrderFixture(null, null, null),
  ToPropertyOrderFixture(
    models.SortOrder('spam', ascending: true),
    null,
    [
      {
        "property": {
          "name": "spam",
        },
        "direction": "ASCENDING",
      },
    ],
  ),
  ToPropertyOrderFixture(
    models.SortOrder('spam', ascending: true),
    'spam',
    [
      {
        "property": {
          "name": "spam",
        },
        "direction": "ASCENDING",
      },
    ],
  ),
  ToPropertyOrderFixture(
    models.SortOrder('spam', ascending: true),
    'ham',
    null,
  ),
  ToPropertyOrderFixture(
    models.SortOrder('spam', ascending: false),
    null,
    [
      {
        "property": {
          "name": "spam",
        },
        "direction": "DESCENDING",
      },
    ],
  ),
  ToPropertyOrderFixture(
    models.SortOrder('spam', ascending: false),
    'spam',
    [
      {
        "property": {
          "name": "spam",
        },
        "direction": "DESCENDING",
      },
    ],
  ),
  ToPropertyOrderFixture(
    models.SortOrder('spam', ascending: false),
    'ham',
    null,
  ),
];

final createFilterFixtures = [
  CreateFilterFixture(
    filters.Filter(
      'Spam',
      filters.Property('ham', String),
      [filters.Property('ham', String)],
      filters.FilterType.EQUALS,
      [filters.FilterType.EQUALS],
      filters.EqualsFilterValue(String, 'spam'),
    ),
    {
      'propertyFilter': {
        'op': 'EQUAL',
        'property': {'name': 'ham'},
        'value': {'stringValue': 'spam'},
      },
    },
  ),
  CreateFilterFixture(
    filters.Filter(
      'Spam',
      filters.Property('ham', String),
      [filters.Property('ham', String)],
      filters.FilterType.RANGE,
      [filters.FilterType.RANGE],
      filters.RangeFilterValue(String, 'spam', 'ham', true, true),
    ),
    {
      'compositeFilter': {
        'filters': [
          {
            'propertyFilter': {
              'op': 'GREATER_THAN_OR_EQUAL',
              'property': {'name': 'ham'},
              'value': {'stringValue': 'ham'},
            }
          },
          {
            'propertyFilter': {
              'op': 'LESS_THAN_OR_EQUAL',
              'property': {'name': 'ham'},
              'value': {'stringValue': 'spam'},
            }
          },
        ],
        'op': 'AND',
      }
    },
  ),
];
