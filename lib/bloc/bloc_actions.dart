import 'package:flutter/foundation.dart';
import 'package:testingbloc_course/bloc/person.dart';

const persons1Url = 'http://127.0.0.1:5500/api/persons1.json';
const persons2Url = 'http://127.0.0.1:5500/api/persons2.json';

//function signaure of PersonLoader
typedef PersonLoader = Future<Iterable<Person>> Function(String url);

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
  final String url;
  final PersonLoader loader;

  const LooadingPersonsAction({
    required this.url,
    required this.loader,
  }) : super();
}
