library parallel;

import 'dart:async';
import 'dart:mirrors';
import 'package:worker/worker.dart';

/**
 * Embeds a [collection] into a parallel executable
 * PIterable object.
 */
PIterable parallel(Iterable collection) => new PIterable(
    new Future.value(collection)
);

class _MessageableFunction extends Task {
  final f;
  final x;
  _MessageableFunction(this.f, this.x);
  dynamic execute() => f(x);
}

/**
 * A parallel Iterable object wraps a classical [Iterable].
 * All methods applicable to [Iterable] can be also applied
 * to [PIterable].
 * Nevertheless the [#map]method are executed parallel.
 * All methods return Futures on
 * return values known from [Iterable].
 */
class PIterable implements Iterable {

  // Wrapped future of an iterable
  final Future<Iterable> _futureIterable;

  /**
   * Constructor to create a collection providing
   * parallelizable operations on lists.
   */
  PIterable(this._futureIterable);

  /**
   * Parallel map. [f] has to be a wannabe function.
   */
  PIterable map(Function f) {
    final worker = new Worker();
    final c = new Completer<Iterable>();
    final computations = [];
    this._futureIterable.then((iterable) {
      for (var entry in iterable) {
        final t = new _MessageableFunction(f, entry);
        computations.add(worker.handle(t));
      }
      Future.wait(computations).then((results) {
        worker.close();
        c.complete(results);
      });
    });
    return new PIterable(c.future);
  }

  /**
   * Applies a function [f] to a completed result.
   */
  PIterable inspect(void f(dynamic)) {
    final c = new Completer<Iterable>();
    this._futureIterable.then((completed) {
      f(completed);
      c.complete(completed);
    });
    return new PIterable(c.future);
  }

  /**
   * Delegates all methods of [Iterable] to the wrapped
   * iterable. Returns a Future of the result returned by
   * the wrapped [Iterable].
   */
  dynamic noSuchMethod(Invocation msg) {
    final c = new Completer();
    this._futureIterable.then((completed) {
      final result = reflect(completed).delegate(msg);
      c.complete(result);
    });
    return c.future;
  }
}