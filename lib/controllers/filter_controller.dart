import 'package:meta/meta.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/filters.dart';

final filterStateProvider = StateProvider.autoDispose((ref) {
  return Filter(
    null,
    null,
    FilterType.UNSPECIFIED,
    FilterTypeSelector([FilterType.UNSPECIFIED], null),
  );
});
final filterControllerProvider =
    Provider.autoDispose((ref) => FilterController(ref.read));

@immutable
class FilterController {
  final Reader read;

  FilterController(this.read);

  void onChangeProperty(Property? prop) {
    late final Property? newProperty;
    late final List<FilterType> selectableFilterType;
    late final String? errorMessage;
    final current = this.read(filterStateProvider).state;

    if (prop == null) {
      newProperty = null;
      errorMessage = "プロパティを選択してください";
      selectableFilterType = [FilterType.UNSPECIFIED];
    } else if (current.propertySelector == null ||
        !current.propertySelector!.selectableProps.contains(prop)) {
      newProperty = null;
      errorMessage = "${prop.name}[${prop.type}]は存在しません";
      selectableFilterType = [FilterType.UNSPECIFIED];
    } else {
      newProperty = prop;
      errorMessage = null;
      selectableFilterType = prop.type == bool
          ? [FilterType.UNSPECIFIED, FilterType.EQUALS]
          : [FilterType.UNSPECIFIED, FilterType.EQUALS, FilterType.RANGE];
    }

    final newState = Filter(
      newProperty,
      PropertySelector(
        current.propertySelector?.selectableProps ?? [],
        errorMessage,
      ),
      FilterType.UNSPECIFIED,
      FilterTypeSelector(selectableFilterType, null),
    );

    this.read(filterStateProvider).state = newState;
  }
}
