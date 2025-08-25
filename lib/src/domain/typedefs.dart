typedef ToJson<T> = Map<String, dynamic> Function(T);
typedef FromJson<T> = T Function(Map<String, dynamic>);
