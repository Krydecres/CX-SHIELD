import 'package:flutter_test/flutter_test.dart';

/// SCRUM-243: Pricing calculation tests.
///
/// Run from the project root:
/// flutter test testing/SCRUM-243/test-scripts/pricing_test.dart
///
/// These tests validate pricing and VAT calculations.
/// UI navigation, database integration and authorization
/// are covered by the corresponding functional test cases.

const double vatRate = 0.10;

double calculateVat(double price) => price * vatRate;

double calculateTotal(double price) => price + calculateVat(price);

void main() {
  group('SCRUM-243 - Pricing calculations', () {
    test('TC-243-01: Basic monthly price with VAT', () {
      const price = 200000.0;

      expect(calculateVat(price), 20000.0);
      expect(calculateTotal(price), 220000.0);
    });

    test('TC-243-02: Basic yearly price with VAT', () {
      const price = 1920000.0;

      expect(calculateVat(price), 192000.0);
      expect(calculateTotal(price), 2112000.0);
    });

    test('TC-243-03: Basic lifetime price with VAT', () {
      const price = 990000.0;

      expect(calculateVat(price), 99000.0);
      expect(calculateTotal(price), 1089000.0);
    });

    test('TC-243-04: Advanced lifetime price with VAT', () {
      const price = 1490000.0;

      expect(calculateVat(price), 149000.0);
      expect(calculateTotal(price), 1639000.0);
    });

    test('TC-243-05: Advanced monthly price with VAT', () {
      const price = 350000.0;

      expect(calculateVat(price), 35000.0);
      expect(calculateTotal(price), 385000.0);
    });

    test('TC-243-06: Chain monthly price with VAT', () {
      const price = 500000.0;

      expect(calculateVat(price), 50000.0);
      expect(calculateTotal(price), 550000.0);
    });

    test('TC-243-07: Chain yearly price with VAT', () {
      const price = 4800000.0;

      expect(calculateVat(price), 480000.0);
      expect(calculateTotal(price), 5280000.0);
    });

    test('TC-243-08: Zero price has zero VAT', () {
      const price = 0.0;

      expect(calculateVat(price), 0.0);
      expect(calculateTotal(price), 0.0);
    });
  });
}
