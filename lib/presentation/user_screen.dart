import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_directory/presentation/profile/profile_screen.dart';
import 'package:user_directory/presentation/user_search_controller.dart';
import 'package:user_directory/provider/api_provider.dart';
import 'package:user_directory/shared/empty_view.dart';
import 'package:user_directory/shared/error_view.dart';
import 'package:user_directory/shared/skeleton_user_card.dart';
import 'package:user_directory/shared/user_search_bar.dart';

import '../../data/models/user.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(userControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('People'), centerTitle: false),
      body: usersState.when(
        loading: () => const _UsersLoadingView(),
        error: (error, stackTrace) {
          return ErrorView(
            message: error.toString(),
            onRetry: () {
              ref.read(userControllerProvider.notifier).retry();
            },
          );
        },
        data: (users) {
          if (users.isEmpty) {
            return const EmptyView(
              title: 'No users found',
              message: 'There are currently no users to display.',
            );
          }

          return _UsersList(users: users);
        },
      ),
    );
  }
}

class _UsersList extends ConsumerWidget {
  const _UsersList({required this.users});

  final List<User> users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(userSearchControllerProvider);

    final normalizedQuery = searchQuery.trim().toLowerCase();

    final filteredUsers = normalizedQuery.isEmpty
        ? users
        : users.where((user) {
            final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();

            final username = user.username.toLowerCase();

            final email = user.email.toLowerCase();

            return fullName.contains(normalizedQuery) ||
                username.contains(normalizedQuery) ||
                email.contains(normalizedQuery);
          }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        try {
          await ref.read(userControllerProvider.notifier).refresh();
        } catch (_) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not refresh users. Please try again.'),
            ),
          );
        }
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverToBoxAdapter(
              child: _UsersHeader(userCount: filteredUsers.length),
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 20),
            sliver: SliverToBoxAdapter(child: UserSearchBar()),
          ),

          if (filteredUsers.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyView(
                title: 'No users found',
                message:
                    'No users match "$searchQuery". Try another name, username, or email.',
                icon: Icons.search_off_rounded,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: filteredUsers.length,
                separatorBuilder: (_, _) {
                  return const SizedBox(height: 12);
                },
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];

                  return _UserCard(
                    user: user,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) {
                            return ProfileScreen(userId: user.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _UsersHeader extends StatelessWidget {
  const _UsersHeader({required this.userCount});

  final int userCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover People',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$userCount people available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Hero(
                tag: 'user-avatar-${user.id}',
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(user.image),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersLoadingView extends StatelessWidget {
  const _UsersLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      separatorBuilder: (_, _) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (_, _) {
        return const SkeletonUserCard();
      },
    );
  }
}
