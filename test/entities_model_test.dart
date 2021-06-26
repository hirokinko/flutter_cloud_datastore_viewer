import 'package:flutter_cloud_datastore_viewer/models/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SingleProperty', () {
    test('SingleProperty', () {
      final property = SingleProperty('intValue', int, true, 1);
      final result = property.propertyEntries;
      expect(result.length, 1);
      expect(result[0].key, 'intValue');
      expect(result[0].value, int);
    });

    test('Null value SingleProperty', () {
      final property = SingleProperty('intValue', int, true, null);
      final result = property.propertyEntries;
      expect(result.length, 1);
      expect(result[0].key, 'intValue');
      expect(result[0].value, int);
    });

    test('Entity Value SingleProperty', () {
      final innerEntity = Entity(
        null,
        [
          SingleProperty('innerIntValue', int, true, 1),
          SingleProperty('innerDoubleValue', double, true, 1.0),
          SingleProperty('innerBoolValue', bool, false, true),
        ],
      );
      final property = SingleProperty('entityValue', Entity, true, innerEntity);
      final result = property.propertyEntries;
      expect(result.length, 2);
      expect(result[0].key, 'entityValue.innerIntValue');
      expect(result[0].value, int);
      expect(result[1].key, 'entityValue.innerDoubleValue');
      expect(result[1].value, double);
    });

    test('null Entity Value SingleProperty', () {
      final property = SingleProperty('entityValue', Entity, true, null);
      final result = property.propertyEntries;
      expect(result.length, 0);
    });

    test('Single Key Property', () {
      final property = SingleProperty(
        'user_key',
        Key,
        true,
        Key(
          'test-project',
          null,
          'User',
          null,
          'hogehoge',
          [],
        ),
      );
      final result = property.propertyEntries;
      expect(result.length, 3);
      expect(result[0].key, 'user_key.kind');
      expect(result[0].value, String);
      expect(result[1].key, 'user_key.name');
      expect(result[1].value, String);
      expect(result[2].key, 'user_key.id');
      expect(result[2].value, int);
    });

    test('null Single Key Property', () {
      final property = SingleProperty(
        'user_key',
        Key,
        true,
        null,
      );
      final result = property.propertyEntries;
      expect(result.length, 3);
      expect(result[0].key, 'user_key.kind');
      expect(result[0].value, String);
      expect(result[1].key, 'user_key.name');
      expect(result[1].value, String);
      expect(result[2].key, 'user_key.id');
      expect(result[2].value, int);
    });
  });

  group('ListProperty', () {
    test('ListProperty', () {
      final property = ListProperty('listProperty', int, true, [1, 2, 3]);
      final result = property.propertyEntries;
      expect(result.length, 1);
      expect(result[0].key, 'listProperty');
      expect(result[0].value, int);
    });

    test('Empty ListProperty', () {
      final property = ListProperty('listProperty', int, true, <int>[]);
      final result = property.propertyEntries;
      expect(result.length, 1);
      expect(result[0].key, 'listProperty');
      expect(result[0].value, int);
    });

    test('Entity ListProperty', () {
      final property = ListProperty(
        'entityListProperty',
        Entity,
        true,
        [
          Entity(
            null,
            [SingleProperty('innerIntValue', int, true, 1)],
          ),
        ],
      );
      final result = property.propertyEntries;
      expect(result.length, 1);
      expect(result[0].key, 'entityListProperty.innerIntValue');
      expect(result[0].value, int);
    });

    test('empty Entity ListProperty', () {
      final property = ListProperty('entityListProperty', Entity, true, []);
      final result = property.propertyEntries;
      expect(result.length, 0);
    });

    test('Key list property', () {
      final property = ListProperty(
        'keys',
        Key,
        true,
        [
          Key(
            'test-project',
            null,
            'Spam',
            null,
            'spam',
            [],
          ),
        ],
      );
      final result = property.propertyEntries;
      expect(result.length, 3);
      expect(result[0].key, 'keys.kind');
      expect(result[0].value, String);
      expect(result[1].key, 'keys.name');
      expect(result[1].value, String);
      expect(result[2].key, 'keys.id');
      expect(result[2].value, int);
    });

    test('empty Key list property', () {
      final property = ListProperty(
        'keys',
        Key,
        true,
        [],
      );
      final result = property.propertyEntries;
      expect(result.length, 3);
      expect(result[0].key, 'keys.kind');
      expect(result[0].value, String);
      expect(result[1].key, 'keys.name');
      expect(result[1].value, String);
      expect(result[2].key, 'keys.id');
      expect(result[2].value, int);
    });
  });

  group('Entity', () {
    test('Entity', () {
      final entity = Entity(null, [
        SingleProperty("intValue", int, true, 1),
        SingleProperty("unindexedBoolValue", bool, false, true),
        ListProperty("stringListValue", String, true, ["spam", "ham", "egg"]),
      ]);
      final result = entity.getInnerPropertyEntries(null, true);
      expect(result.length, 2);
      expect(result[0].key, 'intValue');
      expect(result[0].value, int);
      expect(result[1].key, 'stringListValue');
      expect(result[1].value, String);
    });

    test('Nested Entity', () {
      final parent = Entity(
        null,
        [
          SingleProperty("intValue", int, true, 1),
          SingleProperty(
            "childEntityValue",
            Entity,
            true,
            Entity(
              null,
              [
                SingleProperty("childIntValue", int, true, 1),
                SingleProperty("childStringValue", String, true, "Spam"),
              ],
            ),
          ),
        ],
      );
      final result = parent.getInnerPropertyEntries(null, true);
      expect(result.length, 3);
      expect(result[0].key, 'intValue');
      expect(result[0].value, int);
      expect(result[1].key, 'childEntityValue.childIntValue');
      expect(result[1].value, int);
      expect(result[2].key, 'childEntityValue.childStringValue');
      expect(result[2].value, String);
    });

    test('Double nested entity', () {
      final parent = Entity(
        null,
        [
          SingleProperty(
            'child',
            Entity,
            true,
            Entity(
              null,
              [
                SingleProperty(
                  'grandchild',
                  Entity,
                  true,
                  Entity(
                    null,
                    [
                      SingleProperty(
                        'intValue',
                        int,
                        true,
                        1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
      final result = parent.getInnerPropertyEntries(null, true);
      expect(result.length, 1);
      expect(result[0].key, 'child.grandchild.intValue');
      expect(result[0].value, int);
    });
  });

  test('Nested Entity with Key', () {
    final parent = Entity(
      Key('test-project', null, 'Spam', 1234, null, []),
      [
        SingleProperty("intValue", int, true, 1),
        SingleProperty(
          "childEntityValue",
          Entity,
          true,
          Entity(
            null,
            [
              SingleProperty("childIntValue", int, true, 1),
              SingleProperty("childStringValue", String, true, "Spam"),
            ],
          ),
        ),
      ],
    );
    final result = parent.getInnerPropertyEntries(null, true);
    expect(result.length, 6);
    expect(result[0].key, '__key__.kind');
    expect(result[0].value, String);
    expect(result[1].key, '__key__.name');
    expect(result[1].value, String);
    expect(result[2].key, '__key__.id');
    expect(result[2].value, int);
    expect(result[3].key, 'intValue');
    expect(result[3].value, int);
    expect(result[4].key, 'childEntityValue.childIntValue');
    expect(result[4].value, int);
    expect(result[5].key, 'childEntityValue.childStringValue');
    expect(result[5].value, String);
  });
}
