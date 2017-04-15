// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:dart2js_matrix/dart2js_matrix.dart';
import 'package:path/path.dart' as p;
import 'package:pool/pool.dart';

final _uri = 'https://github.com/dart-lang/angular2_components_example';

final _theMap = {
  new GitPkg('angular2', 'https://github.com/dart-lang/angular2'): const {
    '3.0.0-beta+1': '04-14', // april 14 release
    '719c573a07a': '04-15-more-final',
    '18c7f6a49de8b': '04-15-private-dupe-map'
  },
  new GitPkg('angular2_components',
      'https://github.com/dart-lang/angular2_components'): const {
    'v0.4.1-alpha': '04-04', // april 4 release
    '15de670dec3f': '04-15-explicit-type',
    'c5973289279': '04-15-remove-thing'
  }
};

String _quotedList(Iterable things) => things.map((i) {
      if (i is num) {
        return i;
      } else {
        return '"$i"';
      }
    }).join(', ');

main(List<String> arguments) async {
  var sets = getOverrideSets(_theMap);

  var pkgHeaderValues = _theMap.keys.toList();
  var pkgHeaders = pkgHeaderValues.map((gp) => gp.pkgName).toList();

  var rows = [];

  var row = []..addAll(pkgHeaders)..addAll(['size', 'gzip size']);
  rows.add(_quotedList(row));

  var pool = new Pool(Platform.numberOfProcessors ~/ 2);

  var count = 0;
  await Future.wait(sets.map((s) async {
    var resource = await pool.request();
    var myCount = (++count);
    print("** Starting $myCount");
    try {
      var result = await _doIt(_uri, s);

      var items = []
        ..addAll(pkgHeaderValues.map((h) {
          var versionString = s[h];

          // now get the pretty name!
          var pkg = _theMap[h][s[h]];
          var version = s[h];
          return "${_theMap[h][version]}_$version";
        }))
        ..addAll([result.size, result.gzipSize]);

      rows.add(_quotedList(items));
    } finally {
      resource.release();
      print("** Finished $myCount");
    }
  }), eagerError: true);

  for (var r in rows) {
    print(r);
  }
}

class Result {
  final int size;
  final int gzipSize;

  Result(this.size, this.gzipSize);

  @override
  String toString() => 'Size: ${prettyInt(size)}, GZip: ${prettyInt(gzipSize)}';
}

Future<Result> _doIt(String repoUri, Map<GitPkg, String> overrides,
    {String ref}) async {
  // temp dir
  var tempDir = await Directory.systemTemp.createTemp(
      'dart2js_matrix.${new DateTime.now().millisecondsSinceEpoch}.');

  try {
    // sync repo
    stderr.writeln("syncing repo - $overrides");
    var result = await _runProc('git', ['clone', repoUri, '.'], tempDir.path);
    //print(result.stdout);

    if (ref != null) {
      result = await _runProc(
          'git', ['checkout', '-b', 'working', ref], tempDir.path);
    }

    // apply dependency overrides – if desired
    await _updatePubspec(p.join(tempDir.path, 'pubspec.yaml'), overrides);

    // pub get
    stderr.writeln("pub get - $overrides");
    result = await _runProc('pub', ['get'], tempDir.path);
    //print(result.stdout);

    // pub build web
    stderr.writeln("pub build web - $overrides");
    result = await _runProc('pub', ['build', 'web'], tempDir.path);
    //print(result.stdout);

    // find the output js file
    var buildDir = new Directory(p.join(tempDir.path, 'build', 'web'));
    var jsFile = await buildDir
            .list()
            .singleWhere((fse) => fse is File && fse.path.endsWith('.dart.js'))
        as File;

    // run gzip – get the gzipped size
    stderr.writeln('gzipping - $overrides');
    result = await _runProc('gzip', ['-k', jsFile.path], buildDir.path);
    var gzFile = await buildDir.list().singleWhere(
        (fse) => fse is File && fse.path.endsWith('.dart.js.gz')) as File;

    return new Result(jsFile.statSync().size, gzFile.statSync().size);
  } finally {
    //print(tempDir.path);
    await tempDir.delete(recursive: true);
  }
}

Future _updatePubspec(String pubspecPath, Map<GitPkg, String> overrides) async {
  if (overrides.isEmpty) {
    return;
  }

  var pubspecFile = new File(pubspecPath);

  var buffer = new StringBuffer(await pubspecFile.readAsString());
  buffer.writeln('dependency_overrides:');
  overrides.forEach((pkg, ref) {
    buffer.writeln('''  ${pkg.pkgName}:
    git:
      url: ${pkg.gitUrl}
      ref: $ref''');
  });

  await pubspecFile.writeAsString(buffer.toString());
}

const _pubEnv = const <String, String>{
  'PUB_ENVIRONMENT': 'kevmoo.dart2js_matrix'
};

Future<ProcessResult> _runProc(
    String proc, List<String> args, String workingDir) async {
  var result = await Process.run(proc, args,
      workingDirectory: workingDir, environment: _pubEnv);

  if (result.exitCode != 0) {
    print('In dir $workingDir');
    throw new ProcessException(
        proc, args, [result.stdout, result.stderr].join('\n'), result.exitCode);
  }

  return result;
}
