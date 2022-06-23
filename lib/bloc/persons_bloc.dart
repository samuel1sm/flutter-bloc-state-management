// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'package:bloc_pattern/bloc/person.dart';

import 'block_actions.dart';

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;
  const FetchResult({
    required this.persons,
    required this.isRetrievedFromCache,
  });

  @override
  String toString() =>
      'FetchResult(persons: $persons, isRetrievedFromCache: $isRetrievedFromCache)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FetchResult &&
        other.persons == persons &&
        other.isRetrievedFromCache == isRetrievedFromCache;
  }

  @override
  int get hashCode => Object.hash(
        persons,
        isRetrievedFromCache,
      );
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<String, Iterable<Person>> _cache = {};
  PersonsBloc() : super(null) {
    on<LoadPersonsActions>(((event, emit) async {
      final url = event.url;
      late FetchResult result;
      if (_cache.containsKey(url)) {
        final cashedPersons = _cache[url]!;
        result = FetchResult(
          persons: cashedPersons,
          isRetrievedFromCache: true,
        );
      } else {
        final persons = await event.loader(url);
        _cache[url] = persons;
        result = FetchResult(
          persons: persons,
          isRetrievedFromCache: false,
        );
      }
      emit(result);
    }));
  }
}
