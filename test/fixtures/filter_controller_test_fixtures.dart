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
  final Set<String> expectedFilterValueErrors;

  OnChangeEqualsFilterValueFixture(
    this.property,
    this.givenValue,
    this.expectedFilterValue,
    this.expectedFilterValueErrors,
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
  final Set<String> expectedFilterValueErrors;

  OnChangeRangeFilterValueFixture(
    this.property,
    this.givenMaxValue,
    this.givenMinValue,
    this.expectedFilterValue,
    this.expectedFilterValueErrors, {
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
    EqualsFilterValue(null, null),
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
    EqualsFilterValue(null, "値を入力してください"),
    {"値を入力してください"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    'true',
    EqualsFilterValue('true', null),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    'false',
    EqualsFilterValue('false', null),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    null,
    EqualsFilterValue(null, "値を入力してください"),
    {"値を入力してください"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    'spam',
    EqualsFilterValue('spam', "入力値は'true'または'false'でないといけません"),
    {"入力値は'true'または'false'でないといけません"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('stringProperty', String),
    '',
    EqualsFilterValue('', "値を入力してください"),
    {"値を入力してください"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '1',
    EqualsFilterValue('1', null),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '-1',
    EqualsFilterValue('-1', null),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '',
    EqualsFilterValue('', "整数値を入力してください"),
    {"入力値は整数でないといけません"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    'spam',
    EqualsFilterValue('spam', "整数値を入力してください"),
    {"入力値は整数でないといけません"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '3.1415926535',
    EqualsFilterValue('3.1415926535', "整数値を入力してください"),
    {"入力値は整数でないといけません"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1.0',
    EqualsFilterValue('1.0', null),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '-1.0',
    EqualsFilterValue('-1.0', null),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1',
    EqualsFilterValue('1', null),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '-1',
    EqualsFilterValue('-1', null),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1E6',
    EqualsFilterValue('1E6', null),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1E-6',
    EqualsFilterValue('1E-6', null),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '',
    EqualsFilterValue('', "実数値を入力してください"),
    {"入力値は実数でないといけません"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    'spam',
    EqualsFilterValue('spam', "実数値を入力してください"),
    {"入力値は実数でないといけません"},
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
    {"最大値または最小値に値を入力してください"},
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
    {"最大値または最小値に値を入力してください"},
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
    {"最大値または最小値に値を入力してください"},
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
    {"最大値または最小値に値を入力してください"},
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
    {"真理値型のプロパティに範囲フィルターは使用できません"},
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    'spam',
    'ham',
    RangeFilterValue('spam', 'ham', false, false, null, null, null),
    {"最大値は整数でないといけません", "最小値は整数でないといけません"},
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '0',
    null,
    RangeFilterValue('0', null, false, false, null, null, null),
    {},
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '0',
    '',
    RangeFilterValue('0', '', false, false, null, null, null),
    {},
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    null,
    '0',
    RangeFilterValue(null, '0', false, false, null, null, null),
    {},
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '',
    '0',
    RangeFilterValue('', '0', false, false, null, null, null),
    {},
  ),
  OnChangeRangeFilterValueFixture(
    Property('integerProperty', int),
    '1',
    '2',
    RangeFilterValue('1', '2', false, false, null, null, null),
    {"最大値は最小値以上でないといけません"},
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    'spam',
    'ham',
    RangeFilterValue('spam', 'ham', false, false, null, null, null),
    {"最大値は実数でないといけません", "最小値は実数でないといけません"},
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '1.0',
    null,
    RangeFilterValue('1.0', null, false, false, null, null, null),
    {},
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '1.0',
    '',
    RangeFilterValue('1.0', '', false, false, null, null, null),
    {},
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    null,
    '1.0',
    RangeFilterValue(null, '1.0', false, false, null, null, null),
    {},
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '',
    '1.0',
    RangeFilterValue('', '1.0', false, false, null, null, null),
    {},
  ),
  OnChangeRangeFilterValueFixture(
    Property('doubleProperty', double),
    '1',
    '2',
    RangeFilterValue('1', '2', false, false, null, null, null),
    {"最大値は最小値以上でないといけません"},
  ),
];
