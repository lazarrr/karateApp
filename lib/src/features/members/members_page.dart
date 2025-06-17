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
        title: const Text('Članovi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMemberDialog(context),
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
          return const Center(child: Text('Nije pronađen nijedan član'));
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showAddMemberDialog(context),
      //   child: const Icon(Icons.add),
      // ),
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
                    labelText: 'Dattm rođenja',
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
                  const Text('Belt Color', style: TextStyle(fontSize: 16)),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final color in [
                        'white',
                        'yellow',
                        'orange',
                        'green',
                        'blue',
                        'brown',
                        'black'
                      ])
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
                  dateOfBirth: DateTime.now());
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
  final List<Member> members;

  const MembersList({Key? key, required this.members}) : super(key: key);

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  late List<Member> _filteredMembers;
  int _currentPage = 0;
  static const int _membersPerPage = 5;

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

  List<Member> get _paginatedMembers {
    final startIndex = _currentPage * _membersPerPage;
    final endIndex = startIndex + _membersPerPage;
    return _filteredMembers.sublist(
      startIndex,
      endIndex > _filteredMembers.length ? _filteredMembers.length : endIndex,
    );
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
                hintText: 'Pretraži članove o imenu ili boji pojasa...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (query) {
                _filterMembers(query);
                _currentPage = 0; // Reset to first page on new search
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _paginatedMembers.length,
              itemBuilder: (context, index) {
                final member = _paginatedMembers[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: _getBeltColor(member.beltColor)),
                    title: Text("${member.firstName} ${member.lastName}"),
                    subtitle: Text('${member.beltColor} pojas'),
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
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                  child: const Text('Prethodna'),
                ),
                Text('Strana ${_currentPage + 1}'),
                TextButton(
                  onPressed: (_currentPage + 1) * _membersPerPage <
                          _filteredMembers.length
                      ? () => setState(() => _currentPage++)
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
                    for (final color in [
                      'white',
                      'yellow',
                      'orange',
                      'green',
                      'blue',
                      'brown',
                      'black'
                    ])
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
              beltColor: beltController.text, dateOfBirth: DateTime.now(),
              // You may want to update dateOfBirth instead of age
            );
            context.read<MembersBloc>().add(UpdateMember(updatedMember));
            Navigator.pop(context);
          },
          child: const Text('Sačuvaj', style: TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}
