import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_directory/provider/api_provider.dart';
import 'package:user_directory/shared/error_view.dart';

import '../../data/models/user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileState.when(
        loading: () {
          return const _ProfileSkeleton();
        },
        error: (error, stackTrace) {
          return ErrorView(
            message: error.toString(),
            onRetry: () {
              ref.read(profileControllerProvider(userId).notifier).retry();
            },
          );
        },
        data: (user) {
          return _ProfileContent(user: user);
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        children: [
          _ProfileHeader(user: user),

          const SizedBox(height: 28),

          _InfoSection(
            title: 'Personal Information',
            children: [
              _InfoTile(
                icon: Icons.person_outline_rounded,
                label: 'Username',
                value: '@${user.username}',
              ),
              _InfoTile(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: '${user.age} years',
              ),
              _InfoTile(
                icon: Icons.badge_outlined,
                label: 'Gender',
                value: _capitalize(user.gender),
              ),
              if (user.maidenName.isNotEmpty)
                _InfoTile(
                  icon: Icons.person_outline,
                  label: 'Maiden name',
                  value: user.maidenName,
                ),
            ],
          ),

          const SizedBox(height: 16),

          _InfoSection(
            title: 'Contact Information',
            children: [
              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              _InfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phone,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Hero(
          tag: 'user-avatar-${user.id}',
          child: CircleAvatar(
            radius: 58,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage: NetworkImage(user.image),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          '${user.firstName} ${user.lastName}',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '@${user.username}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 21,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget box({
      required double width,
      required double height,
      double radius = 8,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
          ),

          const SizedBox(height: 18),

          box(width: 180, height: 24),

          const SizedBox(height: 10),

          box(width: 100, height: 16),

          const SizedBox(height: 32),

          box(width: double.infinity, height: 220, radius: 20),

          const SizedBox(height: 16),

          box(width: double.infinity, height: 160, radius: 20),
        ],
      ),
    );
  }
}
