import 'package:dart2js_matrix/dart2js_matrix.dart';
import 'package:test/test.dart';

final _cases = const {};

final _a = new GitPkg('a', 'a');
final _b = new GitPkg('b', 'b');
final _c = new GitPkg('c', 'c');
final _d = new GitPkg('d', 'd');

main() {
  test('simple', () {
    var output = getOverrideSets({});

    expect(output, isEmpty);
  });

  test("one config, new values", () {
    var output = getOverrideSets({
      _a: ['1', '2']
    });

    expect(
        output,
        unorderedEquals([
          {_a: '1'},
          {_a: '2'}
        ]));
  });

  test("two configs, one value", () {
    var output = getOverrideSets({
      _a: ['1'],
      _b: ['2']
    });

    expect(output, [
      {_a: '1', _b: '2'}
    ]);
  });

  test("two configs, two values", () {
    var output = getOverrideSets({
      _a: ['1', '2'],
      _b: ['3', '4']
    });

    expect(
        output,
        unorderedEquals([
          {_a: '1', _b: '3'},
          {_a: '1', _b: '4'},
          {_a: '2', _b: '3'},
          {_a: '2', _b: '4'}
        ]));
  });

  test("two configs, two values", () {
    var output = getOverrideSets({
      _a: ['1', '2'],
      _b: ['3', '4']
    });

    expect(
        output,
        unorderedEquals([
          {_a: '1', _b: '3'},
          {_a: '1', _b: '4'},
          {_a: '2', _b: '3'},
          {_a: '2', _b: '4'}
        ]));
  });

  test("complex", () {
    var output = getOverrideSets({
      _a: ['a1', 'a2'],
      _b: ['b1'],
      _c: [],
      _d: ['d1', 'd2', 'd3']
    });

    expect(
        output,
        unorderedEquals([
          {_a: 'a1', _b: 'b1', _d: 'd1'},
          {_a: 'a1', _b: 'b1', _d: 'd2'},
          {_a: 'a1', _b: 'b1', _d: 'd3'},
          {_a: 'a2', _b: 'b1', _d: 'd1'},
          {_a: 'a2', _b: 'b1', _d: 'd2'},
          {_a: 'a2', _b: 'b1', _d: 'd3'},
        ]));
  });
}
