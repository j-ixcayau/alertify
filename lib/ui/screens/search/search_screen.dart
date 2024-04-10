import 'package:flutter/material.dart';

import 'package:alertify/ui/shared/widgets/user_list.dart';
import 'package:alertify/ui/shared/widgets/user_tile.dart';
import 'package:alertify/ui/screens/search/widgets/app_bar.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  static const String route = '/search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(onSearch: (_) {}),
      body: UserList(
        data: const [1, 2, 3, 4, 5, 6, 7],
        builder: (_, data) => UserTile(
          onPressed: () {},
          username: 'username',
          email: 'email',
        ),
      ),
    );
  }
}
