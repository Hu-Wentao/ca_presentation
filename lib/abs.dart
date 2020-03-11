// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/3/2
// Time  : 18:09
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

typedef ViewBuilder<VM extends AbsViewModel> = Widget Function(BuildContext ctx, VM m);

///-----------------------------------------------------------------------------
///
/// TODO: 后期可能需要使用 HOOK 插件来完成 在SlView中使用 TextField等功能
/// 抽象SlView
abstract class AbsView<VM extends AbsViewModel> extends StatefulWidget {
  AbsView({Key key}) : super(key: key);
}

/// 抽象SlViewSate
/// [VM] View所绑定的ViewModel
/// [V] ViewState所绑定的View
abstract class AbsViewState<VM extends AbsViewModel,
V extends AbsView<VM>> extends State<V> {
  /// ViewState初始化时
  @mustCallSuper
  void onStateInit() {
    sl<VM>().addListener(update);
  }

  /// ViewState释放时
  @mustCallSuper
  void onStateDispose() {
    sl<VM>().removeListener(update);
  }

  /// 刷新内部状态
  update() => setState(() => {});

  @override
  void initState() {
    onStateInit();
    super.initState();
  }

  @override
  void dispose() {
    onStateDispose();
    super.dispose();
  }
}

///-----------------------------------------------------------------------------
/// VM 的状态
/// [unknown]  只有需要 异步init()的VM才需要这个状态
/// [idle]     非异步VM的初始状态, 或者异步init的VM 初始化完成后的状态
/// [blocking] VM正在执行某个方法, 并且尚未执行完毕, 此时VM已阻塞,将忽略任何方法调用
enum VmState {
  unknown,
  idle,
  blocking,
}

///
/// 抽象ViewModel
abstract class AbsViewModel extends ChangeNotifier {
  VmState _vmState = VmState.unknown;

  /// 检查是否处于阻塞状态,如果是,则返回true,
  /// 如果否,则同时设置VM状态为Running
  ///
  /// ```dart
  ///   void incrementCounter() {
  ///     // check里面同时执行了 setVMRunning;
  ///     if (checkAndSetBlocking) return;
  ///
  ///     ... method body ...
  ///
  ///     notifyAndSetIdle;
  ///   }
  /// ```
  bool get checkAndSetBlocking {
    final isBlocking = _vmState != VmState.idle;
    if (!isBlocking) setVMBlocking;
    return isBlocking;
  }

  /// <组合> 通知监听者的同时,将VM设为Idle
  get notifyAndSetIdle {
    setVMIdle;
    notifyListeners();
  }

  /// <原子> 设置VM状态为 Running
  get setVMBlocking => _vmState = VmState.blocking;

  /// <原子> 设置VM状态为 Idle
  get setVMIdle => _vmState = VmState.idle;
}

///-----------------------------------------------------------------------------
///
/// 带有 "signalsReady: true" 的基础Model
abstract class AbsReadyViewModel extends AbsViewModel implements WillSignalReady {
  // 继承类在执行构造的时候, 会自动执行本类构造,即执行 init()方法
  AbsReadyViewModel() {
    init();
  }

  /// 是否阻止方法执行
  ///
  /// 详细介绍请见 super类中的[checkAndSetBlocking]
  @override
  bool get checkAndSetBlocking {
    // 是否已经准备完成(未完成则阻止,返回true)
    final isNotReady = !sl.isReadySync(instance: this);
    final isVMBlocking = super.checkAndSetBlocking;
    return (isNotReady || isVMBlocking);
  }

  /// init() 方法表示注册完成,因此继承类必须在初始化完成之后才能调用super.init()
  /// 如果想在View被展示之前就预先初始化,则可以在外部同步或异步方式调用本方法
  /// 例如:
  /// ```dart
  /// @singleton // 务必使用单例模式注解 <不建议使用@lazySingleton>
  /// class TestModel extends BaseReadyModel {
  ///   @override
  ///   init() {
  ///     return Future.delayed(Duration(seconds: 2)).then((value) => super.init());
  ///   }
  /// }
  /// ```
  @mustCallSuper
  Future<bool> init() async {
    // 先设为 idle,然后再标记 ready
    setVMIdle;
    sl.signalReady(this);
    return true;
  }
}