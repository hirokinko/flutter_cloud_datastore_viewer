import 'package:meta/meta.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/filters.dart';

final filterStateProvider = StateProvider.autoDispose((ref) {
  return Filter(
    null,
    [],
    null,
    FilterType.UNSPECIFIED,
    FILTER_UNSELECTABLE,
    null,
    null,
    {},
  );
});
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
      current.validateSelectedProperty(prop),
      FilterType.UNSPECIFIED,
      current.getSelectableFilterTypes(prop),
      null,
      null,
      {},
    );
  }

  void onChangeFilterType(FilterType filterType) {
    final current = this.read(filterStateProvider).state;
    this.read(filterStateProvider).state = Filter(
      current.selectedProperty,
      current.selectableProperties,
      null,
      filterType,
      current.selectableFilterTypes,
      current.validateSelectedFilterType(filterType),
      current.generateDefaultFilterValue(filterType),
      {},
    );
  }

  void onChangeEqualsFilterValue(String? value) {
    final current = this.read(filterStateProvider).state;
    final newFilterValue = EqualsFilterValue(value);
    this.read(filterStateProvider).state = Filter(
      current.selectedProperty,
      current.selectableProperties,
      current.selectedPropertyError,
      current.filterType,
      current.selectableFilterTypes,
      current.selectedFilterTypeError,
      newFilterValue,
      newFilterValue.validate(current.selectedProperty!),
    );
  }

  void onChangeRangeFilterValues(
    String? maxValue,
    String? minValue, {
    bool containsMaxValue: false,
    bool containsMinValue: false,
  }) {
    final current = this.read(filterStateProvider).state;
    final newFilterValue = RangeFilterValue(
      maxValue,
      minValue,
      containsMaxValue: containsMaxValue,
      containsMinValue: containsMinValue,
    );
    this.read(filterStateProvider).state = Filter(
      current.selectedProperty,
      current.selectableProperties,
      current.selectedPropertyError,
      current.filterType,
      current.selectableFilterTypes,
      current.selectedFilterTypeError,
      newFilterValue,
      newFilterValue.validate(current.selectedProperty!),
    );
  }

  void onSubmitFilterClear() {
    final current = this.read(filterStateProvider).state;
    this.read(filterStateProvider).state = Filter(
      null,
      current.selectableProperties,
      null,
      FilterType.UNSPECIFIED,
      FILTER_UNSELECTABLE,
      null,
      null,
      {},
    );
  }
}
