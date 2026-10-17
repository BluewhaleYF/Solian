/// A fixed-size, FIFO set of string ids.
///
/// Push delivery is at-least-once: the gateway re-sends a `messages.*` frame
/// until the client acks it, so the same message id can arrive twice. Callers
/// use this to skip the *side effects* of a repeat (unread counters, toasts)
/// while still letting the repeat refresh stored state.
///
/// The bound is what makes it safe: the set only answers "did I already act on
/// this id", and every counter it guards is reconciled from REST anyway, so an
/// id that falls out of the window can only cost a duplicate increment that the
/// next server sync corrects.
class BoundedIdSet {
  BoundedIdSet(this.maxLength) : assert(maxLength > 0);

  final int maxLength;
  final Set<String> _seen = <String>{};

  int get length => _seen.length;

  bool contains(String id) => _seen.contains(id);

  /// Records [id] and returns true when it had not been recorded yet.
  bool add(String id) {
    final isNew = _seen.add(id);
    if (_seen.length > maxLength) {
      // LinkedHashSet iterates in insertion order, so the first element is the
      // oldest id.
      _seen.remove(_seen.first);
    }
    return isNew;
  }

  void clear() => _seen.clear();
}
