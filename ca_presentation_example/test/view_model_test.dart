// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/3/15
// Time  : 23:54
import 'package:ca_presentation_example/counter_view_model.dart';
import 'package:ca_presentation_example/di_config.dart';
import 'package:ca_presentation_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

main() async {
  setUpAll(() async {
    await setUpDi();
  });

  test('测试 counter', () async {

    print('开始: ${sl<CounterViewModel>().counter}');
    sl<CounterViewModel>().incrementCounter();
    print('结束: ${sl<CounterViewModel>().counter}');
  });


  test('测试 Counter2ViewModel', () async {
    print('开始: ${sl<Counter2ViewModel>().counter}');
    await sl.allReady();
    sl<Counter2ViewModel>().incrementCounter();
    print('结束: ${sl<Counter2ViewModel>().counter}');
  });


  test('测试 counter3', () async {
    print('开始: ${sl<Counter3ViewModel>().counter}');
    sl<Counter3ViewModel>().incrementCounter();
    print('结束: ${sl<Counter3ViewModel>().counter}');
  });
}
