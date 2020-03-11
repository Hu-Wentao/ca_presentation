## [2.4.0] - 2020/3/11/ 17:06

* 重构代码, 并去除所有类名中的"Sl",使用Abs取代Base (Sl意为: Service Locator)

## [2.3.1] -  2020/3/11 13:42

* 修复抽象_AbsSlView错误的实现了createState()的问题


## [2.3.0] -  2020/3/11 13:01

* 将BaseViewModel改为 ViewModel, 将其内容抽象到_AbsViewModel

## [2.2.1] -  2020/3/11 12:47

* 当onError builder函数为null, sl_view提供默认的error展示方式

## [2.2.0] -  2020/3/10 15:40

* 直接通过 get_it来获取 sl,而不是导入其他包

## [2.1.0] -  2020/3/5 23:29

* 将 setVMIdle 与notifyListeners()合并

## [2.0.0] -  2020/3/5 23:19

* 引入VM状态锁定机制, 状态不再依靠外部定义,而是有VM中的变量控制

## [1.0.1] -  2020/3/4 10:13

* 修复init()内多余的判断ready的方法,重命名notReady()为 isNotReady

## [1.0.0] -  2020/3/3 22:20

* 修复了之前因为省略泛型导致Type总是出错的BUG

## [0.1.0] -  2020/3/3 11:03

* 包装了get_it,取代provider