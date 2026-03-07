import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:m3t_attendee/app/routes.dart';
import 'package:m3t_attendee/features/registered_events/cubit/registered_events_cubit.dart';
import 'package:m3t_attendee/features/registered_events/view/registered_event_view_helpers.dart';
import 'package:m3t_attendee/features/user/view/user_avatar_button.dart';

abstract final class _HomeViewTokens {
  static const leadingPadding = 16.0;
  static const contentPadding = 16.0;
  static const sectionSpacing = 16.0;
  static const itemSpacing = 12.0;
  static const heroSpacing = 20.0;
  static const actionSpacing = 12.0;
  static const cardPadding = 16.0;
  static const cardImageHeight = 220.0;
  static const cardBorderRadius = 24.0;
  static const cardDescriptionMaxLines = 5;
  static const badgeHorizontalPadding = 12.0;
  static const badgeVerticalPadding = 6.0;
  static const inlineBannerSpacing = 12.0;
  static const progressHeight = 2.0;
  static const emptyIconSize = 56.0;
  static const artworkIconSize = 56.0;
}

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static RegisteredEventsTab? _registeredEventsTabSelector(
    RegisteredEventsCubit cubit,
  ) => _recommendedMyEventsTab(cubit.state);

  @override
  Widget build(BuildContext context) {
    final myEventsInitialTab = context.select(_registeredEventsTabSelector);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: .only(left: _HomeViewTokens.leadingPadding),
          child: UserAvatarButton(),
        ),
        title: const Text('m3t Attendee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'My events',
            onPressed: () => context.push(
              AppRoutes.myEvents,
              extra: myEventsInitialTab,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Register for event',
            onPressed: () => context.push(AppRoutes.registerForEvent),
          ),
        ],
      ),
      body: BlocBuilder<RegisteredEventsCubit, RegisteredEventsState>(
        builder: (context, state) {
          if (state.status == .loading && state.timeline.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && state.timeline.isEmpty) {
            return _HomeFailureView(message: state.errorMessage!);
          }
          return RefreshIndicator.adaptive(
            onRefresh: context.read<RegisteredEventsCubit>().refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      if (state.status == .refreshing)
                        const LinearProgressIndicator(
                          minHeight: _HomeViewTokens.progressHeight,
                        ),
                      if (state.status == .failure &&
                          state.errorMessage != null)
                        _HomeInlineFailureBanner(message: state.errorMessage!),
                      Padding(
                        padding: const .all(_HomeViewTokens.contentPadding),
                        child: _HomeContent(state: state),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

RegisteredEventsTab? _recommendedMyEventsTab(RegisteredEventsState state) {
  if (state.upcomingEvents.isNotEmpty) return .upcoming;
  if (state.currentEvents.isEmpty && state.pastEvents.isNotEmpty) return .past;
  return null;
}

final class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final RegisteredEventsState state;

  @override
  Widget build(BuildContext context) {
    final currentEvent = state.primaryCurrentEvent;
    final nextUpcomingEvent = state.nextUpcomingEvent;

    if (currentEvent != null) {
      return _CurrentEventContent(
        event: currentEvent,
        additionalCurrentEventsCount: state.additionalCurrentEventsCount,
        hasUpcomingEvents: state.upcomingEvents.isNotEmpty,
      );
    }

    if (nextUpcomingEvent != null) {
      return _NextEventContent(event: nextUpcomingEvent);
    }

    if (state.pastEvents.isNotEmpty) {
      return const _PastOnlyContent();
    }

    return const _NoEventsContent();
  }
}

final class _CurrentEventContent extends StatelessWidget {
  const _CurrentEventContent({
    required this.event,
    required this.additionalCurrentEventsCount,
    required this.hasUpcomingEvents,
  });

  final RegisteredEventEntity event;
  final int additionalCurrentEventsCount;
  final bool hasUpcomingEvents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text('Happening now', style: textTheme.headlineSmall),
        const SizedBox(height: _HomeViewTokens.itemSpacing),
        Text(
          'Focus on your active event first. '
          'Browse the rest only when you need to.',
          style: textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: _HomeViewTokens.heroSpacing),
        _HomeHeroCard(
          event: event,
          badgeLabel: 'Active now',
          supportingText: _buildCurrentSupportingText(),
          showDescription: true,
        ),
        const SizedBox(height: _HomeViewTokens.heroSpacing),
        Wrap(
          spacing: _HomeViewTokens.actionSpacing,
          runSpacing: _HomeViewTokens.actionSpacing,
          children: [
            if (hasUpcomingEvents)
              FilledButton.icon(
                onPressed: () => context.push(
                  AppRoutes.myEvents,
                  extra: RegisteredEventsTab.upcoming,
                ),
                icon: const Icon(Icons.upcoming),
                label: const Text('View upcoming events'),
              )
            else
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.myEvents),
                icon: const Icon(Icons.calendar_month),
                label: const Text('Open all my events'),
              ),
            if (additionalCurrentEventsCount > 0)
              OutlinedButton.icon(
                onPressed: () => context.push(
                  AppRoutes.myEvents,
                  extra: RegisteredEventsTab.current,
                ),
                icon: const Icon(Icons.event_available),
                label: Text(
                  'See $additionalCurrentEventsCount more active '
                  '${additionalCurrentEventsCount == 1 ? 'event' : 'events'}',
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.myEvents),
                icon: const Icon(Icons.calendar_month),
                label: const Text('Open all my events'),
              ),
          ],
        ),
      ],
    );
  }

  String _buildCurrentSupportingText() {
    if (additionalCurrentEventsCount <= 0) {
      return 'This is your current active event.';
    }

    return 'You also have $additionalCurrentEventsCount other '
        '${additionalCurrentEventsCount == 1 ? 'active event' : ''
                  'active events'}.';
  }
}

