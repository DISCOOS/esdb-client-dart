import 'dart:core';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';

/// A class referring to a potential logical
/// record position in the Event Store transaction file.
class LogPosition {
  /// Constructs a position with the given commit and prepare positions.
  /// It is not guaranteed that the position is actually the start of a
  /// record in the transaction file.
  ///
  /// The commit position cannot be less than the prepare position.
  const LogPosition._(this.commitPosition, this.preparePosition);

  /// Position representing the start of the transaction file
  static LogPosition start = LogPosition._(Int64.ZERO, Int64.ZERO);

  /// Position representing the end of the transaction file
  static LogPosition end = LogPosition._(Int64(-1), Int64(-1));

  /// Constructs a position with the given commit and prepare positions.
  /// It is not guaranteed that the position is actually the start of a
  /// record in the transaction file.
  ///
  /// The commit position cannot be less than the prepare position.
  factory LogPosition.checked(Int64 commitPosition, Int64 preparePosition) {
    if (commitPosition < preparePosition) {
      throw GrpcError.outOfRange(
        'The commit position cannot be less than the prepare position',
      );
    }

    if (commitPosition > Int64.MAX_VALUE && commitPosition != Int64.MAX_VALUE) {
      throw GrpcError.outOfRange(
        'The commit position larger than Int64.MAX_VALUE',
      );
    }

    if (preparePosition > Int64.MAX_VALUE &&
        preparePosition != Int64.MAX_VALUE) {
      throw GrpcError.outOfRange(
        'The prepare position larger than Int64.MAX_VALUE',
      );
    }
    return LogPosition._(commitPosition, preparePosition);
  }

  /// The commit position of the record
  final Int64 commitPosition;

  /// The prepare position of the record.
  final Int64 preparePosition;

  /// Compares whether this &lt; p2.
  bool operator <(LogPosition p2) =>
      commitPosition < p2.commitPosition ||
      commitPosition == p2.commitPosition &&
          preparePosition < p2.preparePosition;

  /// Compares whether this &gt; p2.
  bool operator >(LogPosition p2) =>
      commitPosition > p2.commitPosition ||
      commitPosition == p2.commitPosition &&
          preparePosition > p2.preparePosition;

  /// Compares whether this &gt;= p2.
  bool operator >=(LogPosition p2) => this > p2 || this == p2;

  /// Compares whether this &lt;= p2.
  bool operator <=(LogPosition p2) => this < p2 || this == p2;

  /// Compare this to other [LogPosition]
  int compareTo(LogPosition other) => this == other
      ? 0
      : this > other
          ? 1
          : -1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogPosition &&
          runtimeType == other.runtimeType &&
          commitPosition == other.commitPosition &&
          preparePosition == other.preparePosition;

  @override
  int get hashCode => commitPosition.hashCode ^ preparePosition.hashCode;

  @override
  String toString() {
    return '$runtimeType{commitPosition: $commitPosition, preparePosition: $preparePosition}';
  }
}
