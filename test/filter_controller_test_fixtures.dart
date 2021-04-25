import 'package:meta/meta.dart';
import 'package:flutter_cloud_datastore_viewer/controllers/filter_controller.dart';
import 'package:flutter_cloud_datastore_viewer/models/filter.dart';
import 'package:flutter_cloud_datastore_viewer/models/property.dart';

@immutable
class OnChangePropertyValues {
  const OnChangePropertyValues(
    this.fixtureTitle,
    this.selectProperty,
    this.expectedProperty,
    this.operatorSelector,
  );

  final String fixtureTitle;
  final Property? selectProperty;
  final Property? expectedProperty;
  final List<Operator> operatorSelector;
}

@immutable
class OnChangeOperatorValues {
  const OnChangeOperatorValues(
    this.fixtureTitle,
    this.selectProperty,
    this.selectOperator,
    this.expectedOperator,
  );

  final String fixtureTitle;
  final Property? selectProperty;
  final Operator selectOperator;
  final Operator expectedOperator;
}

@immutable
class OnSubmitValues {
  const OnSubmitValues(
    this.fixtureTitle,
    this.selectProperty,
    this.selectOperator,
    this.submitValue,
    this.expectPropertyFilter,
  );

  final String fixtureTitle;
  final Property? selectProperty;
  final Operator selectOperator;
  final String? submitValue;
  final String? expectPropertyFilter;
}

final onChangePropertyFixtures = <OnChangePropertyValues>[
  OnChangePropertyValues(
    'stringValue property',
    Property('stringValue', true, String),
    Property('stringValue', true, String),
    Operator.values,
  ),
  OnChangePropertyValues(
    'booleanValue property',
    Property('booleanValue', true, bool),
    Property('booleanValue', true, bool),
    BOOLEAN_OP_SELECTOR,
  ),
  OnChangePropertyValues(
    'integerValue property',
    Property('integerValue', true, int),
    Property('integerValue', true, int),
    Operator.values,
  ),
  OnChangePropertyValues(
    'doubleValue property',
    Property('doubleValue', true, double),
    Property('doubleValue', true, double),
    Operator.values,
  ),
  OnChangePropertyValues(
    'null',
    null,
    null,
    UNSPECIFIED_OP_SELECTOR,
  ),
  OnChangePropertyValues(
    'not exist property',
    Property('anyValue', true, String),
    null,
    UNSPECIFIED_OP_SELECTOR,
  ),
  OnChangePropertyValues(
    'other property',
    Property('stringValue', false, String),
    null,
    UNSPECIFIED_OP_SELECTOR,
  ),
];

final onChangeOperatorFixtures = <OnChangeOperatorValues>[
  OnChangeOperatorValues(
    Operator.EQ.value,
    Property('stringValue', true, String),
    Operator.EQ,
    Operator.EQ,
  ),
  OnChangeOperatorValues(
    Operator.GT.value,
    Property('stringValue', true, String),
    Operator.GT,
    Operator.GT,
  ),
  OnChangeOperatorValues(
    Operator.GTE.value,
    Property('stringValue', true, String),
    Operator.GTE,
    Operator.GTE,
  ),
  OnChangeOperatorValues(
    Operator.LT.value,
    Property('stringValue', true, String),
    Operator.LT,
    Operator.LT,
  ),
  OnChangeOperatorValues(
    Operator.LTE.value,
    Property('stringValue', true, String),
    Operator.LTE,
    Operator.LTE,
  ),
  OnChangeOperatorValues(
    Operator.UNSPECIFIED.value,
    Property('stringValue', true, String),
    Operator.UNSPECIFIED,
    Operator.UNSPECIFIED,
  ),
  OnChangeOperatorValues(
    Operator.EQ.value,
    Property('booleanValue', true, bool),
    Operator.EQ,
    Operator.EQ,
  ),
  OnChangeOperatorValues(
    Operator.UNSPECIFIED.value,
    Property('booleanValue', true, bool),
    Operator.UNSPECIFIED,
    Operator.UNSPECIFIED,
  ),
  OnChangeOperatorValues(
    Operator.GT.value,
    Property('booleanValue', true, bool),
    Operator.GT,
    Operator.UNSPECIFIED,
  ),
  OnChangeOperatorValues(
    Operator.GTE.value,
    Property('booleanValue', true, bool),
    Operator.GTE,
    Operator.UNSPECIFIED,
  ),
  OnChangeOperatorValues(
    Operator.LT.value,
    Property('booleanValue', true, bool),
    Operator.LT,
    Operator.UNSPECIFIED,
  ),
  OnChangeOperatorValues(
    Operator.LTE.value,
    Property('booleanValue', true, bool),
    Operator.LTE,
    Operator.UNSPECIFIED,
  ),
  OnChangeOperatorValues(
    Operator.EQ.value,
    Property('unexistValue', true, String),
    Operator.EQ,
    Operator.UNSPECIFIED,
  ),
  OnChangeOperatorValues(
    Operator.GT.value,
    Property('unexistValue', true, String),
    Operator.GT,
    Operator.UNSPECIFIED,
  ),
  OnChangeOperatorValues(
    Operator.GTE.value,
    Property('unexistValue', true, String),
    Operator.GTE,
    Operator.UNSPECIFIED,
  ),
  OnChangeOperatorValues(
    Operator.LT.value,
    Property('unexistValue', true, String),
    Operator.LT,
    Operator.UNSPECIFIED,
  ),
  OnChangeOperatorValues(
    Operator.LTE.value,
    Property('unexistValue', true, String),
    Operator.LTE,
    Operator.UNSPECIFIED,
  ),
];

