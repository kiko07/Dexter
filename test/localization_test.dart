import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Arabic catalogs stay complete and translated', () async {
    final english =
        jsonDecode(await File('lib/core/l10n/app_en.arb').readAsString())
            as Map<String, dynamic>;
    final arabic =
        jsonDecode(await File('lib/core/l10n/app_ar.arb').readAsString())
            as Map<String, dynamic>;
    final englishKeys = english.keys
        .where((key) => !key.startsWith('@'))
        .toSet();
    final arabicKeys = arabic.keys.where((key) => !key.startsWith('@')).toSet();

    expect(arabicKeys, englishKeys);
    for (final key in englishKeys.difference({'faceId'})) {
      expect(
        arabic[key],
        isNot(english[key]),
        reason: 'Arabic translation for $key still matches English.',
      );
    }
  });
}
