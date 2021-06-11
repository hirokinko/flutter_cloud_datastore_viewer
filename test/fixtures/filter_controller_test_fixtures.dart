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
    EqualsFilterValue(null),
  ),
  OnChangeFilterTypeFixture(
    FilterType.RANGE,
    FilterType.RANGE,
    null,
    RangeFilterValue(null, null),
  ),
];

final onChangeEqualsFilterValueFixtures = <OnChangeEqualsFilterValueFixture>[
  OnChangeEqualsFilterValueFixture(
    Property('stringProperty', String),
    null,
    EqualsFilterValue(null),
    {"値を入力してください"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    'true',
    EqualsFilterValue('true'),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    'false',
    EqualsFilterValue('false'),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    null,
    EqualsFilterValue(null),
    {"値を入力してください"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('booleanProperty', bool),
    'spam',
    EqualsFilterValue('spam'),
    {"booleanProperty[bool]は'true'または'false'でないといけません"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('stringProperty', String),
    '',
    EqualsFilterValue(''),
    {"値を入力してください"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '1',
    EqualsFilterValue('1'),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '-1',
    EqualsFilterValue('-1'),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '',
    EqualsFilterValue(''),
    {"入力値は整数でないといけません"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    'spam',
    EqualsFilterValue('spam'),
    {"入力値は整数でないといけません"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('integerProperty', int),
    '3.1415926535',
    EqualsFilterValue('3.1415926535'),
    {"入力値は整数でないといけません"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1.0',
    EqualsFilterValue('1.0'),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '-1.0',
    EqualsFilterValue('-1.0'),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1',
    EqualsFilterValue('1'),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '-1',
    EqualsFilterValue('-1'),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1E6',
    EqualsFilterValue('1E6'),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '1E-6',
    EqualsFilterValue('1E-6'),
    {},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    '',
    EqualsFilterValue(''),
    {"入力値は実数でないといけません"},
  ),
  OnChangeEqualsFilterValueFixture(
    Property('dobuleValue', double),
    'spam',
    EqualsFilterValue('spam'),
    {"入力値は実数でないといけません"},
  ),
  // TODO: doubleについてはNaNやInfを与えたときの処理も必要？
];
