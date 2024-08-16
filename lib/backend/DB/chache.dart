class Cache<K, V> {
  final _cache = <K, V>{};

  Future<V?> get(K key) async {
    return _cache[key];
  }

  void set(K key, V value) {
    _cache[key] = value;
  }

  void clear() => _cache.clear();
}

final cache = Cache<String, dynamic>();
