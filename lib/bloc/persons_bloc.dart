import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:testingbloc_course/bloc/person.dart';
import 'package:testingbloc_course/bloc/bloc_actions.dart';

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

//results in returning a future
@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetriviedFromCache;
  const FetchResult({
    required this.persons,
    required this.isRetriviedFromCache,
  });
  @override
  String toString() =>
      'FetchResult (isRetriviedFromCache = $isRetriviedFromCache, persons $persons';

  @override
  bool operator ==(covariant FetchResult other) =>
      persons.isEqualToIgnoringOrdering(other.persons) &&
      isRetriviedFromCache == other.isRetriviedFromCache;

  @override
  int get hashCode => Object.hash(persons, isRetriviedFromCache);
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  //fetchresult optinal as 'inital state' is required
  final Map<String, Iterable<Person>> _cache = {};
  PersonsBloc() : super(null) {
    on<LooadingPersonsAction>((event, emit) async {
      final url = event.url;
      if (_cache.containsKey(url)) {
        //we have the value in cache
        final cachedPersons = _cache[url]!;
        final result =
            FetchResult(persons: cachedPersons, isRetriviedFromCache: true);
        emit(result);
      } else {
        final loader = event.loader;
        final persons = await loader(url);
        _cache[url] = persons;
        final result =
            FetchResult(persons: persons, isRetriviedFromCache: false);
        emit(result);
      }
    });
  }
}
