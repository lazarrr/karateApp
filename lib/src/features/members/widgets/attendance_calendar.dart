import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc_event.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc_state.dart';
import 'package:table_calendar/table_calendar.dart';

/// Dialog that shows a month view with green‑dot markers on present days.
class AttendanceCalendarDialog extends StatefulWidget {
  final int memberId;
  const AttendanceCalendarDialog({super.key, required this.memberId});

  @override
  State<AttendanceCalendarDialog> createState() =>
      _AttendanceCalendarDialogState();
}

class _AttendanceCalendarDialogState extends State<AttendanceCalendarDialog> {
  Map<DateTime, bool> attendance = {};
  DateTime focusedDay = DateTime.now();

  /// Strip hour/min/sec so look‑ups work.
  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _fetchAttendanceForMonth(focusedDay);

    context.read<AttendanceBloc>().stream.listen((state) {
      if (state is AttendanceFetchedForMonth) {
        final fetched = <DateTime, bool>{};
        for (final date in state.attendanceDates) {
          fetched[_dayKey(date)] = true;
        }
        setState(() {
          attendance = fetched;
        });
      }
    });
  }

  Future<void> _fetchAttendanceForMonth(DateTime month) async {
    final attendanceBloc = context.read<AttendanceBloc>();
    attendanceBloc.add(FetchAttendanceForMonth(widget.memberId, month));
  }

  void _onPageChanged(DateTime newFocusedDay) {
    setState(() {
      focusedDay = newFocusedDay;
    });
    _fetchAttendanceForMonth(newFocusedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pregled dolazaka',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SizedBox(
              child: TableCalendar(
                firstDay: DateTime.utc(DateTime.now().year - 1, 1, 1),
                lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
                focusedDay: focusedDay,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                onPageChanged: _onPageChanged,
                eventLoader: (day) =>
                    attendance[_dayKey(day)] == true ? ['present'] : [],
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (_, day, events) => events.isEmpty
                      ? const SizedBox.shrink()
                      : Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          ),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
