import 'package:meta/meta.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/filters.dart';

final filterControllerProvider =
    Provider.autoDispose((ref) => FilterController(ref.read));

@immutable
class FilterController {
  final Reader read;

  FilterController(this.read);

  void onChangeProperty(Property? prop) {
    final current = this.read(filterStateProvider).state;
    this.read(filterStateProvider).state = Filter(
      prop,
      current.selectableProperties,
      FilterType.UNSPECIFIED,
      current.getSelectableFilterTypes(prop),
      null,
    );
  }

  void onChangeFilterType(FilterType filterType) {
    late final FilterValue? filterValue;
    switch (filterType) {
      case FilterType.EQUALS:
        filterValue = defaultEqualsFilterValue;
        break;
      case FilterType.RANGE:
        filterValue = defaultRangeFilterValue;
        break;
      default:
        filterValue = null;
    }

    final current = this.read(filterStateProvider).state;
    this.read(filterStateProvider).state = Filter(
      current.selectedProperty,
      current.selectableProperties,
      filterType,
      current.selectableFilterTypes,
      filterValue,
    );
  }

  void onChangeEqualsFilterValue(String? value) {
    final current = this.read(filterStateProvider).state;
    this.read(filterStateProvider).state = Filter(
      current.selectedProperty,
      current.selectableProperties,
      current.filterType,
      current.selectableFilterTypes,
      EqualsFilterValue(current.selectedProperty!.type, value),
    );
  }

  void onChangeRangeFilterValues(
    String? maxValue,
    String? minValue, {
    bool containsMaxValue: false,
    bool containsMinValue: false,
  }) {
    final current = this.read(filterStateProvider).state;
    this.read(filterStateProvider).state = Filter(
      current.selectedProperty,
      current.selectableProperties,
      current.filterType,
      current.selectableFilterTypes,
      RangeFilterValue(
        current.selectedProperty!.type,
        maxValue,
        minValue,
        containsMaxValue,
        containsMinValue,
      ),
    );
  }

  void onSubmitFilterClear() {
    final current = this.read(filterStateProvider).state;
    this.read(filterStateProvider).state = Filter(
      null,
      current.selectableProperties,
      FilterType.UNSPECIFIED,
      FILTER_UNSELECTABLE,
      null,
    );
  }
}
