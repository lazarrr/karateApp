import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc_event.dart';
import 'package:karate_club_app/src/features/members/members_bloc_state.dart';
import 'package:karate_club_app/src/models/member.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: BlocBuilder<MembersBloc, MembersState>(
        builder: (context, state) {
          if (state is MembersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MembersLoaded) {
            return MembersList(members: state.members);
          } else if (state is MembersError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No members found'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemberDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final lastNameController = TextEditingController();
    final beltController = TextEditingController();
    final ageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: beltController,
              decoration: const InputDecoration(labelText: 'Belt Color'),
            ),
            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.now().subtract(const Duration(days: 365 * 18)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  ageController.text = "${pickedDate.toLocal()}".split(' ')[0];
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'Select date of birth',
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newMember = Member(
                  id: DateTime.now().millisecondsSinceEpoch,
                  firstName: nameController.text,
                  beltColor: beltController.text,
                  lastName: lastNameController.text,
                  dateOfBirth: DateTime.now());
              context.read<MembersBloc>().add(AddMember(newMember));
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class MembersList extends StatefulWidget {
  final List<Member> members;

  const MembersList({Key? key, required this.members}) : super(key: key);

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  late List<Member> _filteredMembers;

  @override
  void initState() {
    super.initState();
    _filteredMembers = widget.members;
  }

  @override
  void didUpdateWidget(covariant MembersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.members != widget.members) {
      _filteredMembers = widget.members;
    }
  }

  void _filterMembers(String query) {
    setState(() {
      _filteredMembers = widget.members
          .where((member) =>
              member.firstName.toLowerCase().contains(query.toLowerCase()) ||
              member.lastName.toLowerCase().contains(query.toLowerCase()) ||
              member.beltColor.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or belt...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterMembers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredMembers.length,
              itemBuilder: (context, index) {
                final member = _filteredMembers[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getBeltColor(member.beltColor),
                      child: Text(member.firstName.isNotEmpty
                          ? member.firstName[0]
                          : ''),
                    ),
                    title: Text("${member.firstName} ${member.lastName}"),
                    subtitle:
                        Text('${member.beltColor} belt - Age: ${member.age}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showEditMemberDialog(context, member),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => context
                              .read<MembersBloc>()
                              .add(DeleteMember(member.id)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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

  void _showEditMemberDialog(BuildContext context, Member member) {
    final firstNameController = TextEditingController(text: member.firstName);
    final lastNameController = TextEditingController(text: member.lastName);
    final beltController = TextEditingController(text: member.beltColor);
    final ageController =
        TextEditingController(text: member.dateOfBirth.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: beltController,
              decoration: const InputDecoration(labelText: 'Belt Color'),
            ),
            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.now().subtract(const Duration(days: 365 * 18)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  ageController.text = "${pickedDate.toLocal()}".split(' ')[0];
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'Select date of birth',
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedMember = member.copyWith(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                beltColor: beltController.text, dateOfBirth: DateTime.now(),
                // You may want to update dateOfBirth instead of age
              );
              context.read<MembersBloc>().add(UpdateMember(updatedMember));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class MemberSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final members = context.read<MembersBloc>().state.members;
    final results = members.where((member) =>
        member.firstName.toLowerCase().contains(query.toLowerCase()) ||
        member.lastName.toLowerCase().contains(query.toLowerCase()) ||
        member.beltColor.toLowerCase().contains(query.toLowerCase()));

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final member = results.elementAt(index);
        return ListTile(
          title: Text(member.firstName),
          subtitle: Text(member.beltColor),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemberDetailPage(member: member),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show recent searches or popular members
    return const Center(
        child: Text('Search for members by name or belt color'));
  }
}

// Add this to your members.dart exports if you create it
class MemberDetailPage extends StatelessWidget {
  final Member member;

  const MemberDetailPage({Key? key, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(member.firstName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Belt Color: ${member.beltColor}',
                style: TextStyle(fontSize: 18)),
            Text('Age: ${member.age}', style: TextStyle(fontSize: 18))
            // Add more member details as needed
          ],
        ),
      ),
    );
  }
}
