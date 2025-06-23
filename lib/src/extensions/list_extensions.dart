extension ListExtensions<T> on List<T>{


  List<T> addImmutable(T item) {
    return [
      ...this,
      item,
    ];
  }

  List<T> removeImmutable(T item) {
    final index =indexOf(item);
    final newList = <T>[
      ...sublist(0, index),
      ...sublist(index + 1),
    ];
    return newList;
  }

  List<T> replaceImmutable(T oldItem, T newItem) {
    final index = indexOf(oldItem);
    if (index < 0) return List.of(this); // oldItemがなければそのままコピー
    return [
      ...sublist(0, index),
      newItem,
      ...sublist(index + 1),
    ];
  }
  List<T> removeLastImmutable() {
    if (isEmpty) return List.of(this);
    return sublist(0, length - 1);
  }
}

extension IterableExtensions<T> on Iterable<T>{
  T? lastWhereOrNull(bool Function(T) test) {
    for (final item in toList().reversed) {
      if (test(item)) return item;
    }
    return null;
  }
}