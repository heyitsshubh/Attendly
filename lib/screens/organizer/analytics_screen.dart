import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/event.dart';
import '../../theme/app_theme.dart';
import '../../blocs/attendee/attendee_bloc.dart';
import '../../blocs/attendee/attendee_state.dart';
import '../../services/export_service.dart';

class AnalyticsScreen extends StatelessWidget {
  final EventModel event;

  const AnalyticsScreen({super.key, required this.event});

  Future<void> _exportData(BuildContext context, AttendeeState state) async {
    if (state is AttendeesLoaded) {
      try {
        final exportService = ExportService();
        final path = await exportService.exportAttendeesToCSV(
            state.attendees, event.name);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exported to: $path'),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to export: $e'),
              backgroundColor: AppTheme.primaryRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
        elevation: 0,
      ),
      body: BlocBuilder<AttendeeBloc, AttendeeState>(
        builder: (context, state) {
          if (state is AttendeeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AttendeesLoaded) {
            final total = state.attendees.length;
            final checkedIn = state.attendees.where((a) => a.checkedIn).length;
            final pending = total - checkedIn;

            final hasData = total > 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- STAT CARDS ---
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Tickets',
                          value: total.toString(),
                          icon: Icons.confirmation_number_rounded,
                          color: AppTheme.primaryRedDeep,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Checked In',
                          value: checkedIn.toString(),
                          icon: Icons.check_circle_rounded,
                          color: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Pending',
                          value: pending.toString(),
                          icon: Icons.hourglass_empty_rounded,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- PIE CHART ---
                  if (hasData)
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Check-in Ratio',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.darkText : AppTheme.lightText,
                            ),
                          ),
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 50,
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green.shade600,
                                    value: checkedIn.toDouble(),
                                    title: '$checkedIn',
                                    radius: 60,
                                    titleStyle: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orange.shade600,
                                    value: pending.toDouble(),
                                    title: '$pending',
                                    radius: 60,
                                    titleStyle: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      height: 300,
                      alignment: Alignment.center,
                      child: Text('No attendees to analyze.', style: Theme.of(context).textTheme.titleMedium),
                    ),

                  const SizedBox(height: 48),

                  // --- EXPORT BUTTON ---
                  ElevatedButton.icon(
                    onPressed: () => _exportData(context, state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.download_rounded),
                    label: Text(
                      'Export to CSV',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Unable to load analytics.'));
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
            ),
          ),
        ],
      ),
    );
  }
}
