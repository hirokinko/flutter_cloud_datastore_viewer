import 'package:flutter_cloud_datastore_viewer/models/filter.dart';
import 'package:flutter_cloud_datastore_viewer/controllers/filter_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'filter_controller_test_fixtures.dart';

void main() {
  late ProviderContainer container;

  setUp(() => {container = ProviderContainer()});

  for (final values in onChangePropertyFixtures) {
    test(
      'give ${values.fixtureTitle} to onChangeProperty() '
      'then shouled be update '
      'selectedProperty of state is ${values.expectedProperty?.name} '
      'and opSelector is ${values.operatorSelector}',
      () {
        expect(
          container.read(filterStateProvider).state.selectedProperty,
          null,
        );
        container.read(filterControllerProvider).onChangeProperty(
              values.selectProperty,
            );

        final actualState = container.read(filterStateProvider).state;
        expect(actualState.selectedProperty, values.expectedProperty);
        expect(actualState.op, Operator.UNSPECIFIED);
        expect(actualState.value, null);
        expect(actualState.opSelector, values.operatorSelector);
        expect(actualState.toPropertyFilter(), null);
      },
    );
  }

  for (final values in onChangeOperatorFixtures) {
    test(
      'select ${values.selectProperty?.name} property and '
      'give ${values.fixtureTitle} to onChangeOperator() '
      'then should be update '
      'selectedOperator of state is ${values.expectedOperator.value}',
      () {
        container.read(filterControllerProvider).onChangeProperty(
              values.selectProperty,
            );

        expect(
          container.read(filterStateProvider).state.op,
          Operator.UNSPECIFIED,
        );

        container.read(filterControllerProvider).onChangeOperator(
              values.selectOperator,
            );

        final actualState = container.read(filterStateProvider).state;
        expect(actualState.op, values.expectedOperator);
        expect(actualState.value, null);
        expect(actualState.toPropertyFilter(), null);
      },
    );
  }

  for (final values in onSubmitFixtures) {
    test(
      'onSubmit()',
      () {
        container.read(filterControllerProvider).onChangeProperty(
              values.selectProperty,
            );
        container.read(filterControllerProvider).onChangeOperator(
              values.selectOperator,
            );
        container.read(filterControllerProvider).onSubmit(values.submitValue);

        final actualState = container.read(filterStateProvider).state;
        expect(
          actualState.toPropertyFilter()!.toJson().toString(),
          values.expectPropertyFilter,
        );
      },
    );
  }

  for (final values in onSubmitErrorFixtures) {
    test(values.fixtureTitle, () {
      container.read(filterControllerProvider).onChangeProperty(
            values.selectProperty,
          );
      container.read(filterControllerProvider).onChangeOperator(
            values.selectOperator,
          );

      expect(
        () {
          try {
            container.read(filterControllerProvider).onSubmit(
                  values.submitValue,
                );
          } catch (e) {
            throw e;
          }
        },
        throwsException,
      );
    });
  }

  test(
    'execute onResetFilter() then reset filter state',
    () {
      container.read(filterControllerProvider).onResetFilter();
      final actualState = container.read(filterStateProvider).state;
      expect(actualState.selectedProperty, null);
      expect(actualState.op, Operator.UNSPECIFIED);
      expect(actualState.value, null);
      expect(actualState.toPropertyFilter(), null);
    },
  );
}
