import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testingbloc_course/bloc/bloc_actions.dart';
import 'package:testingbloc_course/bloc/person.dart';
import 'package:testingbloc_course/bloc/persons_bloc.dart';

//different data wont make a difference
const mockedPerson1 = [
  Person(name: 'Foo', age: 20),
  Person(name: 'bar', age: 30),
];
const mockedPerson2 = [
  Person(name: 'Foo', age: 20),
  Person(name: 'bar', age: 30),
];

Future<Iterable<Person>> mockGetPersons1(String _) =>
    Future.value(mockedPerson1);

Future<Iterable<Person>> mockGetPersons2(String _) =>
    Future.value(mockedPerson2);

void main() {
  group(
    'Testing bloc',
    () {
      late PersonsBloc bloc;
      setUp(() {
        bloc = PersonsBloc();
      });

      blocTest<PersonsBloc, FetchResult?>(
        'Test intial state',
        build: () => bloc,
        verify: (bloc) => expect(bloc.state, null),
      );
      //fetch mock data (persons1) and compare with FetchResults
      blocTest<PersonsBloc, FetchResult?>(
        'Mock restriving persons from first iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(
            const LooadingPersonsAction(
              url: 'dummy_url_1',
              loader: mockGetPersons1,
            ),
          );
          bloc.add(
            const LooadingPersonsAction(
              url: 'dummy_url_1',
              loader: mockGetPersons1,
            ),
          );
        },
        expect: () => [
          const FetchResult(
            persons: mockedPerson1,
            isRetriviedFromCache: false,
          ),
          const FetchResult(
            persons: mockedPerson1,
            isRetriviedFromCache: true,
          ),
        ],
      );
      //fetch mock data (persons2) and compare with FetchResults
      blocTest<PersonsBloc, FetchResult?>(
        'Mock restriving persons from second iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(
            const LooadingPersonsAction(
              url: 'dummy_url_2',
              loader: mockGetPersons2,
            ),
          );
          bloc.add(
            const LooadingPersonsAction(
              url: 'dummy_url_2',
              loader: mockGetPersons2,
            ),
          );
        },
        expect: () => [
          const FetchResult(
            persons: mockedPerson2,
            isRetriviedFromCache: false,
          ),
          const FetchResult(
            persons: mockedPerson2,
            isRetriviedFromCache: true,
          ),
        ],
      );
    },
  );
}
