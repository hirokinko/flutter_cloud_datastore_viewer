import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../controllers/filter_controller.dart';
import '../models/filters.dart';

class FilterFormWidget extends HookWidget {
  // FilterFormWidget({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('run build');
    final currentState = useProvider(filterStateProvider).state;
    print(currentState.selectedProperty);
    print(currentState.filterType);
    print(currentState.filterValue);
    final equalsFilterValueTextEditingController =
        useTextEditingController(text: ''); // TODO: initial value
    final rangeFilterMaxValueTextEditingController =
        useTextEditingController(text: ''); // TODO: initialvalue
    final rangeFilterMinValueTextEditingController =
        useTextEditingController(text: ''); // TODO: initialvalue

    return Center(
      child: Card(
        child: Form(
          child: Column(
            children: [
              createPropertyAutoCompleteField(context, currentState),
              createFilterTypeDropdownButton(context, currentState),
              createValueFilterForm(
                context,
                currentState,
                [
                  equalsFilterValueTextEditingController,
                  rangeFilterMaxValueTextEditingController,
                  rangeFilterMinValueTextEditingController,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final createPropertyAutoCompleteField = (
  BuildContext context,
  Filter state,
) =>
    Autocomplete<Property>(
      displayStringForOption: (Property option) => option.toString(),
      optionsBuilder: (TextEditingValue textEditingValue) {
        return state.getSuggestedProperties(textEditingValue.text);
      },
      onSelected: (Property? property) {
        context.read(filterControllerProvider).onChangeProperty(property);
      },
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: "絞り込むプロパティを選択してください",
            labelText: "プロパティ*",
            errorText: state.selectedPropertyError,
          ),
          onFieldSubmitted: (String value) {
            final properties = state.getSuggestedProperties(value);
            final selected = (properties.length == 1) ? properties[0] : null;
            context.read(filterControllerProvider).onChangeProperty(selected);
            if (selected != null) {
              textEditingController.text = properties[0].toString();
            }
          },
        );
      },
    );

final createFilterTypeDropdownButton = (
  BuildContext context,
  Filter filter,
) =>
    DropdownButtonFormField<FilterType>(
      value: filter.filterType,
      items: filter.selectableFilterTypes
          .map(
            (FilterType filterType) => DropdownMenuItem(
              value: filterType,
              child: Text(filterType.toString()),
            ),
          )
          .toList(growable: false),
      decoration: InputDecoration(
        hintText: "フィルタータイプを選択してください",
        labelText: "フィルタータイプ*",
        errorText: filter.selectedFilterTypeError,
      ),
      onChanged: (FilterType? filterType) {
        context
            .read(filterControllerProvider)
            .onChangeFilterType(filterType ?? FilterType.UNSPECIFIED);
      },
    );

final createValueFilterForm = (
  BuildContext context,
  Filter filter,
  List<TextEditingController> textEditingControllers,
) {
  switch (filter.filterType) {
    case FilterType.EQUALS:
      return (filter.selectedProperty?.type == bool)
          ? createBooleanValueDropdownButton(context, filter)
          : createEqualsFilterValueTextEditField(
              context,
              filter,
              textEditingControllers[0],
            );
    case FilterType.RANGE:
      return createRangeValueFilterForm(
        context,
        filter,
        textEditingControllers[1],
        textEditingControllers[2],
      );
    default:
      return createDummyTextEditField(
        context,
        filter,
        textEditingControllers[0],
      );
  }
};

final createBooleanValueDropdownButton = (
  BuildContext context,
  Filter filter,
) =>
    DropdownButtonFormField<String>(
      value: (filter.filterValue! as EqualsFilterValue).value ?? '',
      items: ['', 'true', 'false']
          .map((value) => DropdownMenuItem(child: Text(value), value: value))
          .toList(growable: false),
      decoration: InputDecoration(
        hintText: "値を入力してください",
        labelText: "値",
      ),
      onChanged: (value) {
        print('選択した値 $value');
        context.read(filterControllerProvider).onChangeEqualsFilterValue(value);
      },
    );

final createDummyTextEditField = (
  BuildContext context,
  Filter filter,
  TextEditingController textEditingController,
) =>
    TextFormField(
      enabled: false,
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: "値を入力してください",
        labelText: "値",
      ),
    );

Widget createEqualsFilterValueTextEditField(
  BuildContext context,
  Filter filter,
  TextEditingController textEditingController,
) {
  final filterValue = filter.filterValue as EqualsFilterValue;
  return TextFormField(
    controller: textEditingController,
    decoration: InputDecoration(
      hintText: "値を入力してください",
      labelText: "値",
      errorText: filterValue.error,
    ),
    onChanged: (value) {
      print('入力中の値 $value');
      context.read(filterControllerProvider).onChangeEqualsFilterValue(value);
    },
  );
}

final createRangeValueFilterForm = (
  BuildContext context,
  Filter filter,
  TextEditingController maxValueTextEditingController,
  TextEditingController minValueTextEditingController,
) {
  final filterValue = filter.filterValue as RangeFilterValue;
  return Column(
    children: [
      TextFormField(
        controller: maxValueTextEditingController,
        decoration: InputDecoration(
          hintText: "最大値を入力してください",
          labelText: "最大値",
        ),
        onChanged: (value) {
          print('入力中の最大値 $value');
          context.read(filterControllerProvider).onChangeRangeFilterValues(
              value, filterValue.minValue,
              containsMaxValue: filterValue.containsMaxValue,
              containsMinValue: filterValue.containsMinValue);
        },
      ),
      Checkbox(
        value: filterValue.containsMaxValue,
        onChanged: (bool? value) {
          print('最大値を含むか? $value');
          context.read(filterControllerProvider).onChangeRangeFilterValues(
                filterValue.maxValue,
                filterValue.minValue,
                containsMaxValue: value ?? false,
                containsMinValue: filterValue.containsMinValue,
              );
        },
      ),
      TextFormField(
        controller: minValueTextEditingController,
        decoration: InputDecoration(
          hintText: "最小値を入力してください",
          labelText: "最小値",
        ),
        onChanged: (value) {
          print('入力中の最小値 $value');
          context.read(filterControllerProvider).onChangeRangeFilterValues(
              filterValue.maxValue, value,
              containsMaxValue: filterValue.containsMaxValue,
              containsMinValue: filterValue.containsMinValue);
        },
      ),
      Checkbox(
        value: filterValue.containsMinValue,
        onChanged: (bool? value) {
          print('最小値を含むか? $value');
          context.read(filterControllerProvider).onChangeRangeFilterValues(
                filterValue.maxValue,
                filterValue.minValue,
                containsMaxValue: filterValue.containsMaxValue,
                containsMinValue: value ?? false,
              );
        },
      ),
    ],
  );
};
