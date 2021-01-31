extension StringExtension on String {
  String stripMargin() {
    return this.splitMapJoin(
      RegExp(r'^', multiLine: true),
      onMatch: (_) => '\n',
      onNonMatch: (n) => n.trim(),
    );
  }
}
