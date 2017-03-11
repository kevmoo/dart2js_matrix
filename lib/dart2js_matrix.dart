String prettyInt(int value) {
  var chunks = <String>[];
  var strValue = value.toString();

  while (strValue.length > 3) {
    chunks.add(strValue.substring(strValue.length - 3));
    strValue = strValue.substring(0, strValue.length - 3);
  }
  chunks.add(strValue);

  return chunks.reversed.join(',');
}

String asPercent(num v) => '${(100 * v).toStringAsFixed(1)}%'.padLeft(6);
