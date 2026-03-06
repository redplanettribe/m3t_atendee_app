import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_attendee/app/routes.dart';
import 'package:m3t_attendee/core/app_config.dart';
import 'package:m3t_attendee/features/home/bloc/bloc.dart';
import 'package:m3t_attendee/features/user/view/user_avatar_button.dart';
import 'package:m3t_attendee/features/user/view/user_view_helpers.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = HomeCubit(
          attendeeRepository: context.read<AttendeeRepository>(),
        );
        unawaited(cubit.loadRegisteredEvents());
        return cubit;
      },
      child: const _HomeView(),
    );
  }
}

final class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: UserAvatarButton(),
        ),
        title: const Text('m3t Attendee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Register for event',
            onPressed: () => context.push(AppRoutes.registerForEvent),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.loading && state.events.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && state.events.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context
                          .read<HomeCubit>()
                          .loadRegisteredEvents(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state.events.isEmpty) {
            return Center(
              child: Text(
                'You are not registered for any events yet.',
                style: textTheme.bodyLarge,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                context.read<HomeCubit>().loadRegisteredEvents(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                final thumbnailUrl = event.thumbnailUrl != null &&
                        event.thumbnailUrl!.isNotEmpty
                    ? (event.thumbnailUrl!.startsWith('/')
                        ? '${AppConfig.baseUrl}${event.thumbnailUrl}'
                        : event.thumbnailUrl!)
                    : null;
                final resolvedThumbnailUrl = thumbnailUrl.platformResolved;
                final metaParts = <String>[
                  if (event.eventCode != null &&
                      event.eventCode!.isNotEmpty)
                    'Code: ${event.eventCode}',
                  if (event.startDate != null && event.startDate!.isNotEmpty)
                    event.startDate!,
                ];
                const thumbSize = 96.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: thumbSize,
                          height: thumbSize,
                          child: resolvedThumbnailUrl != null &&
                                  resolvedThumbnailUrl.isNotEmpty
                              ? Image.network(
                                  resolvedThumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _thumbnailPlaceholder(context),
                                )
                              : _thumbnailPlaceholder(context),
                        ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    event.name,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (event.description != null &&
                                      event.description!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      event.description!,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (metaParts.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      metaParts.join(' · '),
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
              },
            ),
          );
        },
      ),
    );
  }
}

Widget _thumbnailPlaceholder(BuildContext context) {
  return ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.event,
      size: 40,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
