import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../blocs/ticket/ticket_bloc.dart';
import '../../blocs/ticket/ticket_event.dart';
import '../../blocs/ticket/ticket_state.dart';
import '../../theme/app_theme.dart';

class TicketScreen extends StatefulWidget {
  final String ticketId;

  const TicketScreen({super.key, required this.ticketId});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TicketBloc>().add(FetchTicketRequested(widget.ticketId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ticket'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppTheme.darkText : AppTheme.lightText,
      ),
      extendBodyBehindAppBar: true,
      body: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          if (state is TicketLoading || state is TicketInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TicketError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 56, color: AppTheme.error),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          if (state is TicketNotFound) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 64, color: AppTheme.lightSubtext),
                  const SizedBox(height: 16),
                  Text('Ticket not found',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Please check your Ticket ID',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }

          if (state is TicketLoaded) {
            final attendee = state.attendee;
            final event = state.event;

            return Stack(
              children: [
                // Gradient top background
                Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),

                        // Event header
                        Text(
                          event.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              event.location,
                              style: GoogleFonts.outfit(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.calendar_today_outlined,
                                color: Colors.white70, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              '${event.startTime.day}/${event.startTime.month}/${event.startTime.year}',
                              style: GoogleFonts.outfit(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ── Ticket card ──────────────────────────────────────
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkCard
                                : AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Top section
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                                child: Column(
                                  children: [
                                    Text(
                                      attendee.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AppTheme.darkText
                                            : AppTheme.lightText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      attendee.email,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppTheme.darkSubtext
                                            : AppTheme.lightSubtext,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Dotted divider with notches
                              _TicketDivider(isDark: isDark),

                              // QR code section
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: QrImageView(
                                        data: attendee.ticketId,
                                        version: QrVersions.auto,
                                        size: 200,
                                        backgroundColor: Colors.white,
                                        eyeStyle: const QrEyeStyle(
                                          eyeShape: QrEyeShape.square,
                                          color: Color(0xFF4F46E5),
                                        ),
                                        dataModuleStyle:
                                            const QrDataModuleStyle(
                                          dataModuleShape:
                                              QrDataModuleShape.circle,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      attendee.ticketId.substring(0, 16).toUpperCase(),
                                      style: GoogleFonts.sourceCodePro(
                                        fontSize: 11,
                                        letterSpacing: 1.5,
                                        color: isDark
                                            ? AppTheme.darkSubtext
                                            : AppTheme.lightSubtext,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Status badge
                              Container(
                                margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 20),
                                decoration: BoxDecoration(
                                  gradient: attendee.checkedIn
                                      ? AppTheme.successGradient
                                      : AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      attendee.checkedIn
                                          ? Icons.check_circle_rounded
                                          : Icons.confirmation_number_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      attendee.checkedIn
                                          ? 'Already Checked In'
                                          : 'Valid for Entry — Present at Gate',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TicketDivider extends StatelessWidget {
  final bool isDark;

  const _TicketDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left notch
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
          transform: Matrix4.translationValues(-12, 0, 0),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final dashCount = (constraints.maxWidth / 10).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    dashCount,
                    (_) => Container(
                      width: 5,
                      height: 1.5,
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Right notch
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
          transform: Matrix4.translationValues(12, 0, 0),
        ),
      ],
    );
  }
}
