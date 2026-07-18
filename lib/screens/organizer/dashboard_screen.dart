import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/event/event_bloc.dart';
import '../../blocs/event/event_event.dart';
import '../../blocs/event/event_state.dart';
import 'create_event_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<EventBloc>().add(LoadEventsRequested(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventsLoaded) {
            if (state.events.isEmpty) {
              return const Center(child: Text('No events created yet.'));
            }
            return ListView.builder(
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${event.location}\n${event.startTime.toString().substring(0, 16)}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to Event Details (Feature 4)
                    },
                  ),
                );
              },
            );
          } else if (state is EventError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Initializing...'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
      ),
    );
  }
}
