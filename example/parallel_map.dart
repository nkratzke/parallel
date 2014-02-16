import 'package:parallel/parallel.dart';

/**
 * Fibonacci function to have a function
 * generating substantial and measurable runtime.
 */
int fib(int n) {
  if (n == 0) return 1;
  if (n == 1) return 1;
  return fib(n-1) + fib(n-2);
}

String fibStr(int n) => "fib($n) = ${fib(n)}";

/**
 * We mask our normal Fibonacci function as
 * a wannabe function to be passable between isolates.
 */
class FibStr { String call(int n) => "fib($n) == ${ fib(n) }"; }

void main() {
  final stopwatch = new Stopwatch();
  final vs = [40, 41, 42, 43, 44, 45].reversed;

  print("fib of $vs using classical map");
  stopwatch.start();
  print(vs.map((n) => fib(n)).reduce((a, b) => a + b));
  stopwatch.stop();
  print("Elapsed time: ${stopwatch.elapsed}");

  print("fib of $vs using parallel map");
  stopwatch..reset()..start();
  parallel(vs).map(new FibStr()).reduce((a, b) => a + b).then((r) {
    print(r);
    stopwatch.stop();
    print("Elapsed time: ${stopwatch.elapsed}");
    PIterable.close();
  });
}