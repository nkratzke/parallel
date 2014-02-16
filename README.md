parallel
========

Parallel map for Dart

Dart programs run in a single isolate by default. Although Dart provides 
several asynchronous programming techniques like Futures and Streams Dart
does not use capacities of modern multicore processors by default.

This is a language design decision mainly due to problematic controllability of 
concurrency aspects (thread safeness) in programming.

Let us assume we want to calculate several times the fibonacci number of 40 
by applying the following function

```
int fib(int n) {
  if (n == 0) return 1;
  if (n == 1) return 1;
  return fib(n-1) + fib(n-2);
}
```

and want to add all results to a single result we could do this like that.

```
final vs = [10, 20, 30, 40];
print(vs.map((n) => fib(n)).reduce((a, b) => a + b));
```

The most time intensive part of this operation would be to apply four times the
fibonacci function. And although map is per se perfectly parallizable in the shown case
Dart would not execute it in parallel due to the fact that every Dart program runs in a single
isolate (even if a Dart program runs on a processor being capable to process
several threads in parallel).

This 


```
  print("fib of $vs using classical map");
  stopwatch.start();
  print(vs.map(fibStr).join("\n"));
  stopwatch.stop();
  print("Elapsed time: ${stopwatch.elapsed}");
``