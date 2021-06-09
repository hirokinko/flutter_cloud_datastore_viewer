import 'package:meta/meta.dart';
import '../../lib/models/filters.dart';

@immutable
class OnChangePropertyValue {
  final Property? selectProperty;
  final PropertySelector? propertySelector;
  final Property? expectedProperty;
  final PropertySelector expectedPropertySelector;
  final FilterTypeSelector expectedFilterTypeSelector;

  const OnChangePropertyValue(
    this.selectProperty,
    this.propertySelector,
    this.expectedProperty,
    this.expectedPropertySelector,
    this.expectedFilterTypeSelector,
  );
}

final selectableProps = [
  Property('stringProperty', String),
  Property('boolProperty', bool),
];

final onChangePropertyFixtures = <OnChangePropertyValue>[
  OnChangePropertyValue(
    null,
    PropertySelector(selectableProps, null),
    null,
    PropertySelector(
      selectableProps,
      "プロパティを選択してください",
    ),
    FilterTypeSelector([FilterType.UNSPECIFIED], null),
  ),
  OnChangePropertyValue(
    Property('stringProperty', String),
    PropertySelector(selectableProps, null),
    Property('stringProperty', String),
    PropertySelector(
      selectableProps,
      null,
    ),
    FilterTypeSelector(
      [FilterType.UNSPECIFIED, FilterType.EQUALS, FilterType.RANGE],
      null,
    ),
  ),
  OnChangePropertyValue(
    Property('boolProperty', bool),
    PropertySelector(selectableProps, null),
    Property('boolProperty', bool),
    PropertySelector(
      selectableProps,
      null,
    ),
    FilterTypeSelector(
      [FilterType.UNSPECIFIED, FilterType.EQUALS],
      null,
    ),
  ),
  OnChangePropertyValue(
    Property('notExistsProperty', String),
    PropertySelector(selectableProps, null),
    null,
    PropertySelector(
      selectableProps,
      "notExistsProperty[String]は存在しません",
    ),
    FilterTypeSelector([FilterType.UNSPECIFIED], null),
  ),
  OnChangePropertyValue(
    Property('notExistsProperty', String),
    null,
    null,
    PropertySelector(
      [],
      "notExistsProperty[String]は存在しません",
    ),
    FilterTypeSelector([FilterType.UNSPECIFIED], null),
  ),
];
