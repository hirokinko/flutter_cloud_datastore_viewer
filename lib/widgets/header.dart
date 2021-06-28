import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/entities_controller.dart';
import '../models/connection.dart';

class Header extends HookWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final metadata = useProvider(metadataStateProvider).state;
    final currentShowing = useProvider(currentShowingStateProvider).state;
    return AppBar(
      title: Row(
        children: [
          Expanded(child: Text('Flutter CloudDatastore Viewer')),
          Expanded(
              child: Column(
            children: [
              createNamespaceSelector(
                context,
                metadata.namespaces,
                currentShowing.namespace,
              )
            ],
          )),
          Expanded(
              child: Column(
            children: [
              createKindSelector(
                context,
                metadata.kinds,
                currentShowing.kind,
              )
            ],
          )),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

Widget createNamespaceSelector(
  BuildContext context,
  List<String?> namespaces,
  String? currentShowingNamespace,
) {
  // Autocompleteのほうが良いかも
  return DropdownButtonFormField<String?>(
    decoration: InputDecoration(
      hintText: "名前空間を選択してください",
      labelText: "名前空間",
    ),
    items: namespaces
        .map(
          (namespace) => DropdownMenuItem<String?>(
            child: Text(
              namespace ?? '(default)',
            ),
            value: namespace,
          ),
        )
        .toList(growable: false),
    value: currentShowingNamespace,
    onChanged: (value) async {
      await context
          .read(entitiesControllerProvider)
          .onChangeCurrentShowingNamespace(value);
    },
  );
}

Widget createKindSelector(
  BuildContext context,
  List<String> kinds,
  String? currentShowingKind,
) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      hintText: "種類を選択してください",
      labelText: "種類",
    ),
    items: kinds
        .map((String kind) => DropdownMenuItem<String>(
              child: Text(kind),
              value: kind,
            ))
        .toList(growable: false),
    value: currentShowingKind,
    onChanged: (value) async {
      if (value == null) return;
      context
          .read(entitiesControllerProvider)
          .onChangeCurrentShowingKind(value);
    },
  );
}
