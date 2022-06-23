// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(primarySwatch: Colors.blue),
    debugShowCheckedModeBanner: false,
    home: BlocProvider(
      create: (_) => PersonsBloc(),
      child: const HomePage(),
    ),
  ));
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsActions extends LoadAction {
  final PersonUrl url;

  const LoadPersonsActions({required this.url}) : super();
}

enum PersonUrl {
  person1,
  person2,
}

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.person1:
        return 'http://192.168.0.18:5500/api/persons1.json';
      case PersonUrl.person2:
        return 'http://192.168.0.18:5500/api/persons2.json';
    }
  }
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

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
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({required this.name, required this.age});

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;

  @override
  String toString() => 'Person (name = $name, age = $age)';
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonUrl, Iterable<Person>> _cache = {};
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
        final persons = await getPersons(url.urlString);
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

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Column(children: [
        Row(
          children: [
            TextButton(
              onPressed: () {
                context.read<PersonsBloc>().add(
                      const LoadPersonsActions(
                        url: PersonUrl.person1,
                      ),
                    );
              },
              child: const Text('json 1'),
            ),
            TextButton(
              onPressed: () {
                context.read<PersonsBloc>().add(
                      const LoadPersonsActions(
                        url: PersonUrl.person2,
                      ),
                    );
              },
              child: const Text('json 2'),
            ),
          ],
        ),
        BlocBuilder<PersonsBloc, FetchResult?>(
            buildWhen: (previousResult, currentResult) {
          return previousResult?.persons != currentResult?.persons;
        }, builder: ((context, fetchResult) {
          final persons = fetchResult?.persons;
          if (persons == null) {
            return const SizedBox();
          }

          return Expanded(
            child: ListView.builder(
                itemCount: persons.length,
                itemBuilder: (context, index) {
                  final person = persons[index]!;
                  return ListTile(
                    title: Text(person.name),
                  );
                }),
          );
        }))
      ]),
    );
  }
}
