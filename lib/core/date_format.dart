/// Formata uma data em um texto relativo curto (ex: "agora", "5m", "2h","3d")
String formatRelativeTime(DateTime? date) {
  if (date == null) return '';

  final diff = DateTime.now().toUtc().difference(date.toUtc());

  if (diff.inSeconds < 60) return 'agora';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';

  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}