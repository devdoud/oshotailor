import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/common/widgets/atelier/order_item_section.dart';
import 'package:osho/utils/theme/theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
      theme: theme ?? OshoTheme.lightTheme,
      home: Scaffold(body: child),
    );

void main() {
  group('Tokens (brief: 4.5:1 for any text, in both themes)', () {
    for (final entry in {'clair': OshoTokens.light, 'sombre': OshoTokens.dark}.entries) {
      final t = entry.value;
      final pairs = {
        'ink / bg': (t.ink, t.bg),
        'ink / surface': (t.ink, t.surface),
        'muted / bg': (t.muted, t.bg),
        'muted / surface': (t.muted, t.surface),
        'accent / bg': (t.accent, t.bg),
        'accentInk / accentBg': (t.accentInk, t.accentBg),
        'warnInk / warnBg': (t.warnInk, t.warnBg),
        'okInk / okBg': (t.okInk, t.okBg),
        'dangerInk / dangerBg': (t.dangerInk, t.dangerBg),
        'dangerInk / bg': (t.dangerInk, t.bg),
        'primaryInk / primaryFill': (t.primaryInk, t.primaryFill),
      };
      pairs.forEach((name, p) {
        test('${entry.key} — $name', () {
          expect(_contrast(p.$1, p.$2), greaterThanOrEqualTo(4.5));
        });
      });
    }
  });

  group('Typography', () {
    test('Fraunces tracking follows the size rule', () {
      expect(OType.frauncesTracking(32), closeTo(-0.384, 1e-9));
      expect(OType.frauncesTracking(24), closeTo(-0.288, 1e-9));
      expect(OType.frauncesTracking(20), 0);
      expect(OType.frauncesTracking(16), closeTo(0.032, 1e-9));
    });

    test('text below the 11 px floor is refused', () {
      expect(() => OType.text(10.5, OshoTokens.light.ink), throwsAssertionError);
      expect(OType.text(11, OshoTokens.light.ink).fontSize, 11);
    });
  });

  group('Formatting', () {
    test('FCFA amounts use a no-break space Fraunces can render', () {
      expect(formatFcfa(185000), '185 000 FCFA');
      expect(formatFcfa(0), '0 FCFA');
      expect(formatFcfa(185000).contains(' '), isFalse);
    });

    test('order references are short and upper-case', () {
      expect(shortRef('1a2b3c4d5e6f'), '1A2B3C4D');
      expect(shortRef('abc'), 'ABC');
    });
  });

  group('OSpecRow', () {
    test('treats blank, "null" and dashes as empty', () {
      for (final v in [null, '', '  ', 'null', '-', '—']) {
        expect(OSpecRow.isEmptyValue(v), isTrue, reason: '"$v"');
      }
      expect(OSpecRow.isEmptyValue('104 cm'), isFalse);
    });

    testWidgets('an empty value removes the whole row', (tester) async {
      await tester.pumpWidget(_app(const Column(children: [
        OSpecRow(label: 'Téléphone', value: ''),
        OSpecRow(label: 'Tour de cou', value: '41 cm'),
      ])));
      expect(find.text('Téléphone'), findsNothing);
      expect(find.text('Tour de cou'), findsOneWidget);
      expect(find.text('41 cm'), findsOneWidget);
    });

    testWidgets('a tappable row is at least 48 px high', (tester) async {
      await tester.pumpWidget(_app(OSpecRow(
          label: 'Nom', value: 'Atelier Koffi', onTap: () {})));
      expect(tester.getSize(find.byType(InkWell)).height,
          greaterThanOrEqualTo(48));
    });
  });

  group('OshoLogo', () {
    testWidgets('shows the name and the ATELIER descriptor', (tester) async {
      await tester.pumpWidget(_app(const OshoLogo(height: 24)));
      expect(find.text('Osho'), findsOneWidget);
      expect(find.text('ATELIER'), findsOneWidget);
      expect(find.bySemanticsLabel('Osho Atelier'), findsOneWidget);
    });

    testWidgets('below 20 px only the mark remains', (tester) async {
      await tester.pumpWidget(_app(const OshoLogo(height: 18)));
      expect(find.text('Osho'), findsNothing);
      expect(find.byType(OshoMark), findsOneWidget);
    });
  });

  testWidgets('OStatusTag renders its label in both themes', (tester) async {
    for (final theme in [OshoTheme.lightTheme, OshoTheme.darkTheme]) {
      await tester.pumpWidget(
          _app(const OStatusTag('En attente', OTone.warn), theme: theme));
      expect(find.text('En attente'), findsOneWidget);
    }
  });
}
