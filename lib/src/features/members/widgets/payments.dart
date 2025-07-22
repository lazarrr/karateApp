import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc_event.dart';
import 'package:karate_club_app/src/features/members/members_bloc_state.dart';

void showMonthPickerDialog(BuildContext context, int memberId) {
  int? selectedMonth; // Stores selected month index (0-11)
  final now = DateTime.now();
  final currentMonth = now.month - 1; // Convert to 0-11 index

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Članarina',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: MonthCloudPicker(
          currentMonth: currentMonth,
          onSelected: (month) => selectedMonth = month,
          memberId: memberId,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Odustani', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedMonth == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Niste izabrali nijedan mesec')),
              );
              return;
            }
            context.read<MembersBloc>().add(AddPayment(
                  memberId,
                  selectedMonth!, // Pass as list with single month
                ));
            Navigator.pop(context);
          },
          child: const Text('Sačuvaj'),
        ),
      ],
    ),
  );
}

class MonthCloudPicker extends StatefulWidget {
  final int currentMonth;
  final Function(int) onSelected;
  final int memberId;

  const MonthCloudPicker(
      {super.key,
      required this.currentMonth,
      required this.onSelected,
      required this.memberId});

  @override
  State<MonthCloudPicker> createState() => _MonthCloudPickerState();
}

class _MonthCloudPickerState extends State<MonthCloudPicker> {
  int? selectedMonth;
  late final List<bool> enabledMonths;
  late final List<int> selectedMonths;

  final monthNames = [
    'Januar',
    'Februar',
    'Mart',
    'April',
    'Maj',
    'Jun',
    'Jul',
    'Avgust',
    'Septembar',
    'Oktobar',
    'Novembar',
    'Decembar'
  ];

  @override
  void initState() {
    super.initState();
    context.read<MembersBloc>().add(ReadAllPayments(widget.memberId));
    context.read<MembersBloc>().stream.listen((state) {
      if (state is PaymentsLoaded) {
        setState(() {
          selectedMonths = state.payments;
          enabledMonths = List.generate(
              12,
              (index) =>
                  index <= widget.currentMonth &&
                  !selectedMonths.contains(index));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(12, (index) {
            final isSelected = selectedMonth == index;
            final isEnabled = enabledMonths[index];
            final isPayed = selectedMonths.contains(index);

            return GestureDetector(
              onTap: isEnabled
                  ? () {
                      setState(() {
                        selectedMonth = isSelected ? null : index;
                      });
                      widget
                          .onSelected(selectedMonth ?? -1); // -1 if deselected
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : isEnabled
                          ? Colors.grey[200]
                          : isPayed
                              ? Colors.blue[300]
                              : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isEnabled
                            ? Colors.grey[300]!
                            : isPayed
                                ? Colors.blue[300]!
                                : Colors.grey[200]!,
                    width: 1.5,
                  ),
                  boxShadow: isEnabled
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  monthNames[index],
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isEnabled
                            ? Colors.grey[700]
                            : isPayed
                                ? Colors.white
                                : Colors.grey[400],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          selectedMonth == null
              ? 'Izaberite mesec za plaćanje'
              : 'Izabran: ${monthNames[selectedMonth!]}',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }
}
