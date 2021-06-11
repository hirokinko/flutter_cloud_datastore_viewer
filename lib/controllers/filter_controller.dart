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
    );
  }
}
