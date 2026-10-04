abstract final class FeatureFlags {
  static const enableBiometrics = bool.fromEnvironment(
    'ENABLE_BIOMETRICS',
    defaultValue: false,
  );

  static const enableTrading = bool.fromEnvironment(
    'ENABLE_TRADING',
    defaultValue: true,
  );

  static const enableLedgerExplorer = bool.fromEnvironment(
    'ENABLE_LEDGER_EXPLORER',
    defaultValue: true,
  );
}