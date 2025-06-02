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
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MemberSearchDelegate(),
              );
            },
          ),
        ],
      ),
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
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: beltController,
              decoration: const InputDecoration(labelText: 'Belt Color'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
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
                name: nameController.text,
                beltColor: beltController.text,
                age: int.tryParse(ageController.text) ?? 0,
                joinDate: DateTime.now(),
              );
              // context.read<MembersBloc>().add(AddMember(newMember));
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class MembersList extends StatelessWidget {
  final List<Member> members;

  const MembersList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getBeltColor(member.beltColor),
              child: Text(member.name[0]),
            ),
            title: Text(member.name),
            subtitle: Text('${member.beltColor} belt - Age: ${member.age}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditMemberDialog(context, member),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      context.read<MembersBloc>().add(DeleteMember(member.id)),
                ),
              ],
            ),
          ),
        );
      },
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
    final nameController = TextEditingController(text: member.name);
    final beltController = TextEditingController(text: member.beltColor);
    final ageController = TextEditingController(text: member.age.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: beltController,
              decoration: const InputDecoration(labelText: 'Belt Color'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
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
                name: nameController.text,
                beltColor: beltController.text,
                age: int.tryParse(ageController.text) ?? member.age,
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
        member.name.toLowerCase().contains(query.toLowerCase()) ||
        member.beltColor.toLowerCase().contains(query.toLowerCase()));

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final member = results.elementAt(index);
        return ListTile(
          title: Text(member.name),
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
      appBar: AppBar(title: Text(member.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Belt Color: ${member.beltColor}',
                style: TextStyle(fontSize: 18)),
            Text('Age: ${member.age}', style: TextStyle(fontSize: 18)),
            Text('Member since: ${member.joinDate.toString().split(' ')[0]}',
                style: TextStyle(fontSize: 18)),
            // Add more member details as needed
          ],
        ),
      ),
    );
  }
}
