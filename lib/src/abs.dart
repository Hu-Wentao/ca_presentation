// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/3/2
// Time  : 18:09
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

part 'impl.dart';

final sl = GetIt.instance;

typedef ViewBuilder<VM extends _AbsViewModel> = Widget Function(
    BuildContext ctx, VM m);

///-----------------------------------------------------------------------------
///
/// TODO: 后期可能需要使用 HOOK 插件来完成 在SlView中使用 TextField等功能
/// 抽象SlView
abstract class _AbsView<VM extends _AbsViewModel> extends StatefulWidget {
  _AbsView({Key key}) : super(key: key);
}

/// 抽象SlViewSate
/// [VM] View所绑定的ViewModel
/// [V] ViewState所绑定的View
abstract class _AbsViewState<VM extends _AbsViewModel, V extends _AbsView<VM>>
    extends State<V> {
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
/// ViewModel 的状态
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
abstract class _AbsViewModel extends ChangeNotifier {
  VmState _vmState = VmState.unknown;

//  _AbsViewModel([this._vmState = VmState.unknown]);

  ///
  /// VM是否处于锁定状态
  bool get isBlocking => _vmState != VmState.idle;

  /// 检查是否处于阻塞状态,
  /// 如果是,则返回true,
  /// 如果否,返回false,同时设置VM状态为 [VmState.blocking]
  ///
  /// ```dart
  ///   void incrementCounter() {
  ///     // check里面同时执行了 setVMBlocking;
  ///     if (checkAndSetBlocking) return;
  ///
  ///     ... method body ...
  ///
  ///     notifyAndSetIdle;
  ///   }
  /// ```
  @protected
  bool get checkAndSetBlocking {
    if (isBlocking) return true;
    setVMBlocking;
    return false;
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
