/// Normalizes Arabic text for consistent search and deduplication.
String arabicNormalize(String input) {
  var s = input;
  // Normalize Alef variants
  s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
  // Normalize Taa Marbuta
  s = s.replaceAll('ة', 'ه');
  // Normalize Yaa variants
  s = s.replaceAll('ى', 'ي');
  // Normalize Waw
  s = s.replaceAll('ؤ', 'و');
  // Normalize Hamza on Yaa
  s = s.replaceAll('ئ', 'ي');
  // Strip Tashkeel (diacritics U+064B to U+065F)
  s = s.replaceAll(RegExp(r'[\u064B-\u065F]'), '');
  // Strip Tatweel
  s = s.replaceAll('\u0640', '');
  // Normalize whitespace
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s.toLowerCase();
}
