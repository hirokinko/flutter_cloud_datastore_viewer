import 'package:meta/meta.dart';
import '../../lib/models/filters.dart';

@immutable
class OnChangePropertyValue {
  final Property? selectProperty;
  final List<Property> selectableProperties;
  final Property? expectedProperty;
  final List<Property> expectedSelectableProperties;
  final String? expectedSelectedPropertyError;
  final List<FilterType> expectedSelectableFilterTypes;

  const OnChangePropertyValue(
    this.selectProperty,
    this.selectableProperties,
    this.expectedProperty,
    this.expectedSelectableProperties,
    this.expectedSelectedPropertyError,
    this.expectedSelectableFilterTypes,
  );
}

@immutable
class OnChangeFilterTypeFixture {
  final FilterType selectedFilterType;
  final FilterType expectedFilterType;
  final String? expectedErrorMessage;
  final FilterValue? expectedFilterValue;

  OnChangeFilterTypeFixture(
    this.selectedFilterType,
    this.expectedFilterType,
    this.expectedErrorMessage,
    this.expectedFilterValue,
  );
}

@immutable
class OnChangeEqualsFilterValueFixture {
  final Property property;
  final String? givenValue;
  final EqualsFilterValue expectedFilterValue;
  final String? expectedError;

  OnChangeEqualsFilterValueFixture(
    this.property,
    this.givenValue,
    this.expectedFilterValue,
    this.expectedError,
  );
}

@immutable
class OnChangeRangeFilterValueFixture {
  final Property property;
  final String? givenMaxValue;
  final String? givenMinValue;
  final bool containsMaxValue;
  final bool containsMinValue;
  final RangeFilterValue expectedFilterValue;
  final String? expectedMaxValueError;
  final String? expectedMinValueError;
  final String? expectedFormError;

  OnChangeRangeFilterValueFixture(
    this.property,
    this.givenMaxValue,
    this.givenMinValue,
    this.expectedFilterValue,
    this.expectedMaxValueError,
    this.expectedMinValueError,
    this.expectedFormError, {
    this.containsMaxValue: false,
    this.containsMinValue: false,
  });
}

@immutable
class GetSuggestedPropertiesFixture {
  final String input;
  final List<Property> expected;

  GetSuggestedPropertiesFixture(this.input, this.expected);
}

final selectableProps = <Property>[
  Property('stringProperty', String),
  Property('boolProperty', bool),
];

final onChangePropertyFixtures = <OnChangePropertyValue>[
  OnChangePropertyValue(
    null,
    selectableProps,
    null,
    selectableProps,
    "??????????????????????????????????????????",
    FILTER_UNSELECTABLE,
  ),
  OnChangePropertyValue(
    Property('stringProperty', String),
    selectableProps,
    Property('stringProperty', String),
    selectableProps,
    null,
    AVAILABLE_ALL_FILTERS,
  ),
  OnChangePropertyValue(
    Property('boolProperty', bool),
    selectableProps,
    Property('boolProperty', bool),
    selectableProps,
    null,
    EQUALS_FILTER_ONLY,
  ),
];

final onChangeFilterTypeFixtures = <OnChangeFilterTypeFixture>[
  OnChangeFilterTypeFixture(
    FilterType.UNSPECIFIED,
    FilterType.UNSPECIFIED,
    "???????????????????????????????????????????????????",
    null,
  ),
  OnChangeFilterTypeFixture(
    FilterType.EQUALS,
    FilterType.EQUALS,
    null,
    EqualsFilterValue(Null, null),
  ),
  OnChangeFilterTypeFixture(
    FilterType.RANGE,
    FilterType.RANGE,
    null,
    RangeFilterValue(Null, null, null, false, false),
  ),
];

final onChangeEqualsFilterValueFixtures = <OnChangeEqualsFilterValueFixture>[
  OnChangeEqualsFilterValueFixture(
    Property('stringProperty', String),
    null,
    EqualsFilterValue(String, null),
    "??????????????????????????????",
  ),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    'true',
    EqualsFilterValue(bool, 'true'),
    null,
  ),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    'false',
    EqualsFilterValue(bool, 'false'),
    null,
  ),
  OnChangeEqualsFilterValueFixture(Property('booleanProperty', bool), null,
      EqualsFilterValue(bool, null), "??????????????????????????????"),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    'spam',
    EqualsFilterValue(
      bool,
      'spam',
    ),
    "'true'?????????'false'???????????????????????????",
  ),
  OnChangeEqualsFilterValueFixture(
    Property('stringProperty', String),
    '',
    EqualsFilterValue(String, ''),
    "??????????????????????????????",
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '1',
    EqualsFilterValue(int, '1'),
    null,
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '-1',
    EqualsFilterValue(int, '-1'),
    null,
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '',
    EqualsFilterValue(int, ''),
    "??????????????????????????????",
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    'spam',
    EqualsFilterValue(int, 'spam'),
    "????????????????????????????????????",
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '3.1415926535',
    EqualsFilterValue(int, '3.1415926535'),
    "????????????????????????????????????",
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1.0',
    EqualsFilterValue(double, '1.0'),
    null,
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '-1.0',
    EqualsFilterValue(double, '-1.0'),
    null,
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1',
    EqualsFilterValue(double, '1'),
    null,
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '-1',
    EqualsFilterValue(double, '-1'),
    null,
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1E6',
    EqualsFilterValue(double, '1E6'),
    null,
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1E-6',
    EqualsFilterValue(double, '1E-6'),
    null,
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '',
    EqualsFilterValue(double, ''),
    "??????????????????????????????",
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    'spam',
    EqualsFilterValue(double, 'spam'),
    "????????????????????????????????????",
  ),
  // TODO: double???????????????NaN???Inf???????????????????????????????????????
];

