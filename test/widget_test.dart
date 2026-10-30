import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_modulator/main.dart';

void main() {
  testWidgets('NeuroModulator Desktop i18n, Master Power & WASAPI smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const NeuroModulatorApp());
    await tester.pumpAndSettle();

    // 1. Default Spanish UI verification
    expect(find.textContaining('NEURO-DSP MODULADOR INTELIGENTE'), findsOneWidget);
    expect(find.textContaining('INTERRUPTOR MAESTRO DEL SISTEMA DSP'), findsOneWidget);
    expect(find.textContaining('Modo Calma Consciente Alpha'), findsOneWidget);
    expect(find.textContaining('WASAPI Loopback'), findsWidgets);

    // 2. Switch to English (EN)
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.textContaining('MASTER DSP SYSTEM POWER SWITCH'), findsOneWidget);
    expect(find.textContaining('Mindful Alpha Calm Mode'), findsOneWidget);

    // 3. Switch to Chinese (中文)
    await tester.tap(find.text('中文'));
    await tester.pumpAndSettle();
    expect(find.textContaining('DSP 系统主电源开关'), findsOneWidget);
    expect(find.textContaining('Alpha 正念平静模式'), findsOneWidget);
  });
}
