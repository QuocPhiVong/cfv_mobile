extension ParseModel on Map<String, dynamic> {
  String parseString(String key) {
    var result = '';
    if (isNotEmpty && containsKey(key)) {
      result = this[key].toString();
      if (result.toLowerCase() == 'null') return '';
    }
    return result;
  }

  int parseInt(String key) {
    String resultStr = parseString(key);
    return int.tryParse(resultStr) ?? 0;
  }

  double parseDouble(String key) {
    String resultStr = parseString(key);
    return double.tryParse(resultStr) ?? 0;
  }

  Map<String, dynamic> parseMap(String key) {
    Map<String, dynamic> result = <String, dynamic>{};
    if (isNotEmpty && containsKey(key)) {
      result = Map<String, dynamic>.from(this[key] ?? <String, dynamic>{});
    }
    return result;
  }

  List<Map<String, dynamic>> parseList(String key) {
    if (isNotEmpty && containsKey(key) && this[key] is List) {
      List<Map<String, dynamic>> output = List<Map<String, dynamic>>.from((this[key] ?? []).map((e) => e));
      return output;
    }
    return [];
  }
}
