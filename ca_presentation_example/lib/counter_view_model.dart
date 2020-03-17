import 'package:ca_presentation_example/register_moduls.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ca_presentation/ca_presentation.dart';

///
/// 直接继承自ViewModel
@singleton
class Counter3ViewModel extends ViewModel {
  final Test2 t;
  int _c = 3;

  Counter3ViewModel(this.t);

  int get counter => _c;

  void incrementCounter() {
    print('Counter3ViewModel.incrementCounter isBlocking: $isBlocking');
    if (checkAndSetBlocking) return;
    print('Counter3ViewModel.incrementCounter + ${t.number}');
    _c += t.number;
    notifyAndSetIdle;
  }
}

///
/// 示例Model
///  GetIt提示 ReadyViewModel不能异步标注. 尝试将 singleton改为 lazy..
///  改为使用 lazySingleton后居然没有报原来的错误了
///  还是报错, 又添加了  implements WillSignalReady
///
/// 最终结果: ViewModel必须使用 @singleton, 否则会报错!
@singleton
//@lazySingleton
class Counter2ViewModel extends ReadyViewModel {
  final Test2 t;
  int _counter = 2;

  Counter2ViewModel(this.t);

  @override
  Future<bool> init() async {
    print('这里使用delayed模拟了一些初始化工作');
    return Future.delayed(Duration(seconds: 1)).then((_) => super.init());
  }

  int get counter => _counter;

  void incrementCounter() {
    print('Counter2ViewModel.incrementCounter --- block: $isBlocking');
    if (checkAndSetBlocking) return;

    /// todo 在这里直接抛出异常并不合适,应当先判断
    /// 因为这个方法可能会通过sl<>()在其他地方调用,
    /// 其他地方不一定有try..catch
    _counter += t.number;
    notifyAndSetIdle;
  }
}

@singleton
class CounterViewModel extends ReadyViewModel {
  final Test t;

  /// 数据
  int counter = 1;

  CounterViewModel(this.t);

  /// 操作数据的方法
  void incrementCounter() {
    print('CounterViewModel.incrementCounter --- block: $isBlocking');
    if (checkAndSetBlocking) return;
    print('CounterViewModel.incrementCounter t: ${t.number}');
    counter += t.number;
    setVMIdle;
    notifyListeners();
  }

  @override
  Future<bool> init() =>
      Future.delayed(Duration(seconds: 1)).then((_) => super.init());
}
