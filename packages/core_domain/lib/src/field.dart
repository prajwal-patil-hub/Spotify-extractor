import 'package:meta/meta.dart';

/// A patch field that distinguishes "leave unchanged" from "set to a value"
/// — including setting a nullable value to null (e.g. clearing a playlist
/// description). Plain nullable fields cannot express that difference.
@immutable
sealed class Field<T> {
  const Field();

  /// Leave the current value untouched.
  const factory Field.keep() = KeepField<T>;

  /// Replace the current value with [value].
  const factory Field.set(T value) = SetField<T>;

  bool get isSet => this is SetField<T>;

  /// Returns [current] for [KeepField], the new value for [SetField].
  T resolve(T current) => switch (this) {
    KeepField<T>() => current,
    SetField<T>(:final value) => value,
  };
}

final class KeepField<T> extends Field<T> {
  const KeepField();

  @override
  bool operator ==(Object other) => other is KeepField<T>;

  @override
  int get hashCode => (KeepField<T>).hashCode;
}

final class SetField<T> extends Field<T> {
  const SetField(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      other is SetField<T> && other.value == value;

  @override
  int get hashCode => Object.hash(SetField<T>, value);
}