final onChangeRangeFilterValueFixtures = [
  OnChangeRangeFilterValueFixture(
    Property('stringProperty', String),
    null,
    null,
    RangeFilterValue(
      String,
      null,
      null,
      false,
      false,
    ),
    null,
    null,
    "????????????????????????????????????????????????????????????",
  ),
  OnChangeRangeFilterValueFixture(
    Property('stringProperty', String),
    '',
    '',
    RangeFilterValue(
      String,
      '',
      '',
      false,
      false,
    ),
    null,
    null,
    "????????????????????????????????????????????????????????????",
  ),
  OnChangeRangeFilterValueFixture(
    Property('stringProperty', String),
    null,
    '',
    RangeFilterValue(
      String,
      null,
      '',
      false,
      false,
    ),
    null,
    null,
    "????????????????????????????????????????????????????????????",
  ),
  OnChangeRangeFilterValueFixture(
    Property('stringProperty', String),
    '',
    null,
    RangeFilterValue(
      String,
      '',
      null,
      false,
      false,
    ),
    null,
    null,
    "????????????????????????????????????????????????????????????",
  ),
  OnChangeRangeFilterValueFixture(
    Property('booleanProperty', bool),
    'true',
    'false',
    RangeFilterValue(
      bool,
      'true',
      'false',
      false,
      false,
    ),
    null,
    null,
    "??????????????????????????????????????????????????????????????????????????????",
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    'spam',
    'ham',
    RangeFilterValue(
      int,
      'spam',
      'ham',
      false,
      false,
    ),
    "????????????????????????????????????",
    "????????????????????????????????????",
    null,
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '0',
    null,
    RangeFilterValue(int, '0', null, false, false),
    null,
    null,
    null,
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '0',
    '',
    RangeFilterValue(int, '0', '', false, false),
    null,
    null,
    null,
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    null,
    '0',
    RangeFilterValue(int, null, '0', false, false),
    null,
    null,
    null,
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '',
    '0',
    RangeFilterValue(int, '', '0', false, false),
    null,
    null,
    null,
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '1',
    '2',
    RangeFilterValue(
      int,
      '1',
      '2',
      false,
      false,
    ),
    null,
    null,
    "???????????????????????????????????????????????????????????????????????????",
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    'spam',
    'ham',
    RangeFilterValue(
      double,
      'spam',
      'ham',
      false,
      false,
    ),
    "????????????????????????????????????",
    "????????????????????????????????????",
    null,
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '1.0',
    null,
    RangeFilterValue(double, '1.0', null, false, false),
    null,
    null,
    null,
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '1.0',
    '',
    RangeFilterValue(double, '1.0', '', false, false),
    null,
    null,
    null,
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    null,
    '1.0',
    RangeFilterValue(double, null, '1.0', false, false),
    null,
    null,
    null,
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '',
    '1.0',
    RangeFilterValue(double, '', '1.0', false, false),
    null,
    null,
    null,
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '1',
    '2',
    RangeFilterValue(
      double,
      '1',
      '2',
      false,
      false,
    ),
    null,
    null,
    "???????????????????????????????????????????????????????????????????????????",
  ),
];

final getSuggestedPropertiesFixtures = [
  GetSuggestedPropertiesFixture(
    'P',
    <Property>[
      Property('stringProperty', String),
      Property('boolProperty', bool),
    ],
  ),
  GetSuggestedPropertiesFixture(
    'B',
    <Property>[
      Property('boolProperty', bool),
    ],
  ),
  GetSuggestedPropertiesFixture(
    'Hoge',
    <Property>[],
  ),
  GetSuggestedPropertiesFixture(
    '',
    <Property>[
      Property('stringProperty', String),
      Property('boolProperty', bool),
    ],
  ),
];
