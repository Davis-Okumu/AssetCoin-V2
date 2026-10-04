
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/trading_repository_impl.dart';
import '../../domain/token_holding.dart';
import '../controllers/token_holdings_controller.dart';

final sellTokenHoldingProvider = FutureProvider.autoDispose
    .family<TokenHolding, int>((ref, tokenId) async {
  final controller = ref.read(
    tokenHoldingsControllerProvider.notifier,
  );

  return controller.getTokenHoldingDetails(tokenId);
});

class SellTokenPage extends ConsumerStatefulWidget {
  final int tokenId;

  const SellTokenPage({
    super.key,
    required this.tokenId,
  });

  @override
  ConsumerState<SellTokenPage> createState() =>
      _SellTokenPageState();
}

class _SellTokenPageState
    extends ConsumerState<SellTokenPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final holdingAsync = ref.watch(
      sellTokenHoldingProvider(widget.tokenId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Tokens'),
        centerTitle: true,
      ),
      body: holdingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) {
          return _ErrorView(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(
                sellTokenHoldingProvider(
                  widget.tokenId,
                ),
              );
            },
          );
        },
        data: (holding) {
          return _SellTokenContent(
            holding: holding,
            formKey: _formKey,
            quantityController:
                _quantityController,
            priceController:
                _priceController,
            isSubmitting: _isSubmitting,
            onSell: () => _submitListing(holding),
          );
        },
      ),
    );
  }

  Future<void> _submitListing(
    TokenHolding holding,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity =
        _normalizeDecimal(_quantityController.text);

    final pricePerToken =
        _normalizeDecimal(_priceController.text);

    final availableQuantity =
        _subtractDecimals(
      holding.quantity,
      holding.lockedQuantity,
    );

    if (_compareDecimals(
          quantity,
          availableQuantity,
        ) >
        0) {
      _showError(
        'You cannot sell more than your available quantity.',
      );
      return;
    }

    if (_compareDecimals(quantity, '0') <= 0) {
      _showError(
        'Enter a quantity greater than zero.',
      );
      return;
    }

    if (_compareDecimals(
          pricePerToken,
          '0',
        ) <=
        0) {
      _showError(
        'Enter a price greater than zero.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(
        TradingRepositoryImpl.provider,
      );

      final listing = await repository.createListing(
        tokenId: holding.tokenId,
        quantity: quantity,
        pricePerToken: pricePerToken,
        currency: _holdingCurrency(holding),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your sell listing was created successfully.',
          ),
        ),
      );

      context.pop(listing);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        _cleanErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _holdingCurrency(
    TokenHolding holding,
  ) {
    final token = holding.token;

    if (token != null &&
        token.currency.trim().isNotEmpty) {
      return token.currency;
    }

    return 'KES';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  String _cleanErrorMessage(dynamic error) {
    final message = error
        .toString()
        .replaceFirst('Exception: ', '')
        .trim();

    if (message.isEmpty) {
      return 'Unable to create the sell listing.';
    }

    return message;
  }

  static String _normalizeDecimal(
    String value,
  ) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '0';
    }

    final normalized =
        trimmed.replaceAll(',', '');

    if (!normalized.contains('.')) {
      return normalized;
    }

    var result = normalized
        .replaceFirst(
          RegExp(r'0+$'),
          '',
        )
        .replaceFirst(
          RegExp(r'\.$'),
          '',
        );

    if (result == '-0') {
      result = '0';
    }

    return result.isEmpty ? '0' : result;
  }

  static List<String> _decimalParts(
    String value,
  ) {
    final normalized =
        _normalizeDecimal(value);

    final parts =
        normalized.split('.');

    return [
      parts.first.isEmpty
          ? '0'
          : parts.first,
      if (parts.length > 1) parts[1],
    ];
  }

  static String _combineParts(
    List<String> parts,
    int scale,
  ) {
    var whole = parts.first;
    var fraction =
        parts.length > 1 ? parts[1] : '';

    var negative = false;

    if (whole.startsWith('-')) {
      negative = true;
      whole = whole.substring(1);
    }

    fraction = fraction.padRight(
      scale,
      '0',
    );

    final combined =
        '$whole$fraction';

    final normalized =
        combined.replaceFirst(
      RegExp(r'^0+(?=\d)'),
      '',
    );

    final absolute =
        normalized.isEmpty
            ? '0'
            : normalized;

    if (negative &&
        absolute != '0') {
      return '-$absolute';
    }

    return absolute;
  }

  static int _compareDecimals(
    String first,
    String second,
  ) {
    final firstParts =
        _decimalParts(first);
    final secondParts =
        _decimalParts(second);

    final scale = firstParts.length >
            secondParts.length
        ? firstParts.length
        : secondParts.length;

    final firstInteger = BigInt.parse(
      _combineParts(
        firstParts,
        scale,
      ),
    );

    final secondInteger = BigInt.parse(
      _combineParts(
        secondParts,
        scale,
      ),
    );

    return firstInteger.compareTo(
      secondInteger,
    );
  }

  static String _subtractDecimals(
    String first,
    String second,
  ) {
    final firstParts =
        _decimalParts(first);
    final secondParts =
        _decimalParts(second);

    final scale = firstParts.length >
            secondParts.length
        ? firstParts.length
        : secondParts.length;

    final firstInteger = BigInt.parse(
      _combineParts(
        firstParts,
        scale,
      ),
    );

    final secondInteger = BigInt.parse(
      _combineParts(
        secondParts,
        scale,
      ),
    );

    final difference =
        firstInteger - secondInteger;

    if (difference <= BigInt.zero) {
      return '0';
    }

    final digits =
        difference.toString();

    if (scale == 0) {
      return digits;
    }

    final padded =
        digits.padLeft(
      scale + 1,
      '0',
    );

    final splitPosition =
        padded.length - scale;

    final whole =
        padded.substring(
      0,
      splitPosition,
    );

    var fraction =
        padded.substring(
      splitPosition,
    );

    fraction = fraction.replaceFirst(
      RegExp(r'0+$'),
      '',
    );

    if (fraction.isEmpty) {
      return whole;
    }

    return '$whole.$fraction';
  }
}

