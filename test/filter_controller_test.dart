import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../lib/controllers/filter_controller.dart';
import '../lib/models/filters.dart';
import './fixtures/filter_controller_test_fixtures.dart';

void main() {
  late ProviderContainer container;

  setUp(() => {container = ProviderContainer()});

  onChangePropertyFixtures.asMap().forEach((index, fixture) {
    test(
      'ケース $index\n'
      'onChangeProperty()に${fixture.selectProperty}を与えたとき、\n'
      '  - selectedPropertyには${fixture.expectedProperty}がセットされる\n'
      '  - propertySelectorのerrorには"${fixture.expectedSelectedPropertyError}"がセットされる\n'
      '  - filterTypeには必ずFilterType.UNSPECIFIEDがセットされる\n'
      '  - filterTypeSelectorのselectableFilterTypesには${fixture.expectedFilterTypeSelector.selectableFilterType}がセットされる\n'
      '  - filterValueには必ずnullがセットされる',
      () {
        container.read(filterStateProvider).state = Filter(
          null,
          fixture.selectableProperties,
          null,
          FilterType.UNSPECIFIED,
          FilterTypeSelector([FilterType.UNSPECIFIED], null),
          null,
        );

        container
            .read(filterControllerProvider)
            .onChangeProperty(fixture.selectProperty);

        final actualFilter = container.read(filterStateProvider).state;
        expect(actualFilter.selectedProperty, fixture.expectedProperty);
        expect(
          actualFilter.selectableProperties,
          fixture.expectedSelectableProperties,
        );
        expect(
          actualFilter.selectedPropertyError,
          fixture.expectedSelectedPropertyError,
        );
        expect(actualFilter.filterType, FilterType.UNSPECIFIED);
        expect(
          actualFilter.filterTypeSelector,
          fixture.expectedFilterTypeSelector,
        );
        expect(actualFilter.filterValue, null);
      },
    );
  });
}
