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

  test('测试 CounterViewModel', () async {
    print('开始: ${sl<CounterViewModel>().counter}');
    sl<CounterViewModel>().incrementCounter();
    print('结束: ${sl<CounterViewModel>().counter}');
  });


  test('\n测试 Counter2ViewModel', () async {
    print('开始: ${sl<Counter2ViewModel>().counter}');

    // 如果要确保点击有效, 则需要isReady<T>();或者 allReady();
    await sl.isReady<Counter2ViewModel>();
    sl<Counter2ViewModel>().incrementCounter();
    print('结束: ${sl<Counter2ViewModel>().counter}');
  });


  test('\n测试 Counter3ViewModel', () async {
    print('开始: ${sl<Counter3ViewModel>().counter}');
    sl<Counter3ViewModel>().incrementCounter();
    print('结束: ${sl<Counter3ViewModel>().counter}');
  });

  test('\n测试 Counter4ViewModel', () async {
    print('开始: ${sl<Counter4ViewModel>().counter}');
    sl<Counter4ViewModel>().incrementCounter();
    print('结束: ${sl<Counter4ViewModel>().counter}');
  });
}
