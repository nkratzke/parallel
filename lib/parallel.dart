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

class _PassableFunction extends Task {
  var _f;
  dynamic _v;
  _PassableFunction(this._f, this._v);
  dynamic execute() => _f(_v);
}

/**
 * A parallel Iterable object wraps a classical [Iterable].
 * All methods applicable to [Iterable] can be also applied
 * to [PIterable].
 * Nevertheless the
 *
 * - [#map], and
 * - [#forEach]
 *
 * method are executed parallel. All methods return Futures on
 * return values known from [Iterable].
 */
class PIterable implements Iterable {

  // Wrapped future of an iterable
  final Future<Iterable> _futureIterable;

  /**
   * Requested isolates for parallel processings.
   */
  static var _isolates;

  /**
   * Closes all requested isolates.
   */
  static void close() {
    PIterable._isolates.close();
    _isolates = null;
  }

  /**
   * Constructor to create a collection providing
   * parallelizable operations on lists.
   */
  PIterable(this._futureIterable) {
    if (PIterable._isolates == null) {
      PIterable._isolates = new Worker();
    }
  }

  /**
   * Parallel executed forEach.
   */
  void forEach(Function f) {
    _futureIterable.then((iterable) {
      for (var entry in iterable) {
        final t = new _PassableFunction(f, entry);
        _isolates.handle(t);
      }
    });
  }

  /**
   * Parallel executed map.
   */
  PIterable map(Function f) {
    Completer<Iterable> c = new Completer<Iterable>();
    final calculations = [];
    this._futureIterable.then((iterable) {
      for (var entry in iterable) {
        final t = new _PassableFunction(f, entry);
        calculations.add(_isolates.handle(t));
      }

      Future.wait(calculations).then((results) {
        c.complete(results);
      });
    });
    return new PIterable(c.future);
  }

  /*
   * The following methods are all to be done.
   *
  PIterable expand(Function f) {

  }

  PIterable skip(int n) {

  }

  PIterable skipWhile(Function test) {

  }

  PIterable take(int n) {

  }

  PIterable takeWhile(Function test) {

  }

  PIterable where(Function test) {

  }*/

  /**
   * Applies a function [f] to a completed result.
   */
  PIterable inspect(void f(dynamic)) {
    Completer<Iterable> c = new Completer<Iterable>();
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
    Completer c = new Completer();
    this._futureIterable.then((completed) {
      final result = reflect(completed).delegate(msg);
      c.complete(result);
    });
    return c.future;
  }
}