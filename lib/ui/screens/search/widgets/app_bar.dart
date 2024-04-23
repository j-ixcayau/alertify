import 'dart:async';

import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    required this.onSearch,
    this.controller,
  });

  final TextEditingController? controller;
  final void Function(String query) onSearch;

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  Timer? _timer;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    _timer?.cancel();
    _timer = Timer(
      const Duration(milliseconds: 500),
      () {
        widget.onSearch(query.trim());
      },
    );
  }

  void _cancelSearch() {
    _controller.clear();
    _timer?.cancel();
    widget.onSearch('');
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: _controller,
        onChanged: (query) => _handleSearch(query.toLowerCase().trim()),
        decoration: InputDecoration(
          hintText: 'Search ...',
          fillColor: Colors.transparent,
          suffixIcon: IconButton(
            onPressed: _cancelSearch,
            icon: const Icon(Icons.cancel),
          ),
        ),
      ),
    );
  }
}
