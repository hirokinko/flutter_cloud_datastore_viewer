import 'package:meta/meta.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/filters.dart';

final filterStateProvider = StateProvider.autoDispose((ref) {
  return Filter(
    null,
    [],
    null,
    FilterType.UNSPECIFIED,
    FilterTypeSelector([FilterType.UNSPECIFIED], null),
    null,
  );
});
final filterControllerProvider =
    Provider.autoDispose((ref) => FilterController(ref.read));
const _FILTER_UNSELECTABLE = [FilterType.UNSPECIFIED];
const _EQUALS_FILTER_ONLY = [FilterType.UNSPECIFIED, FilterType.EQUALS];
const _WITH_RANGE_FILTER = [
  FilterType.UNSPECIFIED,
  FilterType.EQUALS,
  FilterType.RANGE,
];

@immutable
class FilterController {
  final Reader read;

  FilterController(this.read);

  void onChangeProperty(Property? prop) {
    late final Filter newFilter;
    final current = this.read(filterStateProvider).state;

    String? errorMessage = current.validateSelectedProperty(prop);
    if (errorMessage == null) {
      newFilter = Filter(
        prop,
        current.selectableProperties,
        errorMessage,
        FilterType.UNSPECIFIED,
        FilterTypeSelector(
          prop!.type == bool ? _EQUALS_FILTER_ONLY : _WITH_RANGE_FILTER,
          null,
        ),
        null,
      );
    } else {
      newFilter = Filter(
        null,
        current.selectableProperties,
        errorMessage,
        FilterType.UNSPECIFIED,
        FilterTypeSelector(_FILTER_UNSELECTABLE, null),
        null,
      );
    }
    this.read(filterStateProvider).state = newFilter;
  }
}