class _SellTokenContent extends StatelessWidget {
  final TokenHolding holding;
  final GlobalKey<FormState> formKey;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final bool isSubmitting;
  final VoidCallback onSell;

  const _SellTokenContent({
    required this.holding,
    required this.formKey,
    required this.quantityController,
    required this.priceController,
    required this.isSubmitting,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final tokenName =
        holding.token?.tokenName ??
            'Token #${holding.tokenId}';

    final tokenCode =
        holding.token?.tokenCode ??
            'TOKEN-${holding.tokenId}';

    final currency =
        holding.token?.currency ?? 'KES';

    final availableQuantity =
        _SellTokenPageState._subtractDecimals(
      holding.quantity,
      holding.lockedQuantity,
    );

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          32,
        ),
        children: [
          _TokenSummaryCard(
            tokenName: tokenName,
            tokenCode: tokenCode,
            tokenId: holding.tokenId,
            totalQuantity: holding.quantity,
            lockedQuantity:
                holding.lockedQuantity,
            availableQuantity:
                availableQuantity,
            currency: currency,
          ),

          const SizedBox(height: 18),

          _SectionTitle(
            icon: Icons.sell_rounded,
            title: 'Create Sell Listing',
            subtitle:
                'Choose how many tokens you want to offer and your asking price.',
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: quantityController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d*\.?\d{0,8}'),
              ),
            ],
            decoration: InputDecoration(
              labelText: 'Quantity',
              hintText: '0.00000000',
              suffixText: tokenCode,
              prefixIcon: const Icon(
                Icons.numbers_rounded,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
            validator: (value) {
              final quantity =
                  _SellTokenPageState
                      ._normalizeDecimal(
                value ?? '',
              );

              if (quantity == '0') {
                return 'Enter a quantity.';
              }

              if (_SellTokenPageState
                      ._compareDecimals(
                    quantity,
                    availableQuantity,
                  ) >
                  0) {
                return 'Maximum available: '
                    '$availableQuantity';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: priceController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d*\.?\d{0,8}'),
              ),
            ],
            decoration: InputDecoration(
              labelText: 'Price per token',
              hintText: '0.00',
              suffixText: currency,
              prefixIcon: const Icon(
                Icons.payments_outlined,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
            validator: (value) {
              final price =
                  _SellTokenPageState
                      ._normalizeDecimal(
                value ?? '',
              );

              if (price == '0') {
                return 'Enter a price.';
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          _ListingPreview(
            quantityController:
                quantityController,
            priceController:
                priceController,
            tokenCode: tokenCode,
            currency: currency,
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed:
                  isSubmitting ? null : onSell,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.sell_rounded,
                    ),
              label: Text(
                isSubmitting
                    ? 'Creating Listing...'
                    : 'Create Sell Listing',
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Your tokens will be offered on the marketplace '
            'using the quantity and price entered above.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }
}

class _TokenSummaryCard extends StatelessWidget {
  final String tokenName;
  final String tokenCode;
  final int tokenId;
  final String totalQuantity;
  final String lockedQuantity;
  final String availableQuantity;
  final String currency;

  const _TokenSummaryCard({
    required this.tokenName,
    required this.tokenCode,
    required this.tokenId,
    required this.totalQuantity,
    required this.lockedQuantity,
    required this.availableQuantity,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary
                .withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary
                      .withValues(alpha: 0.16),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.token_rounded,
                  color:
                      colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      tokenName,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            color:
                                colorScheme
                                    .onPrimary,
                            fontWeight:
                                FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$tokenCode • ID $tokenId',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: colorScheme
                                .onPrimary
                                .withValues(
                              alpha: 0.85,
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryValue(
                  label: 'Available',
                  value: availableQuantity,
                ),
              ),
              Expanded(
                child: _SummaryValue(
                  label: 'Locked',
                  value: lockedQuantity,
                ),
              ),
              Expanded(
                child: _SummaryValue(
                  label: 'Total',
                  value: totalQuantity,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Currency: $currency',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: colorScheme.onPrimary
                      .withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
                color: colorScheme.onPrimary
                    .withValues(alpha: 0.72),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(
                color:
                    colorScheme.onPrimary,
                fontWeight:
                    FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary
                .withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: colorScheme
                          .onSurface
                          .withValues(
                        alpha: 0.62,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListingPreview extends StatelessWidget {
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final String tokenCode;
  final String currency;

  const _ListingPreview({
    required this.quantityController,
    required this.priceController,
    required this.tokenCode,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        quantityController,
        priceController,
      ]),
      builder: (context, _) {
        final quantity =
            _SellTokenPageState
                ._normalizeDecimal(
          quantityController.text,
        );

        final price =
            _SellTokenPageState
                ._normalizeDecimal(
          priceController.text,
        );

        final total =
            _multiplyDecimals(
          quantity,
          price,
        );

        final colorScheme =
            Theme.of(context).colorScheme;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline
                  .withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Listing Preview',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 14),
              _PreviewRow(
                label: 'Quantity',
                value:
                    '$quantity $tokenCode',
              ),
              _PreviewRow(
                label: 'Price per token',
                value:
                    '$price $currency',
              ),
              const Divider(height: 20),
              _PreviewRow(
                label: 'Estimated total',
                value:
                    '$total $currency',
                emphasized: true,
              ),
            ],
          ),
        );
      },
    );
  }

  String _multiplyDecimals(
    String first,
    String second,
  ) {
    final firstParts =
        _parts(first);
    final secondParts =
        _parts(second);

    final firstScale =
        firstParts.length > 1
            ? firstParts[1].length
            : 0;

    final secondScale =
        secondParts.length > 1
            ? secondParts[1].length
            : 0;

    final firstInteger =
        BigInt.parse(
      '${firstParts.first}'
      '${firstParts.length > 1 ? firstParts[1] : ''}',
    );

    final secondInteger =
        BigInt.parse(
      '${secondParts.first}'
      '${secondParts.length > 1 ? secondParts[1] : ''}',
    );

    final product =
        firstInteger * secondInteger;

    final scale =
        firstScale + secondScale;

    if (product == BigInt.zero) {
      return '0';
    }

    if (scale == 0) {
      return product.toString();
    }

    final digits = product.toString();
    final padded =
        digits.padLeft(
      scale + 1,
      '0',
    );

    final splitPosition =
        padded.length - scale;

    final whole =
        padded.substring(
      0,
      splitPosition,
    );

    var fraction =
        padded.substring(
      splitPosition,
    );

    fraction = fraction.replaceFirst(
      RegExp(r'0+$'),
      '',
    );

    if (fraction.isEmpty) {
      return whole;
    }

    return '$whole.$fraction';
  }

  List<String> _parts(String value) {
    final normalized =
        _SellTokenPageState
            ._normalizeDecimal(value);

    return normalized.split('.');
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _PreviewRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: colorScheme
                        .onSurface
                        .withValues(
                      alpha:
                          emphasized ? 0.75 : 0.62,
                    ),
                    fontWeight:
                        emphasized
                            ? FontWeight.w700
                            : FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  fontWeight:
                      emphasized
                          ? FontWeight.w800
                          : FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load your holding',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow:
                  TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}