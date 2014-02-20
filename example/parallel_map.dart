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

class DoubleFunc { int call(int n) => 2 * n; }

class SquareFunc { int call(int n) => n * n; }


void main() {
  final stopwatch = new Stopwatch();
  final vs = new Iterable.generate(45, (i) => i + 1);

  print("sum of fib on $vs using classical map");
  stopwatch.start();
  print(vs.map((n) => fib(n)).reduce((a, b) => a + b));
  stopwatch.stop();
  print("Elapsed time: ${stopwatch.elapsed}");

  print("sum of fib on $vs using parallel map");
  stopwatch..reset()..start();
  parallel(vs).pmap(new FibFunc())
              .reduce((a, b) => a + b)
              .then((r) {
                print(r);
                stopwatch.stop();
                print("Elapsed time: ${stopwatch.elapsed}");
              });
}