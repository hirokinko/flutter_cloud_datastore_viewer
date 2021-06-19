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

  OnChangeRangeFilterValueFixture(
    this.property,
    this.givenMaxValue,
    this.givenMinValue,
    this.expectedFilterValue, {
    this.containsMaxValue: false,
    this.containsMinValue: false,
  });
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
    "プロパティを選択してください",
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
    "フィルタータイプを選択してください",
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
    RangeFilterValue(null, null, false, false, null, null, null),
  ),
];

final onChangeEqualsFilterValueFixtures = <OnChangeEqualsFilterValueFixture>[
  OnChangeEqualsFilterValueFixture(
    Property('stringProperty', String),
    null,
    EqualsFilterValue(String, null),
    "値を入力してください",
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
      EqualsFilterValue(bool, null), "値を入力してください"),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    'spam',
    EqualsFilterValue(
      bool,
      'spam',
    ),
    "'true'または'false'を入力してください",
  ),
  OnChangeEqualsFilterValueFixture(
    Property('stringProperty', String),
    '',
    EqualsFilterValue(String, ''),
    "値を入力してください",
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
    "値を入力してください",
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    'spam',
    EqualsFilterValue(int, 'spam'),
    "整数値を入力してください",
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '3.1415926535',
    EqualsFilterValue(int, '3.1415926535'),
    "整数値を入力してください",
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
    "値を入力してください",
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    'spam',
    EqualsFilterValue(double, 'spam'),
    "実数値を入力してください",
  ),
  // TODO: doubleについてはNaNやInfを与えたときの処理も必要？
];

final onChangeRangeFilterValueFixtures = [
  OnChangeRangeFilterValueFixture(
    Property('stringProperty', String),
    null,
    null,
    RangeFilterValue(
      null,
      null,
      false,
      false,
      "最大値または最小値に値を入力してください",
      null,
      null,
    ),
  ),
  OnChangeRangeFilterValueFixture(
    Property('stringProperty', String),
    '',
    '',
    RangeFilterValue(
      '',
      '',
      false,
      false,
      "最大値または最小値に値を入力してください",
      null,
      null,
    ),
  ),
  OnChangeRangeFilterValueFixture(
    Property('stringProperty', String),
    null,
    '',
    RangeFilterValue(
      null,
      '',
      false,
      false,
      "最大値または最小値に値を入力してください",
      null,
      null,
    ),
  ),
  OnChangeRangeFilterValueFixture(
    Property('stringProperty', String),
    '',
    null,
    RangeFilterValue(
      '',
      null,
      false,
      false,
      "最大値または最小値に値を入力してください",
      null,
      null,
    ),
  ),
  OnChangeRangeFilterValueFixture(
    Property('booleanProperty', bool),
    'true',
    'false',
    RangeFilterValue(
      'true',
      'false',
      false,
      false,
      "真理値型のプロパティに範囲フィルターは使用できません",
      null,
      null,
    ),
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    'spam',
    'ham',
    RangeFilterValue(
      'spam',
      'ham',
      false,
      false,
      null,
      "最大値には整数値を入力してください",
      "最小値には整数値を入力してください",
    ),
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '0',
    null,
    RangeFilterValue('0', null, false, false, null, null, null),
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '0',
    '',
    RangeFilterValue('0', '', false, false, null, null, null),
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    null,
    '0',
    RangeFilterValue(null, '0', false, false, null, null, null),
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '',
    '0',
    RangeFilterValue('', '0', false, false, null, null, null),
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '1',
    '2',
    RangeFilterValue(
      '1',
      '2',
      false,
      false,
      "最大値には最小値より大きい整数値を入力してください",
      null,
      null,
    ),
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    'spam',
    'ham',
    RangeFilterValue(
      'spam',
      'ham',
      false,
      false,
      null,
      "最大値には実数値を入力してください",
      "最小値には実数値を入力してください",
    ),
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '1.0',
    null,
    RangeFilterValue('1.0', null, false, false, null, null, null),
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '1.0',
    '',
    RangeFilterValue('1.0', '', false, false, null, null, null),
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    null,
    '1.0',
    RangeFilterValue(null, '1.0', false, false, null, null, null),
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '',
    '1.0',
    RangeFilterValue('', '1.0', false, false, null, null, null),
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '1',
    '2',
    RangeFilterValue(
      '1',
      '2',
      false,
      false,
      "最大値には最小値より大きい実数値を入力してください",
      null,
      null,
    ),
  ),
];
