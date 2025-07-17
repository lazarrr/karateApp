import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // <‑‑ for nice date formatting
import 'package:karate_club_app/src/features/turnament/tournament_bloc_event.dart';
import 'package:karate_club_app/src/features/turnament/tournament_bloc_state.dart';
import 'package:karate_club_app/src/features/turnament/tournametn_bloc.dart';
import 'package:karate_club_app/src/features/turnament/widgets/add_members_to_tournaments.dart';
import 'package:karate_club_app/src/models/member.dart';
import 'package:karate_club_app/src/models/turnament.dart';

class TournamentsPage extends StatelessWidget {
  const TournamentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turniri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTournamentDialog(context),
          )
        ],
      ),
      body: const _TournamentsList(),
    );
  }

  /* ───────────────────────────────── Add‑dialog ─────────────────────────── */

  void _showAddTournamentDialog(BuildContext context,
      {Tournament? tournament}) {
    final nameCtrl = TextEditingController(text: tournament?.name ?? '');
    final locationCtrl =
        TextEditingController(text: tournament?.location ?? '');
    final dateCtrl = TextEditingController(
        text: tournament != null ? _fmt(tournament.date) : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tournament == null ? 'Novi turnir' : 'Izmeni turnir'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Naziv turnira'),
              ),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(labelText: 'Lokacija'),
              ),
              /* date picker */
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: tournament?.date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (d != null) dateCtrl.text = _fmt(d);
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Datum',
                      hintText: 'Izaberite datum',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () {
              if ([nameCtrl, locationCtrl, dateCtrl]
                  .any((c) => c.text.trim().isEmpty)) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Sva polja su obavezna!')),
                );
                return;
              }

              final tour = Tournament(
                id: tournament?.id ?? DateTime.now().millisecondsSinceEpoch,
                name: nameCtrl.text.trim(),
                location: locationCtrl.text.trim(),
                date: DateTime.parse(dateCtrl.text),
              );

              if (tournament == null) {
                ctx.read<TournamentsBloc>().add(AddTournament(tour));
              } else {
                ctx.read<TournamentsBloc>().add(UpdateTournament(tour));
              }
              ctx.read<TournamentsBloc>().add(GetTotalCountOfTournaments());
              ctx.read<TournamentsBloc>().add(LoadTournaments());
              Navigator.pop(ctx);
            },
            child: Text(tournament == null ? 'Dodaj' : 'Sačuvaj'),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
}

/* ───────────────────────────── List & pagination ────────────────────────── */

class _TournamentsList extends StatefulWidget {
  const _TournamentsList();

  @override
  State<_TournamentsList> createState() => _TournamentsListState();
}

class _TournamentsListState extends State<_TournamentsList> {
  List<Tournament> _tournaments = [];
  int _offset = 0;
  static const _pageSize = 8;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<TournamentsBloc>();
    bloc.add(GetTotalCountOfTournaments());
    bloc.add(LoadTournaments(offset: _offset, limit: _pageSize));

    bloc.stream.listen((state) {
      if (state is TotalCountOfTournaments) {
        setState(() => _total = state.count);
      } else if (state is TournamentsLoaded) {
        setState(() => _tournaments = state.tournaments);
      } else if (state is TournamentsError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.message)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _tournaments.length,
            itemBuilder: (ctx, i) {
              final t = _tournaments[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.emoji_events),
                  title: Text(t.name),
                  subtitle: Text(
                      '${t.location} – ${DateFormat('dd.MM.yyyy').format(t.date)}'),
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
                            Icon(Icons.person, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Dodaj učesnike'),
                          ],
                        ),
                      )
                    ],
                    onSelected: (value) async {
                      if (value == 0) {
                        // Call the dialog from the parent widget
                        (context.findAncestorWidgetOfExactType<
                                TournamentsPage>() as TournamentsPage)
                            ._showAddTournamentDialog(context, tournament: t);
                      } else if (value == 1) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Da li ste sigurni?'),
                            content: const Text(
                                'Želite li da obrišete ovaj turnir?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Odustani'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context
                                      .read<TournamentsBloc>()
                                      .add(DeleteTournament(t.id));
                                },
                                child: const Text('Obriši',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      } else if (value == 2) {
                        // fetch selected members
                        final bloc = context.read<TournamentsBloc>();
                        bloc.add(GetMembersOfTournament(t.id));

                        // Wait for the response from the bloc
                        List<Member> currentMembers = [];
                        final subscription = bloc.stream.listen((state) {
                          if (state is MembersOfTournamentLoaded) {
                            currentMembers = state.members;
                          }
                        });

                        // Wait a short moment for the bloc to emit the state
                        await Future.delayed(const Duration(milliseconds: 200));
                        await subscription.cancel();

                        final selectedMembers =
                            await Navigator.push<List<Member>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddMembersToTournamentPage(
                              initiallySelectedMembers: currentMembers,
                            ),
                          ),
                        );

                        if (selectedMembers != null) {
                          // Do something with the selected members
                          // Determine which members were added or removed
                          final previousIds =
                              currentMembers.map((m) => m.id).toSet();
                          final selectedIds =
                              selectedMembers.map((m) => m.id).toSet();

                          final addedIds =
                              selectedIds.difference(previousIds).toList();
                          final removedIds =
                              previousIds.difference(selectedIds).toList();

                          if (addedIds.isNotEmpty) {
                            context.read<TournamentsBloc>().add(
                                  AddMembersToTournament(addedIds, t.id),
                                );
                          }
                          if (removedIds.isNotEmpty) {
                            context.read<TournamentsBloc>().add(
                                  RemoveMembersFromTournament(removedIds, t.id),
                                );
                          }
                        }
                      }
                    },
                  ),
                  //  you can add edit/delete here later
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
                onPressed: _offset > 0
                    ? () {
                        setState(() => _offset -= _pageSize);
                        context.read<TournamentsBloc>().add(
                              LoadTournaments(
                                  offset: _offset, limit: _pageSize),
                            );
                      }
                    : null,
                child: const Text('Prethodna'),
              ),
              Text('Strana ${(_offset ~/ _pageSize) + 1}'),
              TextButton(
                onPressed: (_offset + _pageSize) < _total
                    ? () {
                        setState(() => _offset += _pageSize);
                        context.read<TournamentsBloc>().add(
                              LoadTournaments(
                                  offset: _offset, limit: _pageSize),
                            );
                      }
                    : null,
                child: const Text('Sledeća'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ─────────────────────────────── Helpers ──────────────────────────────── */

String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
