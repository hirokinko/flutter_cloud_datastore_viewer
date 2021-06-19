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
          FilterType.UNSPECIFIED,
          FILTER_UNSELECTABLE,
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
          FilterType.UNSPECIFIED,
          AVAILABLE_ALL_FILTERS,
          null,
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
      '  - filterValueには${fixture.expectedFilterValue}がセットされる',
      () {
        container.read(filterStateProvider).state = Filter(
          fixture.property,
          selectableProps,
          FilterType.EQUALS,
          AVAILABLE_ALL_FILTERS,
          defaultEqualsFilterValue,
        );
        container
            .read(filterControllerProvider)
            .onChangeEqualsFilterValue(fixture.givenValue);

        final actualFilter = container.read(filterStateProvider).state;
        expect(actualFilter.filterValue, fixture.expectedFilterValue);
        expect(
          (actualFilter.filterValue as EqualsFilterValue).error,
          fixture.expectedError,
        );
      },
    );
  });

  onChangeRangeFilterValueFixtures.asMap().forEach((index, fixture) {
    test(
        'ケース $index\n'
        '${fixture.givenMinValue}から${fixture.givenMaxValue}までの${fixture.property}のクエリを作るとき、\n'
        '  - filterValueには${fixture.expectedFilterValue}がセットされる\n'
        '  - filterValue.maxValueError は ${fixture.expectedMaxValueError} を返す\n'
        '  - filterValue.minValueError は ${fixture.expectedMinValueError} を返す\n'
        '  - filterValue.formError は ${fixture.expectedFormError} を返す', () {
      container.read(filterStateProvider).state = Filter(
        fixture.property,
        selectableProps,
        FilterType.RANGE,
        AVAILABLE_ALL_FILTERS,
        defaultRangeFilterValue,
      );
      container.read(filterControllerProvider).onChangeRangeFilterValues(
            fixture.givenMaxValue,
            fixture.givenMinValue,
          );

      final actualFilter = container.read(filterStateProvider).state;
      expect(actualFilter.filterValue, fixture.expectedFilterValue);
      RangeFilterValue actualFilterValue =
          actualFilter.filterValue as RangeFilterValue;
      expect(actualFilterValue.maxValueError, fixture.expectedMaxValueError);
      expect(actualFilterValue.minValueError, fixture.expectedMinValueError);
      expect(actualFilterValue.formError, fixture.expectedFormError);
    });
  });

  test('clearボタンをsubmitしたとき、プロパティ、フィルタータイプ、値の入力をクリアする', () {
    container.read(filterStateProvider).state = Filter(
      Property('stringProperty', String),
      selectableProps,
      FilterType.RANGE,
      AVAILABLE_ALL_FILTERS,
      RangeFilterValue(String, 'ん', 'あ', false, false),
    );
    container.read(filterControllerProvider).onSubmitFilterClear();

    final actualFilter = container.read(filterStateProvider).state;
    expect(actualFilter.selectedProperty, null);
    expect(actualFilter.selectableProperties, selectableProps);
    expect(actualFilter.selectedPropertyError, "プロパティを選択してください");
    expect(actualFilter.filterType, FilterType.UNSPECIFIED);
    expect(actualFilter.selectableFilterTypes, FILTER_UNSELECTABLE);
    expect(actualFilter.selectedFilterTypeError, null);
    expect(actualFilter.filterValue, null);
  });

  group('getSuggestedProperties', () {
    for (final fixture in getSuggestedPropertiesFixtures) {
      test('${fixture.input}を入力した時、${fixture.expected}が返る', () {
        final filter = Filter(
          null,
          selectableProps,
          FilterType.UNSPECIFIED,
          FILTER_UNSELECTABLE,
          null,
        );
        expect(filter.getSuggestedProperties(fixture.input), fixture.expected);
      });
    }
  });
}
