import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/user_search_controller.dart';

class UserSearchBar extends ConsumerStatefulWidget {
  const UserSearchBar({super.key});

  @override
  ConsumerState<UserSearchBar> createState() => _UserSearchBarState();
}

class _UserSearchBarState extends ConsumerState<UserSearchBar> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(userSearchControllerProvider);

    final theme = Theme.of(context);

    return TextField(
      controller: _textController,
      onChanged: (value) {
        ref.read(userSearchControllerProvider.notifier).updateQuery(value);
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search people...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _textController.clear();

                  ref.read(userSearchControllerProvider.notifier).clear();
                },
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
