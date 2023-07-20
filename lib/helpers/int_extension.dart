extension NullIntExtension on int? {
  bool get isNull => this == null;
  bool get isNotNull => this != null;
  bool get asBool => this == 1;
}

extension IntExtension on int {
  String towDigits() {
    if (this >= 10) return '$this';
    return '0$this';
  }

  String threeDigits() {
    if (this >= 100) return '$this';
    if (this >= 10) return '0$this';
    return '00$this';
  }
}