final class _NextEventContent extends StatelessWidget {
  const _NextEventContent({required this.event});

  final RegisteredEventEntity event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text('Next event', style: textTheme.headlineSmall),
        const SizedBox(height: _HomeViewTokens.itemSpacing),
        Text(
          'This is the next event on your schedule.',
          style: textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: _HomeViewTokens.heroSpacing),
        _HomeHeroCard(
          event: event,
          badgeLabel: 'Upcoming',
          supportingText: 'Be ready before it starts.',
          showDescription: true,
        ),
        const SizedBox(height: _HomeViewTokens.heroSpacing),
      ],
    );
  }
}

final class _PastOnlyContent extends StatelessWidget {
  const _PastOnlyContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      mainAxisSize: .min,
      children: [
        Icon(
          Icons.history,
          size: _HomeViewTokens.emptyIconSize,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: _HomeViewTokens.sectionSpacing),
        Text(
          'No active or upcoming events',
          textAlign: .center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: _HomeViewTokens.itemSpacing),
        Text(
          'Your upcoming schedule is clear. You can review your past events '
          'or register for a new one.',
          textAlign: .center,
          style: textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: _HomeViewTokens.heroSpacing),
        Wrap(
          alignment: .center,
          spacing: _HomeViewTokens.actionSpacing,
          runSpacing: _HomeViewTokens.actionSpacing,
          children: [
            FilledButton.icon(
              onPressed: () => context.push(
                AppRoutes.myEvents,
                extra: RegisteredEventsTab.past,
              ),
              icon: const Icon(Icons.history),
              label: const Text('View past events'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.registerForEvent),
              icon: const Icon(Icons.add),
              label: const Text('Register for event'),
            ),
          ],
        ),
      ],
    );
  }
}

