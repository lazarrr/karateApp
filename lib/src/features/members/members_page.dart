import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc_event.dart';
import 'package:karate_club_app/src/features/members/members_bloc_state.dart';
import 'package:karate_club_app/src/models/member.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  static const beltColors = [
    'white',
    'yellow',
    'orange',
    'green',
    'blue',
    'brown',
    'black'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Članovi'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddMemberDialog(context),
            ),
          ],
        ),
        body: const MembersList());
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final lastNameController = TextEditingController();
    final beltController = TextEditingController();
    final ageController = TextEditingController();
    final mailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dodaj novog člana'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Ime'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Prezime'),
            ),
            TextField(
              controller: mailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.now().subtract(const Duration(days: 365 * 18)),
                  firstDate: DateTime(1950),
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
                    labelText: 'Datum rođenja',
                    hintText: 'Izaberite datum rođenja',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Boja pojasa', style: TextStyle(fontSize: 16)),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final color in beltColors)
                        ChoiceChip(
                          label: Text(
                            () {
                              switch (color) {
                                case 'white':
                                  return 'Bela';
                                case 'yellow':
                                  return 'Žuta';
                                case 'orange':
                                  return 'Narandžasta';
                                case 'green':
                                  return 'Zelena';
                                case 'blue':
                                  return 'Plava';
                                case 'brown':
                                  return 'Braon';
                                case 'black':
                                  return 'Crni';
                                default:
                                  return color[0].toUpperCase() +
                                      color.substring(1);
                              }
                            }(),
                          ),
                          selected: beltController.text == color,
                          selectedColor: _getBeltColor(color).withOpacity(0.7),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color: beltController.text == color
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              beltController.text = color;
                              // Force rebuild to update selection
                              (context as Element).markNeedsBuild();
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () {
              final newMember = Member(
                  id: DateTime.now().millisecondsSinceEpoch,
                  firstName: nameController.text,
                  beltColor: beltController.text,
                  lastName: lastNameController.text,
                  dateOfBirth: DateTime.now(),
                  email: mailController.text);
              context.read<MembersBloc>().add(AddMember(newMember));
              Navigator.pop(context);
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }
}

class MembersList extends StatefulWidget {
  const MembersList({super.key});

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  late List<Member> members = [];
  // int _currentPage = 0;
  int offset = 0;
  static const int _membersPerPage = 5;
  int _totalUserCount = 0;

  @override
  void initState() {
    super.initState();
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
          members = state.members;
        });
      } else if (state is MembersError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    });
  }

  void _filterMembers(String query) {}

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
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
              onChanged: (query) {
                _filterMembers(query);
                offset = 0; // Reset to first page on new search
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    // Replace CircleAvatar with a colored belt strip
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
                            onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Da li ste sigurni?'),
                                    content: const Text(
                                        'Želite li da obrišete ovog člana?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Odustani'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          context
                                              .read<MembersBloc>()
                                              .add(DeleteMember(member.id));
                                        },
                                        child: const Text('Obriši',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ),
                );
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
  final mailController = TextEditingController(text: member.email);

  const beltColors = [
    'white',
    'yellow',
    'orange',
    'green',
    'blue',
    'brown',
    'black'
  ];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Member'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: firstNameController,
            decoration: const InputDecoration(labelText: 'Ime'),
          ),
          TextField(
            controller: lastNameController,
            decoration: const InputDecoration(labelText: 'Prezime'),
          ),
          TextField(
            controller: mailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate:
                    DateTime.now().subtract(const Duration(days: 365 * 18)),
                firstDate: DateTime(1950),
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
                  labelText: 'Datum rođenja',
                  hintText: 'Izaberite datum rođenja',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Boja pojasa', style: TextStyle(fontSize: 16)),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final color in beltColors)
                      ChoiceChip(
                        label: Text(() {
                          switch (color) {
                            case 'white':
                              return 'Bela';
                            case 'yellow':
                              return 'Žuta';
                            case 'orange':
                              return 'Narandžasta';
                            case 'green':
                              return 'Zelena';
                            case 'blue':
                              return 'Plava';
                            case 'brown':
                              return 'Braon';
                            case 'black':
                              return 'Crni';
                            default:
                              return color[0].toUpperCase() +
                                  color.substring(1);
                          }
                        }()),
                        selected: beltController.text == color,
                        selectedColor: _getBeltColor(color).withOpacity(0.7),
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: beltController.text == color
                              ? Colors.white
                              : Colors.black,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            beltController.text = color;
                            // Force rebuild to update selection
                            (context as Element).markNeedsBuild();
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Odustani'),
        ),
        TextButton(
          onPressed: () {
            final updatedMember = member.copyWith(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                beltColor: beltController.text,
                dateOfBirth: DateTime.now(),
                email: mailController.text);
            context.read<MembersBloc>().add(UpdateMember(updatedMember));
            Navigator.pop(context);
          },
          child: const Text('Sačuvaj', style: TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}
