import 'package:flutter/material.dart';
import 'ticket_screen.dart';

class TicketSearchScreen extends StatefulWidget {
  const TicketSearchScreen({super.key});

  @override
  State<TicketSearchScreen> createState() => _TicketSearchScreenState();
}

class _TicketSearchScreenState extends State<TicketSearchScreen> {
  final _ticketIdController = TextEditingController();

  @override
  void dispose() {
    _ticketIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find My Ticket'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.qr_code_scanner, size: 64, color: Colors.deepPurple),
                const SizedBox(height: 24),
                const Text(
                  'Enter your Ticket ID below to access your scannable QR ticket.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _ticketIdController,
                  decoration: const InputDecoration(
                    labelText: 'Ticket ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final ticketId = _ticketIdController.text.trim();
                    if (ticketId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketScreen(ticketId: ticketId),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('View Ticket', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
