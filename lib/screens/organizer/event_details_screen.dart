import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../../models/event.dart';
import '../../models/attendee.dart';
import '../../blocs/attendee/attendee_bloc.dart';
import '../../blocs/attendee/attendee_event.dart';
import '../../blocs/attendee/attendee_state.dart';
import '../attendee/ticket_screen.dart';
import 'scanner_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AttendeeBloc>().add(LoadAttendeesRequested(widget.event.id));
  }

  Future<void> _importCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final input = file.openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(CsvDecoder())
            .toList();

        // Assuming CSV format: Name, Email, Phone
        if (fields.isEmpty) return;
        
        final List<AttendeeModel> newAttendees = [];
        const uuid = Uuid();
        
        // Skip header row if exists
        int startIndex = (fields[0][0].toString().toLowerCase().contains('name')) ? 1 : 0;
        
        for (int i = startIndex; i < fields.length; i++) {
          final row = fields[i];
          if (row.length >= 3) {
            newAttendees.add(
              AttendeeModel(
                id: '', // Firestore will generate
                name: row[0].toString(),
                email: row[1].toString(),
                phone: row[2].toString(),
                ticketId: uuid.v4(),
                registeredAt: DateTime.now(),
              )
            );
          }
        }

        if (newAttendees.isNotEmpty && mounted) {
          context.read<AttendeeBloc>().add(
            BulkImportAttendeesRequested(widget.event.id, newAttendees)
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing CSV: $e')),
        );
      }
    }
  }

  void _showAddAttendeeDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Attendee'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newAttendee = AttendeeModel(
                    id: '',
                    name: nameController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    ticketId: const Uuid().v4(),
                    registeredAt: DateTime.now(),
                  );
                  context.read<AttendeeBloc>().add(
                    AddAttendeeRequested(widget.event.id, newAttendee)
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import CSV',
            onPressed: _importCSV,
          ),
        ],
      ),
      body: BlocConsumer<AttendeeBloc, AttendeeState>(
        listener: (context, state) {
          if (state is AttendeeOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AttendeeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AttendeeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendeesLoaded) {
            if (state.attendees.isEmpty) {
              return const Center(child: Text('No attendees yet.'));
            }
            return ListView.builder(
              itemCount: state.attendees.length,
              itemBuilder: (context, index) {
                final attendee = state.attendees[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: attendee.checkedIn ? Colors.green : Colors.grey,
                    child: Icon(
                      attendee.checkedIn ? Icons.check : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(attendee.name),
                  subtitle: Text(attendee.email),
                  trailing: Text(
                    attendee.ticketId.substring(0, 8),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketScreen(ticketId: attendee.ticketId),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('Initializing...'));
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'scan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScannerScreen(event: widget.event),
                ),
              );
            },
            tooltip: 'Scan Tickets',
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: _showAddAttendeeDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Attendee'),
          ),
        ],
      ),
    );
  }
}
