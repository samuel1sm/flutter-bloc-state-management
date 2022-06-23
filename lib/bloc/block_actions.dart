// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart' show immutable;

import 'package:bloc_pattern/bloc/person.dart';

const person1Url = 'http://192.168.0.18:5500/api/persons1.json';
const person2Url = 'http://192.168.0.18:5500/api/persons2.json';

typedef PersonsLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsActions extends LoadAction {
  final String url;
  final PersonsLoader loader;
  const LoadPersonsActions({
    required this.url,
    required this.loader,
  }) : super();
}
