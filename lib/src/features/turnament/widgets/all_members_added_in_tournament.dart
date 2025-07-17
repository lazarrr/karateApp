import 'package:flutter/material.dart';
import 'package:karate_club_app/src/models/member.dart';

class TournamentMembersPage extends StatefulWidget {
  final List<Member> tournamentMembers;

  const TournamentMembersPage({
    super.key,
    required this.tournamentMembers,
  });

  @override
  State<TournamentMembersPage> createState() => _TournamentMembersPageState();
}

class _TournamentMembersPageState extends State<TournamentMembersPage> {
  late List<Member> _filteredMembers;
  final TextEditingController _searchController = TextEditingController();
  int _offset = 0;
  final int _pageSize = 5;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _filteredMembers = List.from(widget.tournamentMembers);
    _total = widget.tournamentMembers.length;
    _searchController.addListener(_filterMembers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = widget.tournamentMembers.where((member) {
        return member.firstName.toLowerCase().contains(query) ||
            member.lastName.toLowerCase().contains(query);
      }).toList();
      _total = _filteredMembers.length;
      _offset = 0; // Reset to first page when filtering
    });
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
      case 'white':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  String _getBeltColorAsString(String beltColor) {
    switch (beltColor.toLowerCase()) {
      case 'black':
        return 'Crni pojas';
      case 'brown':
        return 'Braon pojas';
      case 'blue':
        return 'Plavi pojas';
      case 'green':
        return 'Zeleni pojas';
      case 'orange':
        return 'Narandžasti pojas';
      case 'yellow':
        return 'Žuti pojas';
      case 'white':
        return 'Beli pojas';
      default:
        return beltColor[0].toUpperCase() + beltColor.substring(1);
    }
  }

  List<Member> get _paginatedMembers {
    if (_offset >= _filteredMembers.length) {
      return [];
    }
    return _filteredMembers.sublist(
      _offset,
      _offset + _pageSize > _filteredMembers.length
          ? _filteredMembers.length
          : _offset + _pageSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Učesnici turnira'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pretraži učesnike...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Member count info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Ukupno učesnika: $_total',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Members list
          Expanded(
            child: ListView.builder(
              itemCount: _paginatedMembers.length,
              itemBuilder: (context, index) {
                final member = _paginatedMembers[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Container(
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
                    title: Text("${member.firstName} ${member.lastName}"),
                    subtitle: Text(_getBeltColorAsString(member.beltColor)),
                  ),
                );
              },
            ),
          ),

          // Pagination controls (your preferred style)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _offset > 0
                      ? () {
                          setState(() {
                            _offset -= _pageSize;
                          });
                        }
                      : null,
                  child: const Text('Prethodna'),
                ),
                Text('Strana ${(_offset ~/ _pageSize) + 1}'),
                TextButton(
                  onPressed: (_offset + _pageSize) < _total
                      ? () {
                          setState(() {
                            _offset += _pageSize;
                          });
                        }
                      : null,
                  child: const Text('Sledeća'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
