import "../service/syllabus_query_result.dart";

class CacheManager {
  // Singletonインスタンスを保持するための変数
  static final CacheManager _instance = CacheManager._internal();

  // プライベートコンストラクタ
  CacheManager._internal();

  // Singletonインスタンスを返すファクトリコンストラクタ
  factory CacheManager() {
    return _instance;
  }

  // ジェネリックなCacheインスタンスを管理
  final _cacheMap = <String, dynamic>{};

  Cache<K, V> getCache<K, V>() {
    final key = '${K.toString()}-${V.toString()}';
    return _cacheMap.putIfAbsent(key, () => Cache<K, V>()) as Cache<K, V>;
  }
}

class Cache<K, V> {
  final _cache = <K, V>{};

  Future<V?> get(K key) async {
    return _cache[key];
  }

  Future<void> set(K key, V value) async {
    _cache[key] = value;
  }

  void clear() => _cache.clear();
}

// CacheManagerのインスタンスを取得
final cacheManager = CacheManager();
final syllabusQueryCache = cacheManager.getCache<String, SyllabusQueryResult>();
