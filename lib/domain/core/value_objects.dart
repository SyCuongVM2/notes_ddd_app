import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'errors.dart';
import 'failures.dart';

abstract class ValueObject<T> {
  const ValueObject();
  Either<ValueFailure<T>, T> get value;

  /// Throws [UnexpectedValueError] containing the [ValueFailure]
  T getOrCrash() {
    // id = identity - same as writing (r) => r
    return value.fold((f) => throw UnexpectedValueError(f), id);
  }

  bool isValid() => value.isRight();

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Value($value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ValueObject<T> && 
      other.value == value;
  }
}

class UniqueId extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  factory UniqueId() {
    return UniqueId._(
      right(const Uuid().v1()),
    );
  }

  factory UniqueId.fromUniqueString(String uniqueId) {
    return UniqueId._(
      right(uniqueId),
    );
  }

  const UniqueId._(this.value);
}