final onSubmitFixtures = <OnSubmitValues>[
  OnSubmitValues(
    'stringValue',
    Property('stringValue', true, String),
    Operator.EQ,
    'spam',
    Filter(Property('stringValue', true, String), Operator.EQ, 'spam')
        .toPropertyFilter()!
        .toJson()
        .toString(),
  ),
  OnSubmitValues(
    'integerValue',
    Property('integerValue', true, int),
    Operator.EQ,
    '42',
    Filter(Property('integerValue', true, int), Operator.EQ, 42)
        .toPropertyFilter()!
        .toJson()
        .toString(),
  ),
  OnSubmitValues(
    'doubleValue',
    Property('doubleValue', true, double),
    Operator.EQ,
    '42',
    Filter(Property('doubleValue', true, double), Operator.EQ, 42.0)
        .toPropertyFilter()!
        .toJson()
        .toString(),
  ),
  OnSubmitValues(
    'booleanValue true',
    Property('booleanValue', true, bool),
    Operator.EQ,
    'true',
    Filter(Property('booleanValue', true, bool), Operator.EQ, true)
        .toPropertyFilter()!
        .toJson()
        .toString(),
  ),
  OnSubmitValues(
    'booleanValue false',
    Property('booleanValue', true, bool),
    Operator.EQ,
    'false',
    Filter(Property('booleanValue', true, bool), Operator.EQ, false)
        .toPropertyFilter()!
        .toJson()
        .toString(),
  ),
];

final onSubmitErrorFixtures = <OnSubmitValues>[
  OnSubmitValues(
    'Empty string',
    Property('stringValue', true, String),
    Operator.EQ,
    '',
    null,
  ),
  OnSubmitValues(
    'Not integer value (character)',
    Property('integerValue', true, int),
    Operator.EQ,
    'spam',
    null,
  ),
  OnSubmitValues(
    'Not integer value (double)',
    Property('integerValue', true, int),
    Operator.EQ,
    '42.0',
    null,
  ),
  OnSubmitValues(
    'Not double value (character)',
    Property('doubleValue', true, double),
    Operator.EQ,
    'spam',
    null,
  ),
  OnSubmitValues(
    'Not boolean value',
    Property('booleanValue', true, bool),
    Operator.EQ,
    'spam',
    null,
  ),
  OnSubmitValues('No selected property', null, Operator.EQ, 'spam', null),
  OnSubmitValues(
    'Unspecified operator',
    Property('stringValue', true, String),
    Operator.UNSPECIFIED,
    'spam',
    null,
  ),
  OnSubmitValues(
    'Null value',
    Property('stringValue', true, String),
    Operator.EQ,
    null,
    null,
  )
];
