import 'dart:async';

/// A value that streams its current state, then every change: a stand-in
/// for a Drift watch in widget tests.
class Live<T> {
  new(this._value);

  T _value;
  final _changes = StreamController<T>.broadcast();

  T get value => _value;
  set value(T next) {
    _value = next;
    _changes.add(next);
  }

  Stream<T> get stream {
    StreamSubscription<T>? changes;
    late final StreamController<T> out;
    out = StreamController<T>(
      onListen: () {
        out.add(_value);
        changes = _changes.stream.listen(out.add);
      },
      onCancel: () {
        unawaited(changes?.cancel());
      },
    );
    return out.stream;
  }
}
