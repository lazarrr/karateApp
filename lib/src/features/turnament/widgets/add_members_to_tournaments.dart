import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc_event.dart';
import 'package:karate_club_app/src/features/members/members_bloc_state.dart';
import 'package:karate_club_app/src/models/member.dart';

class AddMembersToTournamentPage extends StatefulWidget {
  final List<Member> initiallySelectedMembers;

  const AddMembersToTournamentPage({
    super.key,
    this.initiallySelectedMembers = const [],
  });

  @override
  State<AddMembersToTournamentPage> createState() =>
      _AddMembersToTournamentPageState();
}

class _AddMembersToTournamentPageState
    extends State<AddMembersToTournamentPage> {
  late List<Member> availableMembers = [];
  late List<Member> selectedMembers = [];
  int offset = 0;
  static const int _membersPerPage = 5;
  int _totalUserCount = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedMembers = List.from(widget.initiallySelectedMembers);
    context.read<MembersBloc>().add(GetTotalCountOfMembers());
    context.read<MembersBloc>().add(LoadMembers(
          offset: offset,
          limit: _membersPerPage,
        ));
    context.read<MembersBloc>().stream.listen((state) {
      if (state is TotalCountOfMembers) {
        setState(() {
          _totalUserCount = state.count;
        });
      } else if (state is MembersLoaded) {
        setState(() {
          availableMembers = state.members;
        });
      } else if (state is MembersError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    });
  }

  void _filterMembers(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      offset = 0; // Reset to first page on new search
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

  void _toggleMemberSelection(Member member, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedMembers.add(member);
      } else {
        selectedMembers.removeWhere((m) => m.id == member.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter members based on search query
    final filteredMembers = _searchQuery.isEmpty
        ? availableMembers
        : availableMembers
            .where((member) =>
                member.firstName.toLowerCase().contains(_searchQuery) ||
                member.lastName.toLowerCase().contains(_searchQuery))
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dodaj članove na turnir'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, selectedMembers);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pretraži članove po imenu ili prezimenu...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: _filterMembers,
              ),
            ),

            // Selected members count
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    'Izabrani članovi: ${selectedMembers.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Available members list
            Expanded(
              child: ListView.builder(
                itemCount: filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = filteredMembers[index];
                  final isSelected =
                      selectedMembers.any((m) => m.id == member.id);

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
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (value) =>
                            _toggleMemberSelection(member, value ?? false),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Pagination controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: offset > 0
                        ? () => setState(() {
                              offset -= _membersPerPage;
                              context.read<MembersBloc>().add(LoadMembers(
                                    offset: offset,
                                    limit: _membersPerPage,
                                  ));
                            })
                        : null,
                    child: const Text('Prethodna'),
                  ),
                  Text('Strana ${(offset ~/ _membersPerPage) + 1}'),
                  TextButton(
                    onPressed: (offset + 1) * _membersPerPage < _totalUserCount
                        ? () => setState(() {
                              offset += _membersPerPage;
                              context.read<MembersBloc>().add(LoadMembers(
                                    offset: offset,
                                    limit: _membersPerPage,
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
      ),
    );
  }
}
