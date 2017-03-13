class GitPkg {
  final String pkgName;
  final String gitUrl;

  GitPkg(this.pkgName, this.gitUrl);

  @override
  String toString() => '$pkgName ($gitUrl)';

  @override
  bool operator ==(other) =>
      other is GitPkg && other.pkgName == pkgName && other.gitUrl == gitUrl;

  @override
  int get hashCode => pkgName.hashCode ^ 37 * gitUrl.hashCode;
}

List<Map<GitPkg, String>> getOverrideSets(Map<GitPkg, List<String>> theMap) {
  var sets = <Map<GitPkg, String>>[];

  theMap.forEach((pkg, refs) {
    var newSets = <Map<GitPkg, String>>[];

    if (sets.isEmpty) {
      for (var r in refs) {
        newSets.add(<GitPkg, String>{pkg: r});
      }
    } else {
      if (refs.isEmpty) {
        return;
      }

      for (var s in sets) {
        for (var r in refs) {
          var newMap = new Map<GitPkg, String>.from(s);
          newMap[pkg] = r;

          newSets.add(newMap);
        }
      }
    }

    sets = newSets;
  });

  return sets;
}

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
