import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  // Reference date: 2026-03-06 (a Friday).
  final today = DateTime(2026, 3, 6);

  RegisteredEventEntity buildEvent({
    required String name,
    required DateTime startDate,
    int? durationDays,
    String? eventId,
  }) => RegisteredEventEntity(
    eventId: eventId ?? name,
    name: name,
    registrationId: 'reg-$name',
    startDate: startDate,
    durationDays: durationDays,
  );

  group('RegisteredEventsTimelineClassifier', () {
    // -----------------------------------------------------------------------
    // Empty input
    // -----------------------------------------------------------------------
    test('returns empty timeline for empty list', () {
      final timeline = RegisteredEventsTimelineClassifier.classify(
        [],
        referenceDate: today,
      );

      expect(timeline, RegisteredEventsTimeline.empty);
      expect(timeline.isEmpty, isTrue);
    });

    // -----------------------------------------------------------------------
    // Classification
    // -----------------------------------------------------------------------
    group('classification', () {
      test('event starting tomorrow is upcoming', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(
              name: 'Tomorrow',
              startDate: DateTime(2026, 3, 7),
            ),
          ],
          referenceDate: today,
        );

        expect(timeline.upcoming, hasLength(1));
        expect(timeline.current, isEmpty);
        expect(timeline.past, isEmpty);
      });

      test('event starting today is current', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(
              name: 'Today',
              startDate: DateTime(2026, 3, 6),
            ),
          ],
          referenceDate: today,
        );

        expect(timeline.current, hasLength(1));
        expect(timeline.upcoming, isEmpty);
        expect(timeline.past, isEmpty);
      });

      test('event that ended yesterday is past', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(
              name: 'Yesterday',
              startDate: DateTime(2026, 3, 5),
            ),
          ],
          referenceDate: today,
        );

        expect(timeline.past, hasLength(1));
        expect(timeline.current, isEmpty);
        expect(timeline.upcoming, isEmpty);
      });

      test('3-day event starting 2 days ago is still current', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(
              name: 'Multi',
              startDate: DateTime(2026, 3, 4),
              durationDays: 3,
            ),
          ],
          referenceDate: today,
        );

        // Mar 4 + 3 = end-exclusive Mar 7.
        // Today (Mar 6) < Mar 7 -> current.
        expect(timeline.current, hasLength(1));
      });

      test('3-day event starting 3 days ago just ended (past)', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(
              name: 'Ended',
              startDate: DateTime(2026, 3, 3),
              durationDays: 3,
            ),
          ],
          referenceDate: today,
        );

        // Mar 3 + 3 = end-exclusive Mar 6.
        // Today (Mar 6) is NOT before Mar 6 -> past.
        expect(timeline.past, hasLength(1));
      });

      test('last included day of multi-day event is current', () {
        // 2-day event starting Mar 5.
        // End-exclusive = Mar 7. Today Mar 6 < Mar 7.
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(
              name: 'LastDay',
              startDate: DateTime(2026, 3, 5),
              durationDays: 2,
            ),
          ],
          referenceDate: today,
        );

        expect(timeline.current, hasLength(1));
      });
    });

    // -----------------------------------------------------------------------
    // Duration normalization
    // -----------------------------------------------------------------------
    group('duration normalization', () {
      test('null durationDays defaults to 1-day event', () {
        // Starts today, duration null -> treated as 1 day -> current.
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(
              name: 'Null dur',
              startDate: DateTime(2026, 3, 6),
            ),
          ],
          referenceDate: today,
        );

        expect(timeline.current, hasLength(1));
      });

      test('zero durationDays normalized to 1', () {
        // Mar 5 + 0 -> normalized to 1 -> end-exclusive Mar 6.
        // Today = Mar 6 -> past.
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(
              name: 'Zero dur',
              startDate: DateTime(2026, 3, 5),
              durationDays: 0,
            ),
          ],
          referenceDate: today,
        );

        expect(timeline.past, hasLength(1));
      });

      test('negative durationDays normalized to 1', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(
              name: 'Neg dur',
              startDate: DateTime(2026, 3, 6),
              durationDays: -5,
            ),
          ],
          referenceDate: today,
        );

        expect(timeline.current, hasLength(1));
      });
    });

    // -----------------------------------------------------------------------
    // Time-of-day stripping
    // -----------------------------------------------------------------------
    test('referenceDate time-of-day is stripped', () {
      // Even if referenceDate has a late time, classification uses day only.
      final lateToday = DateTime(2026, 3, 6, 23, 59, 59);
      final timeline = RegisteredEventsTimelineClassifier.classify(
        [buildEvent(name: 'Today', startDate: DateTime(2026, 3, 6))],
        referenceDate: lateToday,
      );

      expect(timeline.current, hasLength(1));
    });

    test('event startDate time-of-day is stripped', () {
      final timeline = RegisteredEventsTimelineClassifier.classify(
        [
          buildEvent(
            name: 'WithTime',
            startDate: DateTime(2026, 3, 7, 14, 30),
          ),
        ],
        referenceDate: today,
      );

      // Mar 7 > Mar 6 -> upcoming regardless of the 14:30 time component.
      expect(timeline.upcoming, hasLength(1));
    });

    // -----------------------------------------------------------------------
    // Sorting
    // -----------------------------------------------------------------------
    group('sorting', () {
      test('current events sorted by soonest ending first', () {
        final events = [
          buildEvent(
            name: 'B ends later',
            startDate: DateTime(2026, 3, 4),
            durationDays: 5,
          ),
          buildEvent(
            name: 'A ends sooner',
            startDate: DateTime(2026, 3, 5),
            durationDays: 2,
          ),
        ];

        final timeline = RegisteredEventsTimelineClassifier.classify(
          events,
          referenceDate: today,
        );

        expect(timeline.current.map((e) => e.name).toList(), [
          'A ends sooner', // end Mar 7
          'B ends later', // end Mar 9
        ]);
      });

      test('current events with same end sorted by start then name', () {
        final events = [
          buildEvent(
            name: 'Z same range',
            startDate: DateTime(2026, 3, 5),
            durationDays: 3,
          ),
          buildEvent(
            name: 'A same range',
            startDate: DateTime(2026, 3, 5),
            durationDays: 3,
          ),
        ];

        final timeline = RegisteredEventsTimelineClassifier.classify(
          events,
          referenceDate: today,
        );

        expect(timeline.current.map((e) => e.name).toList(), [
          'A same range',
          'Z same range',
        ]);
      });

      test('upcoming events sorted by soonest starting first', () {
        final events = [
          buildEvent(name: 'Far', startDate: DateTime(2026, 3, 20)),
          buildEvent(name: 'Near', startDate: DateTime(2026, 3, 8)),
        ];

        final timeline = RegisteredEventsTimelineClassifier.classify(
          events,
          referenceDate: today,
        );

        expect(timeline.upcoming.map((e) => e.name).toList(), [
          'Near',
          'Far',
        ]);
      });

      test('past events sorted by most recently ended first', () {
        final events = [
          buildEvent(name: 'Long ago', startDate: DateTime(2026, 2)),
          buildEvent(name: 'Recent', startDate: DateTime(2026, 3, 4)),
        ];

        final timeline = RegisteredEventsTimelineClassifier.classify(
          events,
          referenceDate: today,
        );

        expect(timeline.past.map((e) => e.name).toList(), [
          'Recent',
          'Long ago',
        ]);
      });
    });

    // -----------------------------------------------------------------------
    // Convenience getters
    // -----------------------------------------------------------------------
    group('convenience getters', () {
      test('primaryCurrentEvent returns first sorted current event', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(
              name: 'B',
              startDate: DateTime(2026, 3, 4),
              durationDays: 5,
            ),
            buildEvent(
              name: 'A',
              startDate: DateTime(2026, 3, 5),
              durationDays: 2,
            ),
          ],
          referenceDate: today,
        );

        expect(timeline.primaryCurrentEvent?.name, 'A');
      });

      test('primaryCurrentEvent is null when no current events', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [buildEvent(name: 'Future', startDate: DateTime(2026, 4))],
          referenceDate: today,
        );

        expect(timeline.primaryCurrentEvent, isNull);
      });

      test('nextUpcomingEvent returns soonest upcoming event', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(name: 'Far', startDate: DateTime(2026, 5)),
            buildEvent(name: 'Near', startDate: DateTime(2026, 3, 10)),
          ],
          referenceDate: today,
        );

        expect(timeline.nextUpcomingEvent?.name, 'Near');
      });

      test('nextUpcomingEvent is null when no upcoming events', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [buildEvent(name: 'Past', startDate: DateTime(2026))],
          referenceDate: today,
        );

        expect(timeline.nextUpcomingEvent, isNull);
      });

      test('additionalCurrentEventsCount excludes primary', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [
            buildEvent(
              name: 'A',
              startDate: DateTime(2026, 3, 5),
              durationDays: 3,
            ),
            buildEvent(
              name: 'B',
              startDate: DateTime(2026, 3, 4),
              durationDays: 5,
            ),
            buildEvent(
              name: 'C',
              startDate: DateTime(2026, 3, 3),
              durationDays: 10,
            ),
          ],
          referenceDate: today,
        );

        expect(timeline.additionalCurrentEventsCount, 2);
      });

      test('additionalCurrentEventsCount is 0 with single current event', () {
        final timeline = RegisteredEventsTimelineClassifier.classify(
          [buildEvent(name: 'Only', startDate: DateTime(2026, 3, 6))],
          referenceDate: today,
        );

        expect(timeline.additionalCurrentEventsCount, 0);
      });
    });

    // -----------------------------------------------------------------------
    // Mixed events — end-to-end
    // -----------------------------------------------------------------------
    test('mixed events are correctly distributed across buckets', () {
      final events = [
        buildEvent(name: 'Past 1', startDate: DateTime(2026, 2)),
        buildEvent(name: 'Current 1', startDate: DateTime(2026, 3, 6)),
        buildEvent(name: 'Upcoming 1', startDate: DateTime(2026, 4)),
        buildEvent(
          name: 'Current 2',
          startDate: DateTime(2026, 3, 4),
          durationDays: 5,
        ),
        buildEvent(name: 'Past 2', startDate: DateTime(2026, 2, 15)),
        buildEvent(name: 'Upcoming 2', startDate: DateTime(2026, 3, 10)),
      ];

      final timeline = RegisteredEventsTimelineClassifier.classify(
        events,
        referenceDate: today,
      );

      expect(timeline.current.map((e) => e.name), ['Current 1', 'Current 2']);
      expect(
        timeline.upcoming.map((e) => e.name),
        ['Upcoming 2', 'Upcoming 1'],
      );
      expect(timeline.past.map((e) => e.name), ['Past 2', 'Past 1']);
    });

    // -----------------------------------------------------------------------
    // Immutability
    // -----------------------------------------------------------------------
    test('returned bucket lists are unmodifiable', () {
      final timeline = RegisteredEventsTimelineClassifier.classify(
        [buildEvent(name: 'A', startDate: DateTime(2026, 3, 6))],
        referenceDate: today,
      );

      expect(
        () => timeline.current.add(
          buildEvent(name: 'Intruder', startDate: DateTime(2026, 3, 6)),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
