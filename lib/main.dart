import 'dart:convert';
import 'dart:io';
import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
          create: (context) {
            return PersonsBloc();
          },
          child: const MyHomePage()),
    );
  }
}

//Action is just different wording for an event, both mean to be an input to bloc
//This class is to be generic class for actions/events classes.
// For a class to be valid input to bloc it must be a subclass of this abstract class,
// This programmatically validates that classes are intended to be sent to bloc. reducing errors/bugs/mistakes
@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LooadingPersonsAction implements LoadAction {
  //This will be an input for bloc and each input will have value to 'url' loading one from the api folder
  final PersonUrl url;
  const LooadingPersonsAction({required this.url}) : super();
}

enum PersonUrl {
  persons1,
  persons2,
}

extension UrlString on PersonUrl {
  //this extension will allow loading of persons file based on persons enum used
  String get urlString {
    switch (this) {
      // 'this' referes to current instance of enumeration

      case PersonUrl.persons1:
        return 'http://127.0.0.1:5500/api/persons1.json';
      case PersonUrl.persons2:
        return 'http://127.0.0.1:5500/api/persons2.json';
    }
  }
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({
    required this.name,
    required this.age,
  });
  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;
  @override
  String toString() => 'Person (name = $name, age = $age';
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url)) //get http request
    .then((req) => req.close()) //close request and returns the response
    .then((resp) => resp
        .transform(utf8.decoder)
        .join()) //resp is transformed into string following UTF8 encoding
    .then((str) => json.decode(str) as List<
        dynamic>) //the string is decoded itno dynamic then casted as list of dynamics
    .then((list) => list.map((e) => Person.fromJson(
        e))); //for item in list a persons object is created by called Persons.fromJson which will retrivie the values inside its methods

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
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  //fetchresult optinal as 'inital state' is required
  final Map<PersonUrl, Iterable<Person>> _cache = {};
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
        final persons = await getPersons(url.urlString);
        _cache[url] = persons;
        final result =
            FetchResult(persons: persons, isRetriviedFromCache: false);
        emit(result);
      }
    });
  }
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cubit Example'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    context.read<PersonsBloc>().add(
                        const LooadingPersonsAction(url: PersonUrl.persons1));
                  },
                  child: const Text('Load json #1')),
              TextButton(
                onPressed: () {
                  context.read<PersonsBloc>().add(
                      const LooadingPersonsAction(url: PersonUrl.persons2));
                },
                child: const Text('Load json #2'),
              ),
            ],
          ),
          BlocBuilder<PersonsBloc, FetchResult?>(
            buildWhen: (previous, current) {
              return previous?.persons != current?.persons;
            },
            builder: (context, fetchResult) {
              fetchResult?.log();
              final persons = fetchResult?.persons;
              if (persons == null) {
                return const SizedBox();
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    final person = persons[index]!;
                    return ListTile(title: Text(person.name));
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
