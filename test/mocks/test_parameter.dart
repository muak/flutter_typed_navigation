class TestParameter {
  final String value;
  final bool isCancel;

  const TestParameter(this.value, {this.isCancel = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestParameter &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          isCancel == other.isCancel;

  @override
  int get hashCode => value.hashCode ^ isCancel.hashCode;

  @override
  String toString() => 'TestParameter(value: $value, isCancel: $isCancel)';
}