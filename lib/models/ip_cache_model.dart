class IpCacheModel {
  List<Map<String, String>> get ipCache => _ipCache;

  final List<Map<String, String>> _ipCache = [];

  void addIpCache({
    required String ip,
    required String deviceId,
  }) {
    _ipCache.add(
      {
        'ip': ip,
        'deviceId': deviceId,
      },
    );
  }

  String getIpCache(String deviceId) {
    final index =
        _ipCache.indexWhere((element) => element['deviceId'] == deviceId);
    if (index == -1) {
      return '';
    }
    return _ipCache[index]['ip']!;
  }
}
