parallel
========

Parallel map for Dart

Dart programs run in a single isolate by default. Although Dart provides 
several asynchronous programming techniques like Futures and Streams Dart
does not use capacities of modern multicore processors by default.

This package provides a parallel map function
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
  final sum = parallel(vs).map(new FibFunc())
                          .reduce((a, b) => a + b)
                          .then((result) => print(result));  
}
```
