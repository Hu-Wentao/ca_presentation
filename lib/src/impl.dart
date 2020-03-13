// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/3/11
// Time  : 13:34

part of 'abs.dart';

///
/// 适用于无需进行耗时初始化的ViewModel
abstract class ViewModel extends _AbsViewModel {
  ViewModel() : super(VmState.idle);
}

///
/// 配合GetIt使用的基础View类
abstract class View<VM extends ViewModel> extends _AbsView<VM> {
  final ViewBuilder<VM> builder;

  View({
    Key key,
    @required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewState<VM, View<VM>>();
}

class _ViewState<VM extends ViewModel, V extends View<VM>>
    extends _AbsViewState<VM, V> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, sl<VM>());
  }
}





///
/// 带有 "signalsReady: true" 的基础Model
abstract class ReadyViewModel extends _AbsViewModel
    implements WillSignalReady {
  // 继承类在执行构造的时候, 会自动执行本类构造,即执行 init()方法
  ReadyViewModel() : super(VmState.unknown) {
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

///
/// 配合Get_it使用的, <带有Ready的view基类>
/// 参数:
///   [VM]表示View所绑定的ViewModel,需要继承[ReadyViewModel]
///   [loading] 参数返回值表示[ViewModel]所依赖的参数在初始化时展示的Widget
///   [builder] 参数返回值表示构造[View]所展示的Widget, 可以调用[ViewModel]中的方法
///   [onReadyError] 表示vm在 [loading] 过程中出现的错误,
///     本类提供默认的错误处理方式, 即展示一个包含错误信息的Container
abstract class ReadyView<VM extends ReadyViewModel> extends _AbsView<VM> {
  final WidgetBuilder loading;
  final ViewBuilder<VM> builder;
  final Widget Function(BuildContext ctx, dynamic error) onReadyError;

  ReadyView({
    this.loading,
    @required this.builder,
    this.onReadyError,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReadyViewState<VM, ReadyView<VM>>();
}

class _ReadyViewState<VM extends ReadyViewModel, V extends ReadyView<VM>>
    extends _AbsViewState<VM, V> {
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
          if (widget.onReadyError == null)
            return Container(child: CircularProgressIndicator());
          return widget.loading(context);
        }
      },
    );
  }

  ///
  /// 本类只覆写 [onInit]方法的[addListener]步骤,本类的继承类仍需call super
  /// 因为[_AbsView]的[onInit]方法没有等待[VM]初始化完成
  @override
  // ignore: must_call_super
  void onStateInit() {
    sl.isReady<VM>().then((_) => sl<VM>().addListener(update));
  }
}
