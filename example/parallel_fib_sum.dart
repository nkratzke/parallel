import 'package:parallel/parallel.dart';

class FibFunc {
  int call(int n) {
    if (n == 0) return 0;
    if (n == 1) return 1;
    return call(n-1) + call(n-2);
  }
}

main() {
  final vs = [40, 41, 42, 43, 44, 45];
  final sum = parallel(vs).pmap(new FibFunc())
                          .reduce((a, b) => a + b)
                          .then((result) => print(result));
}