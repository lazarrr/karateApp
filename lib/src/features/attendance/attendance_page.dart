import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc_event.dart';
import 'package:karate_club_app/src/models/member.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Member> _filteredMembers = [];
  bool _selectMode = false;
  final List<int> _selectedIds = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    var members = context.read<AttendanceBloc>().add(FetchAbsentMembers(0, 5));
  }

  void _filterMembers(String query) {
    setState(() {});
  }

  void _toggleAttendance(Member member) {
    setState(() {
      final index = _filteredMembers.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        // _filteredMembers[index] = member.copyWith(
        //   lastAttendance: DateTime.now(),
        //   isPresentToday: !(member.isPresentToday ?? false),
        // );
      }
    });
  }

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) _selectedIds.clear();
    });
  }

  void _toggleSelection(int memberId) {
    setState(() {
      if (_selectedIds.contains(memberId)) {
        _selectedIds.remove(memberId);
      } else {
        _selectedIds.add(memberId);
      }
    });
  }

  void _markSelectedAsPresent(bool present) {
    setState(() {
      _filteredMembers = _filteredMembers.map((member) {
        if (_selectedIds.contains(member.id)) {
          return member.copyWith(dateOfBirth: DateTime.now());
        }
        return member;
      }).toList();
      _selectMode = false;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = 2;
    // _filteredMembers.where((m) => m.isPresentToday ?? false).length;
    final absentCount = _filteredMembers.length - presentCount;

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
                    hintText: 'Pretraži po imenu ili pojasu...',
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
                        // Example: Call your repository endpoint here
                        // await AttendanceRepository().markAllPresent();
                      },
                      child: _StatBadge(
                        color: Colors.red,
                        icon: Icons.close,
                        count: absentCount,
                        label: 'Odsutni',
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        // Example: Call your repository endpoint here
                        // await AttendanceRepository().markAllPresent();
                      },
                      child: _StatBadge(
                        color: Colors.green,
                        icon: Icons.check,
                        count: presentCount,
                        label: 'Prisutni',
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
              itemCount: _filteredMembers.length,
              itemBuilder: (context, index) {
                final member = _filteredMembers[index];
                return _AttendanceCard(
                  member: member,
                  isSelected: _selectedIds.contains(member.id),
                  selectMode: _selectMode,
                  onToggleSelect: () => _toggleSelection(member.id),
                  onToggleAttendance: () => _toggleAttendance(member),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Save to DB
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attendance saved!')),
          );
        },
        child: const Icon(Icons.save),
        tooltip: 'Save Attendance',
      ),
    );
  }
}

// --- Custom Widgets ---

class _AttendanceCard extends StatelessWidget {
  final Member member;
  final bool selectMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onToggleAttendance;

  const _AttendanceCard({
    required this.member,
    required this.selectMode,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onToggleAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isSelected ? Colors.blue[50] : null,
      child: InkWell(
        onTap: selectMode ? onToggleSelect : onToggleAttendance,
        onLongPress: onToggleSelect,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (selectMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggleSelect(),
                ),
              CircleAvatar(
                backgroundColor: _getBeltColor(member.beltColor),
                child: Text(
                  member.firstName[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.firstName,
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
                icon: const Icon(
                  1 == 1 ?? false
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: 1 == 1 ?? false ? Colors.green : Colors.grey,
                ),
                onPressed: selectMode ? null : onToggleAttendance,
                tooltip: 1 == 1 ?? false ? 'Mark as Absent' : 'Mark as Present',
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

  const _StatBadge({
    required this.color,
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
