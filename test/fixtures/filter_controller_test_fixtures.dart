import 'package:meta/meta.dart';
import '../../lib/models/filters.dart';

@immutable
class OnChangePropertyValue {
  final Property? selectProperty;
  final List<Property> selectableProperties;
  final Property? expectedProperty;
  final List<Property> expectedSelectableProperties;
  final String? expectedSelectedPropertyError;
  final FilterTypeSelector expectedFilterTypeSelector;

  const OnChangePropertyValue(
    this.selectProperty,
    this.selectableProperties,
    this.expectedProperty,
    this.expectedSelectableProperties,
    this.expectedSelectedPropertyError,
    this.expectedFilterTypeSelector,
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
    FilterTypeSelector([FilterType.UNSPECIFIED], null),
  ),
  OnChangePropertyValue(
    Property('stringProperty', String),
    selectableProps,
    Property('stringProperty', String),
    selectableProps,
    null,
    FilterTypeSelector(
      [FilterType.UNSPECIFIED, FilterType.EQUALS, FilterType.RANGE],
      null,
    ),
  ),
  OnChangePropertyValue(
    Property('boolProperty', bool),
    selectableProps,
    Property('boolProperty', bool),
    selectableProps,
    null,
    FilterTypeSelector(
      [FilterType.UNSPECIFIED, FilterType.EQUALS],
      null,
    ),
  ),
  OnChangePropertyValue(
    Property('notExistsProperty', String),
    selectableProps,
    null,
    selectableProps,
    "notExistsProperty[String]は存在しません",
    FilterTypeSelector([FilterType.UNSPECIFIED], null),
  ),
  OnChangePropertyValue(
    Property('notExistsProperty', String),
    [],
    null,
    [],
    "notExistsProperty[String]は存在しません",
    FilterTypeSelector([FilterType.UNSPECIFIED], null),
  ),
];
