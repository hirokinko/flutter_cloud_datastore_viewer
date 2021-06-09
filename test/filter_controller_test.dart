import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../lib/controllers/filter_controller.dart';
import '../lib/models/filters.dart';
import './fixtures/filter_controller_test_fixtures.dart';

void main() {
  late ProviderContainer container;

  setUp(() => {container = ProviderContainer()});

  for (final fixture in onChangePropertyFixtures) {
    test(
      'onChangeProperty()に${fixture.selectProperty}を与えたとき、\n'
      '  - selectedPropertyには${fixture.expectedProperty}がセットされる\n'
      '  - propertySelectorのerrorには"${fixture.expectedPropertySelector.error}"がセットされる\n'
      '  - filterTypeには必ずFilterType.UNSPECIFIEDがセットされる\n'
      '  - filterTypeSelectorのselectableFilterTypesには${fixture.expectedFilterTypeSelector.selectableFilterType}がセットされる',
      () {
        container.read(filterStateProvider).state = Filter(
          null,
          fixture.propertySelector,
          FilterType.UNSPECIFIED,
          FilterTypeSelector([FilterType.UNSPECIFIED], null),
        );

        container
            .read(filterControllerProvider)
            .onChangeProperty(fixture.selectProperty);

        final actualFilter = container.read(filterStateProvider).state;
        expect(actualFilter.selectedProperty, fixture.expectedProperty);
        expect(actualFilter.propertySelector, fixture.expectedPropertySelector);
        expect(actualFilter.filterType, FilterType.UNSPECIFIED);
        expect(
          actualFilter.filterTypeSelector,
          fixture.expectedFilterTypeSelector,
        );
      },
    );
  }
}
