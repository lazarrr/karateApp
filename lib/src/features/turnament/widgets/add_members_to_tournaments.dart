import 'package:flutter/material.dart';

class AddMembersToTournament extends StatefulWidget {
  const AddMembersToTournament({Key? key}) : super(key: key);

  @override
  State<AddMembersToTournament> createState() => _AddMembersToTournamentState();
}

class _AddMembersToTournamentState extends State<AddMembersToTournament> {
  late List<String> _selectedMembers;

  @override
  void initState() {
    super.initState();
    // _selectedMembers = List<String>.from(widget.initiallySelected);
  }

  void _onMemberTap(String member) {
    setState(() {
      if (_selectedMembers.contains(member)) {
        _selectedMembers.remove(member);
      } else {
        _selectedMembers.add(member);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Members to Tournament'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          // itemCount: widget.availableMembers.length,
          itemCount: 0,
          itemBuilder: (context, index) {
            // final member = widget.availableMembers[index];
            final member = 'Member $index'; // Placeholder for example
            final isSelected = _selectedMembers.contains(member);
            return ListTile(
              title: Text(member),
              leading: Checkbox(
                value: isSelected,
                onChanged: (_) => _onMemberTap(member),
              ),
              onTap: () => _onMemberTap(member),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // widget.onMembersSelected(_selectedMembers);
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
