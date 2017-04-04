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
      _a: {'1': 'a', '2': 'b'}
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
      _a: {'1': 'a'},
      _b: {'2': 'b'}
    });

    expect(output, [
      {_a: '1', _b: '2'}
    ]);
  });

  test("two configs, two values", () {
    var output = getOverrideSets({
      _a: {'1': 'a', '2': 'b'},
      _b: {'3': 'c', '4': 'd'}
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
      _a: {'1': 'a', '2': 'b'},
      _b: {'3': 'c', '4': 'd'}
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
      _a: {'a1': 'a', 'a2': 'b'},
      _b: {'b1': 'c'},
      _c: {},
      _d: {'d1': 'a', 'd2': 'b', 'd3': 'c'}
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
