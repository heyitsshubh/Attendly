import 'package:equatable/equatable.dart';

class SyncState extends Equatable {
  final bool isOnline;
  final int pendingWritesCount;

  const SyncState({
    this.isOnline = true,
    this.pendingWritesCount = 0,
  });

  SyncState copyWith({bool? isOnline, int? pendingWritesCount}) {
    return SyncState(
      isOnline: isOnline ?? this.isOnline,
      pendingWritesCount: pendingWritesCount ?? this.pendingWritesCount,
    );
  }

  bool get hasPendingWrites => pendingWritesCount > 0;

  @override
  List<Object> get props => [isOnline, pendingWritesCount];
}
