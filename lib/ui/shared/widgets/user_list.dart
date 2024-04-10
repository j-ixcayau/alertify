import 'package:flutter/material.dart';

import 'package:alertify/core/typedefs.dart';
import 'package:alertify/ui/shared/theme/palette.dart';

class UserList<T> extends StatelessWidget {
  const UserList({
    super.key,
    required this.data,
    required this.builder,
  });
  final List<T> data;
  final UserListItemBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) => builder(context, data[index]),
      separatorBuilder: (_, __) => const Divider(
        color: Palette.darkGray,
        height: 1,
      ),
      itemCount: data.length,
    );
  }
}
