// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:ca_presentation_example/register_moduls.dart';
import 'package:ca_presentation_example/counter_view_model.dart';
import 'package:get_it/get_it.dart';

Future<void> $initGetIt(GetIt g, {String environment}) async {
  final needInitPlugs = _$NeedInitPlugs();
  final test2 = await needInitPlugs.testTwo;
  g.registerFactory<Test2>(() => test2);
  final test = await needInitPlugs.testOne;
  g.registerFactory<Test>(() => test);
  final test3 = await needInitPlugs.testThree;
  g.registerFactory<Test3<String>>(() => test3);

  //Eager singletons must be registered in the right order
  g.registerSingleton<Counter3ViewModel>(Counter3ViewModel(g<Test2>()));
  g.registerSingleton<Counter2ViewModel>(Counter2ViewModel(g<Test2>()));
  g.registerSingleton<CounterViewModel>(CounterViewModel(g<Test>()));
}

class _$NeedInitPlugs extends NeedInitPlugs {}
