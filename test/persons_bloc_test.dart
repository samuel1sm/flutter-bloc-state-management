import 'package:bloc_pattern/bloc/block_actions.dart';
import 'package:bloc_pattern/bloc/person.dart';
import 'package:bloc_pattern/bloc/persons_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

const mockedPersons1 = [
  Person(
    name: 'foo',
    age: 20,
  ),
  Person(
    name: 'bar',
    age: 30,
  ),
];

const mockedPersons2 = [
  Person(
    name: 'foo',
    age: 20,
  ),
  Person(
    name: 'bar',
    age: 30,
  ),
];

Future<Iterable<Person>> mockGetPerson1(String _) =>
    Future.value(mockedPersons1);

Future<Iterable<Person>> mockGetPerson2(String _) =>
    Future.value(mockedPersons2);
void main() {
  group('Testing bloc', () {
    late PersonsBloc bloc;

    setUp(() {
      bloc = PersonsBloc();
    });

    blocTest<PersonsBloc, FetchResult?>(
      'Test Initial State',
      build: () => bloc,
      verify: (bloc) => expect(bloc.state, null),
    );

    blocTest<PersonsBloc, FetchResult?>(
        'Mock retriving persons1 from the iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const LoadPersonsActions(
              loader: mockGetPerson1, url: 'dummy_utl_1'));

          bloc.add(const LoadPersonsActions(
              loader: mockGetPerson1, url: 'dummy_utl_1'));
        },
        expect: () => [
              const FetchResult(
                persons: mockedPersons1,
                isRetrievedFromCache: false,
              ),
              const FetchResult(
                persons: mockedPersons1,
                isRetrievedFromCache: true,
              ),
            ]);

    blocTest<PersonsBloc, FetchResult?>(
        'Mock retriving persons2 from the iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const LoadPersonsActions(
              loader: mockGetPerson2, url: 'dummy_utl_2'));

          bloc.add(const LoadPersonsActions(
              loader: mockGetPerson2, url: 'dummy_utl_2'));
        },
        expect: () => [
              const FetchResult(
                persons: mockedPersons2,
                isRetrievedFromCache: false,
              ),
              const FetchResult(
                persons: mockedPersons2,
                isRetrievedFromCache: true,
              ),
            ]);
  });
}
