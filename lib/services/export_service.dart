import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/attendee.dart';

class ExportService {
  Future<String> exportAttendeesToCSV(List<AttendeeModel> attendees, String eventName) async {
    // 1. Prepare data rows
    List<List<dynamic>> rows = [];
    
    // Header
    rows.add([
      'Name',
      'Email',
      'Phone',
      'Ticket ID',
      'Checked In',
      'Checked In At',
      'Checked In By',
      'Registered At'
    ]);

    // Data
    for (var attendee in attendees) {
      rows.add([
        attendee.name,
        attendee.email,
        attendee.phone,
        attendee.ticketId,
        attendee.checkedIn ? 'Yes' : 'No',
        attendee.checkedInAt?.toIso8601String() ?? 'N/A',
        attendee.checkedInBy ?? 'N/A',
        attendee.registeredAt.toIso8601String(),
      ]);
    }

    // 2. Convert to CSV string
    String csvData = const ListToCsvConverter().convert(rows);

    // 3. Save file
    Directory? directory;
    if (Platform.isAndroid) {
      // Use external storage for Android so it's easily accessible
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not find directory to save CSV.');
    }

    final sanitizedEventName = eventName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${directory.path}/attendees_${sanitizedEventName}_$timestamp.csv';

    final file = File(path);
    await file.writeAsString(csvData);

    return path;
  }
}
