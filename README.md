# Parallel map for Dart #

Dart programs run in a single isolate by default. Although Dart provides 
several asynchronous programming techniques like Futures and Streams Dart
does not use capacities of modern multicore processors by default.

This package provides a parallel map function <code>pmap</code>
for easy parallelization. Let us assume you want to
execute computational intensive tasks in parallel.

For example applying the fibonacci function

```
int fib(int n) {
  if (n == 0) return 0;
  if (n == 1) return 1;
  return fib(n-1) + fib(n-2);
}
```

to a list of values

```
final vs = [40, 41, 42, 43, 44, 45];
```

you can do this like that.

```
// We have to define a wannabe function
class FibFunc() {
  int call(int n) => fib(n);
}

void main() {
  final vs = [40, 41, 42, 43, 44, 45];
  final sum = parallel(vs).pmap(new FibFunc())
                          .then((result) => print(result));  
}
```

you will get this result.

```
[102334155, 165580141, 267914296, 433494437, 701408733, 1134903170]
```

which are the fibonacci values of [40, 41, 42, 43, 44, 45] __processed in parallel__.

We can even combine the parallel map with normal methods applyable to iterables.

Let's say we want to calculate the sum fibonacci numbers from 1 to 45 in parallel
we can do the following:

```
  final vs = new Iterable.generate(45, (i) => i + 1);
  parallel(vs).pmap(new FibFunc())
              .reduce((a, b) => a + b)
              .then((r) {
                print(r);
              });
```

and will get the following result (computed in parallel):

```
2971215072
```

You can run the following code to check that pmap is really faster (on multicore systems).

```
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
```

## Changelog ##

- __Version 0.0.4__ Changed map to pmap. You can now control whether you want the sequential or the parallel map.