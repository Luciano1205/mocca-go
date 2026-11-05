// Formatos de texto que se repiten en las pantallas.

/// 16000 → "$16.000"
String formatoPesos(int valor) {
  final digitos = valor.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digitos[i]);
  }
  return '${valor < 0 ? '-' : ''}\$$buffer';
}

/// Tiempo desde [fecha]: "Hace un momento", "Hace 4 min", "Hace 2 h", "Hace 3 d".
String haceCuanto(DateTime fecha, {DateTime? ahora}) {
  final diferencia = (ahora ?? DateTime.now()).difference(fecha);
  if (diferencia.inMinutes < 1) return 'Hace un momento';
  if (diferencia.inHours < 1) return 'Hace ${diferencia.inMinutes} min';
  if (diferencia.inDays < 1) return 'Hace ${diferencia.inHours} h';
  return 'Hace ${diferencia.inDays} d';
}

/// "9:05"
String formatoHora(DateTime fecha) {
  final minutos = fecha.minute.toString().padLeft(2, '0');
  return '${fecha.hour}:$minutos';
}

/// "Laura Gómez" → "Laura G."
String nombreCorto(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+'));
  if (partes.length < 2) return nombre.trim();
  return '${partes.first} ${partes[1][0]}.';
}

/// "Laura Gómez" → "LG"
String iniciales(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return partes.take(2).map((p) => p[0].toUpperCase()).join();
}
