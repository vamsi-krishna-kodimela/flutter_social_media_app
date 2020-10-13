class SocialUtils {
  static List<String> keyWordGenerator(String key) {
    final List<String> keys = [];

    for (var i = 1; i <= key.length; i++) {
      for (var j = 0; j < key.length; j++) {
        if (j + i > key.length) break;
        var symb = key.substring(j, j + i).toLowerCase();
        if (!keys.contains(symb)) keys.add(symb);
      }
    }

    return keys;
  }
}