final class _NoEventsContent extends StatelessWidget {
  const _NoEventsContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      mainAxisSize: .min,
      children: [
        Icon(
          Icons.event_available,
          size: _HomeViewTokens.emptyIconSize,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: _HomeViewTokens.sectionSpacing),
        Text(
          'You are not registered for any events yet.',
          textAlign: .center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: _HomeViewTokens.itemSpacing),
        Text(
          'Register for an event to see it here as your next focus item.',
          textAlign: .center,
          style: textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: _HomeViewTokens.heroSpacing),
        FilledButton.icon(
          onPressed: () => context.push(AppRoutes.registerForEvent),
          icon: const Icon(Icons.add),
          label: const Text('Register for event'),
        ),
      ],
    );
  }
}

final class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard({
    required this.event,
    required this.badgeLabel,
    required this.supportingText,
    required this.showDescription,
  });

  final RegisteredEventEntity event;
  final String badgeLabel;
  final String supportingText;
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final resolvedThumbnailUrl = event.resolvedThumbnailUrl;

    return Card(
      clipBehavior: .antiAlias,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          SizedBox(
            height: _HomeViewTokens.cardImageHeight,
            child:
                resolvedThumbnailUrl != null && resolvedThumbnailUrl.isNotEmpty
                ? Image.network(
                    resolvedThumbnailUrl,
                    fit: .cover,
                    errorBuilder: (_, _, _) => _heroArtworkPlaceholder(context),
                  )
                : _heroArtworkPlaceholder(context),
          ),
          Padding(
            padding: const .all(_HomeViewTokens.cardPadding),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: .circular(
                      _HomeViewTokens.cardBorderRadius,
                    ),
                  ),
                  child: Padding(
                    padding: const .symmetric(
                      horizontal: _HomeViewTokens.badgeHorizontalPadding,
                      vertical: _HomeViewTokens.badgeVerticalPadding,
                    ),
                    child: Text(
                      badgeLabel,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: .w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: _HomeViewTokens.sectionSpacing),
                Text(
                  event.name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: .w700,
                  ),
                ),
                const SizedBox(height: _HomeViewTokens.itemSpacing),
                Text(
                  supportingText,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                ..._buildMeta(theme),
                if (showDescription &&
                    event.description != null &&
                    event.description!.isNotEmpty) ...[
                  const SizedBox(height: _HomeViewTokens.sectionSpacing),
                  Text(
                    event.description!,
                    style: textTheme.bodyMedium,
                    maxLines: _HomeViewTokens.cardDescriptionMaxLines,
                    overflow: .ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMeta(ThemeData theme) {
    final metaParts = <String>[
      DateFormat.yMMMd().format(event.startDate),
      if (event.eventCode != null && event.eventCode!.isNotEmpty)
        'Code: ${event.eventCode}',
    ];

    if (metaParts.isEmpty) return const [];

    return [
      const SizedBox(height: _HomeViewTokens.sectionSpacing),
      Text(
        metaParts.join(' · '),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ];
  }
}

final class _HomeFailureView extends StatelessWidget {
  const _HomeFailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final registeredEventsCubit = context.read<RegisteredEventsCubit>();

    return Center(
      child: Padding(
        padding: const .all(_HomeViewTokens.contentPadding),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              message,
              textAlign: .center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: _HomeViewTokens.sectionSpacing),
            FilledButton.icon(
              onPressed: registeredEventsCubit.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

final class _HomeInlineFailureBanner extends StatelessWidget {
  const _HomeInlineFailureBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final registeredEventsCubit = context.read<RegisteredEventsCubit>();

    return Material(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const .symmetric(
          horizontal: _HomeViewTokens.contentPadding,
          vertical: _HomeViewTokens.inlineBannerSpacing,
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: _HomeViewTokens.inlineBannerSpacing),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: registeredEventsCubit.refresh,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onErrorContainer,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _heroArtworkPlaceholder(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return ColoredBox(
    color: colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.event,
      size: _HomeViewTokens.artworkIconSize,
      color: colorScheme.onSurfaceVariant,
    ),
  );
}
