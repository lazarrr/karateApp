import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc_event.dart';
import 'package:karate_club_app/src/features/members/members_bloc_state.dart';
import 'package:karate_club_app/src/features/members/widgets/attendance_calendar.dart';
import 'package:karate_club_app/src/features/members/widgets/payments.dart';
import 'package:karate_club_app/src/models/member.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  static const beltColors = [
    'yellow',
    'orange',
    'red',
    'green',
    'light_blue',
    'dark_blue',
    'purple',
    'light_brown',
    'dark_brown',
    'black',
  ];

  String _getTranslatedColor(String color) {
    switch (color.toLowerCase()) {
      case 'yellow':
        return 'Žuti';
      case 'orange':
        return 'Narandžasti';
      case 'red':
        return 'Crveni';
      case 'green':
        return 'Zeleni';
      case 'light_blue':
        return 'Svetlo plavi';
      case 'dark_blue':
        return 'Tamno plavi';
      case 'purple':
        return 'Ljubičasti';
      case 'light_brown':
        return 'Svetlo braon';
      case 'dark_brown':
        return 'Tamno braon';
      case 'black':
        return 'Crni';
      default:
        return '';
    }
  }

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
    final firstNameController = TextEditingController();
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: beltColors
                            .map((color) => GestureDetector(
                                  onTap: () {
                                    beltController.text = color;
                                    (context as Element).markNeedsBuild();
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _getBeltColor(color),
                                      shape: BoxShape.circle,
                                      border: beltController.text == color
                                          ? Border.all(
                                              width: 3, color: Colors.white)
                                          : null,
                                      boxShadow: beltController.text == color
                                          ? [
                                              const BoxShadow(
                                                  color: Colors.black38,
                                                  blurRadius: 4)
                                            ]
                                          : null,
                                    ),
                                    child: beltController.text == color
                                        ? Center(
                                            child: Text(
                                              _getTranslatedColor(
                                                  color)[0], // First letter
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ))
                            .toList(),
                      )
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
              if (firstNameController.text.isEmpty ||
                  lastNameController.text.isEmpty ||
                  beltController.text.isEmpty ||
                  ageController.text.isEmpty ||
                  mailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sva polja su obavezna!')),
                );
                return;
              }
              final newMember = Member(
                  id: DateTime.now().millisecondsSinceEpoch,
                  firstName: firstNameController.text,
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
      case 'white':
        return Colors.grey; // Beli
      case 'yellow':
        return const Color(0xFFFFEB3B); // Žuti
      case 'orange':
        return const Color(0xFFFF9800); // Narandžasti
      case 'red':
        return const Color(0xFFF44336); // Crveni
      case 'green':
        return const Color(0xFF4CAF50); // Zeleni
      case 'light_blue':
        return const Color(0xFF81D4FA); // Svetlo plavi
      case 'dark_blue':
        return const Color(0xFF1565C0); // Tamno plavi
      case 'purple':
        return const Color(0xFF9C27B0); // Ljubičasti
      case 'light_brown':
        return const Color(0xFFBCAAA4); // Svetlo braon
      case 'dark_brown':
        return const Color(0xFF5D4037); // Tamno braon
      case 'black':
        return Colors.black; // Crni
      default:
        return Colors.purple;
    }
  }

  String _getBeltColorAsString(String beltColor) {
    switch (beltColor.toLowerCase()) {
      case 'yellow':
        return 'Žuti';
      case 'orange':
        return 'Narandžasti';
      case 'red':
        return 'Crveni';
      case 'green':
        return 'Zeleni';
      case 'light_blue':
        return 'Svetlo plavi';
      case 'dark_blue':
        return 'Tamno plavi';
      case 'purple':
        return 'Ljubičasti';
      case 'light_brown':
        return 'Svetlo braon';
      case 'dark_brown':
        return 'Tamno braon';
      case 'black':
        return 'Crni';
      default:
        return '';
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
                    trailing: PopupMenuButton<int>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Izmeni'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Obriši'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Pregled dolaska'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 3,
                          child: Row(
                            children: [
                              Icon(Icons.payment, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Clanarina'),
                            ],
                          ),
                        )
                      ],
                      onSelected: (value) {
                        if (value == 0) {
                          _showEditMemberDialog(context, member);
                        } else if (value == 1) {
                          showDialog(
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
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        } else if (value == 2) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              contentPadding: EdgeInsets.zero,
                              content: SingleChildScrollView(
                                child: SizedBox(
                                  width: 330,
                                  height: 540, // You can adjust this
                                  child: AttendanceCalendarDialog(
                                      memberId: members[index].id),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Zatvori'),
                                ),
                              ],
                            ),
                          );
                        } else if (value == 3) {
                          showMonthPickerDialog(context, members[index].id);
                        }
                      },
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
    case 'white':
      return Colors.grey; // Beli
    case 'blue':
      return const Color(0xFF2196F3); // Plavi
    case 'brown':
      return const Color(0xFF795548); // Braon
    case 'yellow':
      return const Color(0xFFFFEB3B); // Žuti
    case 'orange':
      return const Color(0xFFFF9800); // Narandžasti
    case 'red':
      return const Color(0xFFF44336); // Crveni
    case 'green':
      return const Color(0xFF4CAF50); // Zeleni
    case 'light_blue':
      return const Color(0xFF81D4FA); // Svetlo plavi
    case 'dark_blue':
      return const Color(0xFF1565C0); // Tamno plavi
    case 'purple':
      return const Color(0xFF9C27B0); // Ljubičasti
    case 'light_brown':
      return const Color(0xFFBCAAA4); // Svetlo braon
    case 'dark_brown':
      return const Color(0xFF5D4037); // Tamno braon
    case 'black':
      return Colors.black; // Crni
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
    'yellow', // Žuti
    'orange', // Narandžasti
    'red', // Crveni
    'green', // Zeleni
    'light_blue', // Svetlo plavi
    'dark_blue', // Tamno plavi
    'purple', // Ljubičasti
    'light_brown', // Svetlo braon
    'dark_brown', // Tamno braon
    'black' // Crni
  ];

  String _getTranslatedColor(String color) {
    switch (color.toLowerCase()) {
      case 'yellow':
        return 'Žuti';
      case 'orange':
        return 'Narandžasti';
      case 'red':
        return 'Crveni';
      case 'green':
        return 'Zeleni';
      case 'light_blue':
        return 'Svetlo plavi';
      case 'dark_blue':
        return 'Tamno plavi';
      case 'purple':
        return 'Ljubičasti';
      case 'light_brown':
        return 'Svetlo braon';
      case 'dark_brown':
        return 'Tamno braon';
      case 'black':
        return 'Crni';
      default:
        return '';
    }
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Izmeni člana'),
      content: SingleChildScrollView(
        child: Column(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Boja pojasa', style: TextStyle(fontSize: 16)),
                  Wrap(
                    spacing: 8,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: beltColors
                            .map((color) => GestureDetector(
                                  onTap: () {
                                    beltController.text = color;
                                    (context as Element).markNeedsBuild();
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _getBeltColor(color),
                                      shape: BoxShape.circle,
                                      border: beltController.text == color
                                          ? Border.all(
                                              width: 3, color: Colors.white)
                                          : null,
                                      boxShadow: beltController.text == color
                                          ? [
                                              const BoxShadow(
                                                  color: Colors.black38,
                                                  blurRadius: 4)
                                            ]
                                          : null,
                                    ),
                                    child: beltController.text == color
                                        ? Center(
                                            child: Text(
                                              _getTranslatedColor(
                                                  color)[0], // First letter
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ))
                            .toList(),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Odustani'),
        ),
        TextButton(
          onPressed: () {
            if (firstNameController.text.isEmpty ||
                lastNameController.text.isEmpty ||
                beltController.text.isEmpty ||
                ageController.text.isEmpty ||
                mailController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sva polja su obavezna!')),
              );
              return;
            }
            final updatedMember = member.copyWith(
              firstName: firstNameController.text,
              lastName: lastNameController.text,
              beltColor: beltController.text,
              dateOfBirth:
                  DateTime.tryParse(ageController.text) ?? DateTime.now(),
              email: mailController.text,
            );
            context.read<MembersBloc>().add(UpdateMember(updatedMember));
            Navigator.pop(context);
          },
          child: const Text('Sačuvaj', style: TextStyle(color: Colors.blue)),
        ),
      ],
      scrollable: true,
    ),
  );
}
