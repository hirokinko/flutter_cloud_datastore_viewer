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
      '  - selectableFilterTypesには${fixture.expectedSelectableFilterTypes}がセットされる\n'
      '  - filterValueには必ずnullがセットされる',
      () {
        container.read(filterStateProvider).state = Filter(
          null,
          fixture.selectableProperties,
          null,
          FilterType.UNSPECIFIED,
          FILTER_UNSELECTABLE,
          null,
          null,
          {},
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
          actualFilter.selectableFilterTypes,
          fixture.expectedSelectableFilterTypes,
        );
        expect(actualFilter.filterValue, null);
      },
    );
  });

  onChangeFilterTypeFixtures.asMap().forEach((index, fixture) {
    test(
      'ケース $index\n'
      'onChangeFilterType()に${fixture.selectedFilterType}を与えたとき、\n'
      '  - filterTypeには${fixture.expectedFilterType}がセットされる\n'
      '  - selectedFilterTypeErrorには${fixture.expectedErrorMessage}がセットされる\n'
      '  - filterValueには${fixture.expectedFilterValue}がセットされる',
      () {
        container.read(filterStateProvider).state = Filter(
          Property('stringProperty', String),
          selectableProps,
          null,
          FilterType.UNSPECIFIED,
          AVAILABLE_ALL_FILTERS,
          null,
          null,
          {},
        );
        container
            .read(filterControllerProvider)
            .onChangeFilterType(fixture.selectedFilterType);

        final actualFilter = container.read(filterStateProvider).state;
        expect(actualFilter.filterType, fixture.expectedFilterType);
        expect(
          actualFilter.selectedFilterTypeError,
          fixture.expectedErrorMessage,
        );
        expect(actualFilter.filterValue, fixture.expectedFilterValue);
      },
    );
  });

  onChangeEqualsFilterValueFixtures.asMap().forEach((index, fixture) {
    test(
      'ケース $index\n'
      '${fixture.property}に${fixture.givenValue}を与えたとき、\n'
      '  - filterValueには${fixture.expectedFilterValue}がセットされる\n'
      '  - filterValueErrorsには${fixture.expectedFilterValueErrors}がセットされる',
      () {
        container.read(filterStateProvider).state = Filter(
          fixture.property,
          selectableProps,
          null,
          FilterType.EQUALS,
          AVAILABLE_ALL_FILTERS,
          null,
          EqualsFilterValue(null),
          {},
        );
        container
            .read(filterControllerProvider)
            .onChangeEqualsFilterValue(fixture.givenValue);

        final actualFilter = container.read(filterStateProvider).state;
        expect(actualFilter.filterValue, fixture.expectedFilterValue);
        expect(
          actualFilter.filterValueErrors,
          fixture.expectedFilterValueErrors,
        );
      },
    );
  });

  onChangeRangeFilterValueFixtures.asMap().forEach((index, fixture) {
    test(
        'ケース $index\n'
        '${fixture.givenMinValue}から${fixture.givenMaxValue}までの${fixture.property}のクエリを作るとき、\n'
        '  - filterValueには${fixture.expectedFilterValue}がセットされる'
        '  - filterValueErrorsには${fixture.expectedFilterValueErrors}がセットされる',
        () {
      container.read(filterStateProvider).state = Filter(
        fixture.property,
        selectableProps,
        null,
        FilterType.RANGE,
        AVAILABLE_ALL_FILTERS,
        null,
        RangeFilterValue(null, null),
        {},
      );
      container.read(filterControllerProvider).onChangeRangeFilterValues(
            fixture.givenMaxValue,
            fixture.givenMinValue,
          );

      final actualFilter = container.read(filterStateProvider).state;
      expect(actualFilter.filterValue, fixture.expectedFilterValue);
      expect(actualFilter.filterValueErrors, fixture.expectedFilterValueErrors);
    });
  });
}
