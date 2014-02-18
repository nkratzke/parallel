import 'package:parallel/parallel.dart';

/**
 * Fibonacci function to have a function
 * generating substantial and measurable runtime.
 */
int fib(int n) {
  if (n == 0) return 0;
  if (n == 1) return 1;
  return fib(n-1) + fib(n-2);
}

/**
 * We mask our normal Fibonacci function as
 * a wannabe function to be passable between isolates.
 */
class FibFunc { int call(int n) => fib(n); }

void main() {
  final stopwatch = new Stopwatch();
  final vs = [40, 41, 42, 43, 44, 45];

  print("sum of fib on $vs using classical map");
  stopwatch.start();
  print(vs.map((n) => fib(n)).reduce((a, b) => a + b));
  stopwatch.stop();
  print("Elapsed time: ${stopwatch.elapsed}");

  print("sum of fib on $vs using parallel map");
  stopwatch..reset()..start();
  parallel(vs).map(new FibFunc()).reduce((a, b) => a + b).then((r) {
    print(r);
    stopwatch.stop();
    print("Elapsed time: ${stopwatch.elapsed}");
  });
}