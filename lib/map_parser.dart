extension ParseModel on Map<String, dynamic> {
  String? parseString(String key) {
    if (isNotEmpty && containsKey(key) && this[key] != null) {
      final value = this[key];
      if (value is String) {
        return value.isEmpty ? null : value;
      }
      final result = value.toString();
      return result.toLowerCase() == 'null' ? null : result;
    }
    return null;
  }

  int? parseInt(String key) {
    if (isNotEmpty && containsKey(key) && this[key] != null) {
      final value = this[key];
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  double? parseDouble(String key) {
    if (isNotEmpty && containsKey(key) && this[key] != null) {
      final value = this[key];
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  bool? parseBool(String key) {
    if (isNotEmpty && containsKey(key) && this[key] != null) {
      final value = this[key];
      if (value is bool) return value;
      if (value is String) {
        final lowerValue = value.toLowerCase();
        if (lowerValue == 'true') return true;
        if (lowerValue == 'false') return false;
      }
    }
    return null;
  }

  DateTime? parseDateTime(String key) {
    final dateString = parseString(key);
    if (dateString != null) {
      return DateTime.tryParse(dateString);
    }
    return null;
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
