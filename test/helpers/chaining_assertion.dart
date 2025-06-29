import 'package:flutter_test/flutter_test.dart';

extension ChainingAssertion on dynamic {
  void shouldBe(dynamic expected, {String? reason}) {
    expect(this, expected, reason: reason);
  }

  void shouldNotBe(dynamic expected, {String? reason}) {
    expect(this, isNot(expected), reason: reason);
  }

  void shouldBeNull({String? reason}) {
    expect(this, isNull, reason: reason);
  }

  void shouldBeNotNull({String? reason}) {
    expect(this, isNotNull, reason: reason);
  }

  void shouldBeTrue({String? reason}) {
    expect(this, isTrue, reason: reason);
  }

  void shouldBeFalse({String? reason}) {
    expect(this, isFalse, reason: reason);
  }
}
