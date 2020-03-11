// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/3/11
// Time  : 13:34

import 'package:ca_presentation/src/abs.dart';
import 'package:flutter/widgets.dart';

/// 防止AbsReadyModel被识别为AbsViewModel,
/// 因此新建ViewModel类
class ViewModel extends AbsViewModel {}

///
/// 配合Get_it使用的view基类
class View<VM extends ViewModel> extends AbsView<VM> {
  final ViewBuilder<VM> builder;

  View({
    Key key,
    @required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewState<VM, View<VM>>();
}

class _ViewState<VM extends ViewModel, V extends View<VM>>
    extends AbsViewState<VM, V> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, sl<VM>());
  }
}



///
/// 配合Get_it使用的, <带有Ready的view基类>
/// 参数:
///   [VM]表示Model,需要继承[AbsReadyViewModel]
///   [builder] 构造View的函数, 可以调用ViewModel
///   [onReadyError] 表示vm在 isReady 过程中出现的错误, 本类提供默认的错误处理方式
/// 条件:
class ReadyView<VM extends AbsReadyViewModel> extends AbsView<VM> {
  final WidgetBuilder loading;
  final ViewBuilder<VM> builder;
  final Widget Function(BuildContext ctx, dynamic error) onReadyError;

  ReadyView({
    @required this.loading,
    @required this.builder,
    this.onReadyError,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ReadyViewState<VM, ReadyView<VM>>();
}

class _ReadyViewState<VM extends AbsReadyViewModel, V extends ReadyView<VM>>
    extends AbsViewState<VM, V> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VM>(
      future: sl.isReady<VM>().then((_) => sl<VM>()),
      builder: (ctx, snap) {
        if (snap.hasData) {
          return widget.builder(context, snap.data);
        } else if (snap.hasError) {
          if (widget.onReadyError == null)
            return Container(child: Text("error: ${snap.error}"));
          return widget.onReadyError(context, snap.error);
        } else {
          return widget.loading(context);
        }
      },
    );
  }

  ///
  /// 本类只覆写 onInit的"addListener"步骤,本类的继承类仍需call super
  /// 因为[AbsView]的 onInit()没有等待[VM]初始化完成
  @override
  // ignore: must_call_super
  void onStateInit() {
    sl.isReady<VM>().then((_) => sl<VM>().addListener(update));
  }
}
