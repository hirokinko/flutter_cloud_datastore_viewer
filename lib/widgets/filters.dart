import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/controllers/entities_controller.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../controllers/filter_controller.dart';
import '../models/filters.dart';

class FilterFormWidget extends HookWidget {
  // FilterFormWidget({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentState = useProvider(filterStateProvider).state;
    final equalsFilterValueTextEditingController =
        useTextEditingController(text: ''); // TODO: initial value
    final rangeFilterMaxValueTextEditingController =
        useTextEditingController(text: ''); // TODO: initialvalue
    final rangeFilterMinValueTextEditingController =
        useTextEditingController(text: ''); // TODO: initialvalue

    return SimpleDialog(
      title: Text('フィルターの設定'),
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
        createSubmitButton(context, currentState),
      ],
    );
  }
}

final createPropertyAutoCompleteField = (
  BuildContext context,
  Filter filter,
) =>
    ListTile(
      title: Autocomplete<Property>(
        displayStringForOption: (Property option) => option.toString(),
        optionsBuilder: (TextEditingValue textEditingValue) {
          return filter.getSuggestedProperties(textEditingValue.text);
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
              errorText: filter.selectedPropertyError,
            ),
            onFieldSubmitted: (String value) {
              final properties = filter.getSuggestedProperties(value);
              final selected = (properties.length == 1) ? properties[0] : null;
              context.read(filterControllerProvider).onChangeProperty(selected);
              if (selected != null) {
                textEditingController.text = properties[0].toString();
              }
            },
          );
        },
      ),
    );

final createFilterTypeDropdownButton = (
  BuildContext context,
  Filter filter,
) =>
    ListTile(
      title: DropdownButtonFormField<FilterType>(
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
      ),
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
      return createRangeFilterFormGroup(
        context,
        filter,
        textEditingControllers[1],
        textEditingControllers[2],
      );
    default:
      return SizedBox.shrink();
  }
};

final createBooleanValueDropdownButton = (
  BuildContext context,
  Filter filter,
) =>
    ListTile(
      title: DropdownButtonFormField<String>(
        value: (filter.filterValue! as EqualsFilterValue).value ?? '',
        items: ['', 'true', 'false']
            .map((value) => DropdownMenuItem(child: Text(value), value: value))
            .toList(growable: false),
        decoration: InputDecoration(
          hintText: "値を入力してください",
          labelText: "値",
          errorText: (filter.filterValue as EqualsFilterValue).error,
        ),
        onChanged: (value) {
          context
              .read(filterControllerProvider)
              .onChangeEqualsFilterValue(value);
        },
      ),
    );

final createDummyTextEditField = (
  BuildContext context,
  Filter filter,
  TextEditingController textEditingController,
) =>
    ListTile(
      title: TextFormField(
        enabled: false,
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: "値を入力してください",
          labelText: "値",
          errorText: (filter.filterType as EqualsFilterValue).error,
        ),
      ),
    );

Widget createEqualsFilterValueTextEditField(
  BuildContext context,
  Filter filter,
  TextEditingController textEditingController,
) {
  final filterValue = filter.filterValue as EqualsFilterValue;
  return ListTile(
    title: TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: "値を入力してください",
        labelText: "値",
        errorText: filterValue.error,
      ),
      onChanged: (value) {
        context.read(filterControllerProvider).onChangeEqualsFilterValue(value);
      },
    ),
  );
}

final createRangeFilterFormGroup = (
  BuildContext context,
  Filter filter,
  TextEditingController maxValueTextEditingController,
  TextEditingController minValueTextEditingController,
) {
  final filterValue = filter.filterValue as RangeFilterValue;
  return ListTile(
    title: Column(
      children: [
        createRangeFilterValueForm(
          context,
          '最大値',
          maxValueTextEditingController,
          filterValue,
        ),
        createRangeFilterValueForm(
          context,
          '最小値',
          minValueTextEditingController,
          filterValue,
        ),
      ],
    ),
  );
};

Widget createRangeFilterValueForm(
  BuildContext context,
  String label,
  TextEditingController controller,
  RangeFilterValue currentRangeFilterValue,
) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            flex: 7,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '$labelを入力してください',
                labelText: '$label',
                errorText: (label == '最大値')
                    ? currentRangeFilterValue.maxValueError
                    : currentRangeFilterValue.minValueError,
              ),
              onChanged: (String value) {
                context
                    .read(filterControllerProvider)
                    .onChangeRangeFilterValues(
                      label == '最大値' ? value : currentRangeFilterValue.maxValue,
                      label == '最小値' ? value : currentRangeFilterValue.minValue,
                      containsMaxValue:
                          currentRangeFilterValue.containsMaxValue,
                      containsMinValue:
                          currentRangeFilterValue.containsMinValue,
                    );
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: CheckboxListTile(
              title: Text('含む'),
              value: label == '最大値'
                  ? currentRangeFilterValue.containsMaxValue
                  : currentRangeFilterValue.containsMinValue,
              onChanged: (bool? value) {
                context
                    .read(filterControllerProvider)
                    .onChangeRangeFilterValues(
                      currentRangeFilterValue.maxValue,
                      currentRangeFilterValue.minValue,
                      containsMaxValue: label == '最大値'
                          ? value ?? false
                          : currentRangeFilterValue.containsMaxValue,
                      containsMinValue: label == '最小値'
                          ? value ?? false
                          : currentRangeFilterValue.containsMinValue,
                    );
              },
            ),
          )
        ],
      )
    ],
  );
}

Widget createSubmitButton(BuildContext context, Filter filter) {
  return ListTile(
    title: Column(
      children: [
        ElevatedButton(
          child: Text('絞り込む'),
          onPressed: filter.isValid
              ? () async {
                  await context
                      .read(entitiesControllerProvider)
                      .onLoadEntityList(null, null);
                  Navigator.pop(context);
                }
              : null,
        )
      ],
    ),
  );
}
