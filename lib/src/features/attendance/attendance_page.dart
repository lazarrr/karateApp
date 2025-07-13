import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc_event.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc_state.dart';
import 'package:karate_club_app/src/models/member.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Member> _members = [];
  bool _showPresent = false;
  int presentCount = 0;
  int absentCount = 0;
  int offset = 0;
  static const int _membersPerPage = 5;
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    context.read<AttendanceBloc>().stream.listen((state) {
      if (state is AttendanceLoaded) {
        setState(() {
          _showPresent == true ? _members = state.attendance : null;
        });
      } else if (state is AbsentMembersLoaded) {
        setState(() {
          _showPresent == false ? _members = state.attendance : null;
        });
      } else if (state is TotalPresentMembersLoaded) {
        setState(() => presentCount = state.count);
      } else if (state is TotalAbsentMembersLoaded) {
        setState(() => absentCount = state.count);
      } else if (state is AttendanceAdded) {
        _loadInitialData();
      } else if (state is AttendanceRemoved) {
        _loadInitialData();
      } else if (state is AttendanceError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${state.message}')),
        );
      }
    });
  }

  void _loadInitialData() {
    final attendanceBloc = context.read<AttendanceBloc>();
    attendanceBloc.add(FetchPresentMembers(offset, _membersPerPage));
    attendanceBloc.add(FetchAbsentMembers(offset, _membersPerPage));
    attendanceBloc.add(GetTotalNumberOfPresentMembers());
    attendanceBloc.add(GetTotalNumberOfAbsentMembers());
  }

  void _filterMembers(String query) {
    offset = 0; // Reset offset on new search
    _showPresent == false
        ? context
            .read<AttendanceBloc>()
            .add(FetchAbsentMembers(offset, _membersPerPage, query))
        : context
            .read<AttendanceBloc>()
            .add(FetchPresentMembers(offset, _membersPerPage, query));
  }

  void _toggleSelection(int memberId) {
    _showPresent == false
        ? context.read<AttendanceBloc>().add(AddAttendance(memberId))
        : context.read<AttendanceBloc>().add(RemoveAttendance(memberId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dnevna Prisustva'),
      ),
      body: Column(
        children: [
          // Search & Stats Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Pretraži po imenu ili prezimenu...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: _filterMembers,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          _showPresent = false;
                          offset = 0; // Reset offset for absent members
                        });
                        context
                            .read<AttendanceBloc>()
                            .add(FetchAbsentMembers(offset, _membersPerPage));
                      },
                      child: _StatBadge(
                        color: Colors.red,
                        icon: Icons.close,
                        count: absentCount,
                        label: 'Odsutni',
                        isActive: !_showPresent,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        _showPresent = true;
                        offset = 0; // Reset offset for present members
                        context
                            .read<AttendanceBloc>()
                            .add(FetchPresentMembers(offset, _membersPerPage));
                      },
                      child: _StatBadge(
                        color: Colors.green,
                        icon: Icons.check,
                        count: presentCount,
                        label: 'Prisutni',
                        isActive: _showPresent,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

          // Attendance List
          Expanded(
            child: ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                return _AttendanceCard(
                    member: member,
                    isSelected: _showPresent,
                    onToggleSelect: () => _toggleSelection(member.id));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: offset > 0
                      ? () => setState(() {
                            offset -= _membersPerPage;
                            _showPresent == true
                                ? context
                                    .read<AttendanceBloc>()
                                    .add(FetchPresentMembers(
                                      offset,
                                      _membersPerPage,
                                    ))
                                : context
                                    .read<AttendanceBloc>()
                                    .add(FetchAbsentMembers(
                                      offset,
                                      _membersPerPage,
                                    ));
                          })
                      : null,
                  child: const Text('Prethodna'),
                ),
                Text('Strana ${(offset ~/ _membersPerPage) + 1}'),
                TextButton(
                  onPressed:
                      (offset + 1) * _membersPerPage < returnTotalUserCount()
                          ? () => setState(() {
                                offset += _membersPerPage;
                                _showPresent == true
                                    ? context
                                        .read<AttendanceBloc>()
                                        .add(FetchPresentMembers(
                                          offset,
                                          _membersPerPage,
                                        ))
                                    : context
                                        .read<AttendanceBloc>()
                                        .add(FetchAbsentMembers(
                                          offset,
                                          _membersPerPage,
                                        ));
                              })
                          : null,
                  child: const Text('Sledeća'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  num returnTotalUserCount() {
    if (_showPresent) {
      return presentCount;
    } else {
      return absentCount;
    }
  }
}

// --- Custom Widgets ---

class _AttendanceCard extends StatelessWidget {
  final Member member;
  final bool isSelected;
  final VoidCallback onToggleSelect;

  const _AttendanceCard(
      {required this.member,
      required this.isSelected,
      required this.onToggleSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isSelected ? Colors.blue[50] : null,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getBeltColor(member.beltColor),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black12, width: 1),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${member.firstName} ${member.lastName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${member.beltColor} belt',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                // is present today not is active
                icon: Icon(
                  isSelected == true
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected == true ? Colors.green : Colors.grey,
                ),
                onPressed: onToggleSelect,
                tooltip: isSelected == true
                    ? 'Označi kao odsutnog'
                    : 'Označi kao prisutnog',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final int count;
  final String label;
  final bool isActive;

  const _StatBadge({
    required this.color,
    required this.icon,
    required this.count,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: isActive ? Border.all(color: color, width: 2) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
              color: color,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

Color _getBeltColor(String beltColor) {
  switch (beltColor.toLowerCase()) {
    case 'black':
      return Colors.black;
    case 'brown':
      return Colors.brown;
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case 'orange':
      return Colors.orange;
    case 'yellow':
      return Colors.yellow;
    default:
      return Colors.grey;
  }
}
