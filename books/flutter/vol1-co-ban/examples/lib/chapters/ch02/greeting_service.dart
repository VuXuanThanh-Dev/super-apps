import 'package:flutter/widgets.dart';

/// Service + DI của Angular ↔ InheritedWidget (có sẵn trong Flutter).
/// Tập 2 dùng package `provider` (docs chính thức khuyên dùng) — nó được xây trên InheritedWidget.
abstract interface class GreetingService {
  String greet(String name);
}

class FriendlyGreeting implements GreetingService {
  const FriendlyGreeting();
  @override
  String greet(String name) => 'Chào $name!';
}

class FormalGreeting implements GreetingService {
  const FormalGreeting();
  @override
  String greet(String name) => 'Kính chào anh/chị $name.';
}

/// Giống `providers: [{ provide: GreetingService, useValue: ... }]` ở một nhánh của cây.
class GreetingScope extends InheritedWidget {
  const GreetingScope({super.key, required this.service, required super.child});

  final GreetingService service;

  /// Giống `inject(GreetingService)`. Không có scope nào ở trên → dùng mặc định.
  static GreetingService of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GreetingScope>()?.service ?? const FriendlyGreeting();

  @override
  bool updateShouldNotify(GreetingScope oldWidget) => service != oldWidget.service;
}

class GreetingText extends StatelessWidget {
  const GreetingText({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Text(GreetingScope.of(context).greet(name));
}
