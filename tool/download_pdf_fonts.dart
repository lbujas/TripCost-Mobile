import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main() async {
  const files = {
    'assets/fonts/NotoSans-Regular.ttf':
        'https://raw.githubusercontent.com/googlefonts/noto-fonts/main/hinted/ttf/NotoSans/NotoSans-Regular.ttf',
    'assets/fonts/NotoSans-Bold.ttf':
        'https://raw.githubusercontent.com/googlefonts/noto-fonts/main/hinted/ttf/NotoSans/NotoSans-Bold.ttf',
  };

  for (final entry in files.entries) {
    final target = File(entry.key);
    await target.parent.create(recursive: true);
    stdout.writeln('Downloading ${entry.key}...');
    final response = await http.get(Uri.parse(entry.value));
    if (response.statusCode != 200) {
      stderr.writeln(
        'Failed to download ${entry.key}: HTTP ${response.statusCode}',
      );
      exitCode = 1;
      continue;
    }
    await target.writeAsBytes(response.bodyBytes);
    stdout.writeln('Saved ${entry.key} (${response.bodyBytes.length} bytes)');
  }
}
