import 'dart:convert';
import 'dart:io';
import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testingbloc_course/bloc/persons_bloc.dart';
import 'package:testingbloc_course/bloc/person.dart';
import 'package:testingbloc_course/bloc/bloc_actions.dart';

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
                    context.read<PersonsBloc>().add(const LooadingPersonsAction(
                        url: persons1Url, loader: getPersons));
                  },
                  child: const Text('Load json #1')),
              TextButton(
                onPressed: () {
                  context.read<PersonsBloc>().add(const LooadingPersonsAction(
                      url: persons2Url, loader: getPersons));
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
