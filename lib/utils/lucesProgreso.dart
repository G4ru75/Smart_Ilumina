class LucesProgreso {
  final int total;
  final int encendidas;
  const LucesProgreso({required this.total, required this.encendidas});
  String get texto => '$encendidas/$total';
  double get valor => total == 0 ? 0.0 : encendidas / total;
}
