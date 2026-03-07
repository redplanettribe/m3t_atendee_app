import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:m3t_attendee/app/routes.dart';
import 'package:m3t_attendee/features/registered_events/cubit/registered_events_cubit.dart';
import 'package:m3t_attendee/features/registered_events/view/registered_event_view_helpers.dart';

abstract final class _RegisteredEventsViewTokens {
  static const cardContentPadding = 16.0;
  static const contentPadding = 24.0;
  static const listHorizontalPadding = 16.0;
  static const listVerticalPadding = 12.0;
  static const bannerSpacing = 12.0;
  static const sectionSpacing = 16.0;
  static const itemSpacing = 12.0;
  static const descriptionSpacing = 8.0;
  static const thumbnailSize = 96.0;
  static const emptyIconSize = 56.0;
  static const placeholderIconSize = 40.0;
  static const refreshIndicatorHeight = 2.0;
}

final class RegisteredEventsPage extends StatefulWidget {
  const RegisteredEventsPage({super.key, this.initialTab});

  final RegisteredEventsTab? initialTab;

  @override
  State<RegisteredEventsPage> createState() => _RegisteredEventsPageState();
}

final class _RegisteredEventsPageState extends State<RegisteredEventsPage>
    with SingleTickerProviderStateMixin {
  late final RegisteredEventsCubit _registeredEventsCubit;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _registeredEventsCubit = context.read<RegisteredEventsCubit>();
    final initialTab =
        widget.initialTab ?? _registeredEventsCubit.state.effectiveSelectedTab;
    _registeredEventsCubit.selectTab(initialTab);
    _tabController = TabController(
      length: RegisteredEventsTab.values.length,
      vsync: this,
      initialIndex: initialTab.index,
    )..addListener(_handleTabChanged);
  }

  @override
  void didUpdateWidget(covariant RegisteredEventsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextInitialTab = widget.initialTab;
    if (nextInitialTab == null || nextInitialTab == oldWidget.initialTab) {
      return;
    }

    _registeredEventsCubit.selectTab(nextInitialTab);
    if (_tabController.index != nextInitialTab.index) {
      _tabController.animateTo(nextInitialTab.index);
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;

    final selectedTab = RegisteredEventsTab.values[_tabController.index];
    if (_registeredEventsCubit.state.selectedTab == selectedTab) return;
    _registeredEventsCubit.selectTab(selectedTab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Register for event',
            onPressed: () => context.push(AppRoutes.registerForEvent),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Current'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: BlocBuilder<RegisteredEventsCubit, RegisteredEventsState>(
        builder: (context, state) {
          if (state.status == .loading && state.timeline.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.timeline.isEmpty) {
            return _FailureView(message: state.errorMessage!);
          }

          return Column(
            children: [
              if (state.status == .refreshing)
                const LinearProgressIndicator(
                  minHeight: _RegisteredEventsViewTokens.refreshIndicatorHeight,
                ),
              if (state.status == .failure && state.errorMessage != null)
                _InlineFailureBanner(message: state.errorMessage!),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _EventsTab(
                      events: state.currentEvents,
                      emptyMessage: 'You have no active registered events.',
                    ),
                    _EventsTab(
                      events: state.upcomingEvents,
                      emptyMessage: 'You have no upcoming registered events.',
                    ),
                    _EventsTab(
                      events: state.pastEvents,
                      emptyMessage: 'You have no past registered events.',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

final class _FailureView extends StatelessWidget {
  const _FailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final registeredEventsCubit = context.read<RegisteredEventsCubit>();

    return Center(
      child: Padding(
        padding: const .all(_RegisteredEventsViewTokens.contentPadding),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              message,
              textAlign: .center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: _RegisteredEventsViewTokens.sectionSpacing),
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

final class _InlineFailureBanner extends StatelessWidget {
  const _InlineFailureBanner({required this.message});

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
          horizontal: _RegisteredEventsViewTokens.listHorizontalPadding,
          vertical: _RegisteredEventsViewTokens.listVerticalPadding,
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: _RegisteredEventsViewTokens.bannerSpacing),
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

final class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.events, required this.emptyMessage});

  final List<RegisteredEventEntity> events;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final registeredEventsCubit = context.read<RegisteredEventsCubit>();

    return RefreshIndicator.adaptive(
      onRefresh: registeredEventsCubit.refresh,
      child: events.isEmpty
          ? _EmptyEventsView(message: emptyMessage)
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const .symmetric(
                horizontal: _RegisteredEventsViewTokens.listHorizontalPadding,
                vertical: _RegisteredEventsViewTokens.listVerticalPadding,
              ),
              itemCount: events.length,
              itemBuilder: (context, index) => _EventCard(event: events[index]),
            ),
    );
  }
}

final class _EmptyEventsView extends StatelessWidget {
  const _EmptyEventsView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const .all(_RegisteredEventsViewTokens.contentPadding),
              child: Column(
                mainAxisSize: .min,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: _RegisteredEventsViewTokens.emptyIconSize,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(
                    height: _RegisteredEventsViewTokens.sectionSpacing,
                  ),
                  Text(
                    message,
                    textAlign: .center,
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final RegisteredEventEntity event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final resolvedThumbnailUrl = event.resolvedThumbnailUrl;
    final metaParts = <String>[
      if (event.eventCode != null && event.eventCode!.isNotEmpty)
        'Code: ${event.eventCode}',
      DateFormat.yMMMd().format(event.startDate),
    ];

    return Padding(
      padding: const .only(bottom: _RegisteredEventsViewTokens.itemSpacing),
      child: Card(
        clipBehavior: .antiAlias,
        child: Row(
          crossAxisAlignment: .start,
          children: [
            SizedBox(
              width: _RegisteredEventsViewTokens.thumbnailSize,
              height: _RegisteredEventsViewTokens.thumbnailSize,
              child:
                  resolvedThumbnailUrl != null &&
                      resolvedThumbnailUrl.isNotEmpty
                  ? Image.network(
                      resolvedThumbnailUrl,
                      fit: .cover,
                      errorBuilder: (_, _, _) => _thumbnailPlaceholder(context),
                    )
                  : _thumbnailPlaceholder(context),
            ),
            Expanded(
              child: Padding(
                padding: const .all(
                  _RegisteredEventsViewTokens.cardContentPadding,
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(
                      event.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: .w600,
                      ),
                    ),
                    if (metaParts.isNotEmpty) ...[
                      const SizedBox(
                        height: _RegisteredEventsViewTokens.descriptionSpacing,
                      ),
                      Text(
                        metaParts.join(' · '),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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
  }
}

Widget _thumbnailPlaceholder(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return ColoredBox(
    color: colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.event,
      size: _RegisteredEventsViewTokens.placeholderIconSize,
      color: colorScheme.onSurfaceVariant,
    ),
  );
}
