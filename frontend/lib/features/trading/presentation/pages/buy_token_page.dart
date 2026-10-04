
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/trading_repository_impl.dart';
import '../../domain/listing.dart';
import '../../domain/trading_repository.dart';

/// Loads a single marketplace listing for the buy page.
///
/// This provider intentionally lives here instead of depending on
/// ListingDetailsPage's provider. Pages should not depend on providers
/// declared inside other pages.
final buyListingDetailsProvider = FutureProvider.family
    .autoDispose<Listing, int>((ref, listingId) async {
  final repository = ref.read(
    TradingRepositoryImpl.provider,
  );

  return repository.getListingDetails(listingId);
});

class BuyTokenPage extends ConsumerStatefulWidget {
  final int listingId;

  const BuyTokenPage({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<BuyTokenPage> createState() => _BuyTokenPageState();
}

class _BuyTokenPageState
    extends ConsumerState<BuyTokenPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listingId <= 0) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Invalid listing identifier.',
          ),
        ),
      );
    }

    final listingAsync = ref.watch(
      buyListingDetailsProvider(widget.listingId),
    );

    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Buy Tokens'),
        centerTitle: false,
      ),
      body: listingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorView(
          onRetry: () {
            ref.invalidate(
              buyListingDetailsProvider(
                widget.listingId,
              ),
            );
          },
        ),
        data: (listing) {
          return _BuyTokenContent(
            listing: listing,
            formKey: _formKey,
            quantityController: _quantityController,
            isSubmitting: _isSubmitting,
            onQuantityChanged: () {
              setState(() {});
            },
            onSubmit: () => _submitPurchase(listing),
          );
        },
      ),
    );
  }

  // ============================================================
  // SUBMIT PURCHASE
  // ============================================================

  Future<void> _submitPurchase(
    Listing listing,
  ) async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity =
        _quantityController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(
        TradingRepositoryImpl.provider,
      );

      final result = await repository.buyToken(
        listingId: listing.id,
        quantity: quantity,
      );

      if (!mounted) {
        return;
      }

      await _showSuccessDialog(
        result,
      );

      if (!mounted) {
        return;
      }

      context.go(
        '/trading/orders/${result.order.id}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      await _showErrorDialog(
        _friendlyErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // SUCCESS
  // ============================================================

  Future<void> _showSuccessDialog(
    BuyTokenResult result,
  ) async {
    final colorScheme =
        Theme.of(context).colorScheme;

    final totalAmount =
        result.totalAmount?.trim();

    final currency =
        result.currency?.trim().isNotEmpty == true
            ? result.currency!.trim()
            : 'KES';

    final reference =
        result.transactionReference?.trim();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Purchase Submitted',
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Your token purchase order has been '
                'created successfully.',
              ),
              if (totalAmount != null &&
                  totalAmount.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Total Amount',
                  style: Theme.of(dialogContext)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currency $totalAmount',
                  style: Theme.of(dialogContext)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
              if (reference != null &&
                  reference.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Transaction Reference',
                  style: Theme.of(dialogContext)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  reference,
                  style: Theme.of(dialogContext)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'View Order',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Future<void> _showErrorDialog(
    String message,
  ) async {
    final colorScheme =
        Theme.of(context).colorScheme;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: colorScheme.error,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Purchase Failed',
                ),
              ),
            ],
          ),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _friendlyErrorMessage(
    Object error,
  ) {
    final message = error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        )
        .trim();

    if (message.isEmpty) {
      return 'The purchase could not be completed. '
          'Please try again.';
    }

    return message;
  }
}

// ============================================================
// CONTENT
// ============================================================

class _BuyTokenContent extends StatelessWidget {
  final Listing listing;
  final GlobalKey<FormState> formKey;
  final TextEditingController quantityController;
  final bool isSubmitting;
  final VoidCallback onQuantityChanged;
  final VoidCallback onSubmit;

  const _BuyTokenContent({
    required this.listing,
    required this.formKey,
    required this.quantityController,
    required this.isSubmitting,
    required this.onQuantityChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final assetName =
        _assetName(listing);

    final tokenCode =
        listing.token?.tokenCode ??
        'TOKEN-${listing.tokenId}';

    final currency =
        listing.currency.trim().isEmpty
            ? 'KES'
            : listing.currency.trim();

    final canBuy = _canBuy(listing);

    final estimatedTotal =
        _calculateEstimatedTotal(
      quantityController.text.trim(),
      listing.pricePerToken,
    );

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          32,
        ),
        children: [
          _ListingHeader(
            listing: listing,
            assetName: assetName,
            tokenCode: tokenCode,
          ),

          const SizedBox(height: 20),

          _PriceCard(
            listing: listing,
            currency: currency,
          ),

          const SizedBox(height: 20),

          if (!canBuy)
            _UnavailableCard(
              status: listing.status,
            ),

          if (canBuy) ...[
            _QuantityCard(
              listing: listing,
              quantityController:
                  quantityController,
              onChanged: onQuantityChanged,
            ),

            const SizedBox(height: 16),

            _TotalCard(
              currency: currency,
              total: estimatedTotal,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed:
                    isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(
                        Icons
                            .shopping_cart_checkout_rounded,
                      ),
                label: Text(
                  isSubmitting
                      ? 'Processing...'
                      : 'Buy Tokens',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      colorScheme.primary,
                  foregroundColor:
                      colorScheme.onPrimary,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          _InformationCard(
            listing: listing,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String? _validateQuantity(
    String? value,
  ) {
    final quantity = value?.trim() ?? '';

    if (quantity.isEmpty) {
      return 'Enter the quantity you want to buy.';
    }

    if (!_isPositiveDecimal(quantity)) {
      return 'Enter a valid positive quantity.';
    }

    if (_compareDecimalStrings(
          quantity,
          listing.remainingQuantity,
        ) >
        0) {
      return 'Quantity exceeds the available '
          'listing quantity.';
    }

    final decimals =
        _decimalPlaces(quantity);

    final tokenDecimals =
        listing.token?.decimals ?? 8;

    if (decimals > tokenDecimals) {
      return 'This token supports a maximum of '
          '$tokenDecimals decimal places.';
    }

    return null;
  }

  bool _canBuy(
    Listing listing,
  ) {
    final remaining =
        listing.remainingQuantity.trim();

    if (remaining.isEmpty) {
      return false;
    }

    if (!_isPositiveDecimal(remaining)) {
      return false;
    }

    final status =
        listing.status.toLowerCase();

    return status == 'active' ||
        status == 'partially_filled';
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _assetName(
    Listing listing,
  ) {
    final assetName =
        listing.assetName?.trim();

    if (assetName != null &&
        assetName.isNotEmpty) {
      return assetName;
    }

    final tokenName =
        listing.token?.tokenName.trim();

    if (tokenName != null &&
        tokenName.isNotEmpty) {
      return tokenName;
    }

    return 'Tokenized Asset';
  }

  String _calculateEstimatedTotal(
    String quantity,
    String price,
  ) {
    if (quantity.isEmpty ||
        !_isPositiveDecimal(quantity) ||
        !_isPositiveDecimal(price)) {
      return '0';
    }

    return _multiplyDecimalStrings(
      quantity,
      price,
    );
  }

  // ============================================================
  // DECIMAL HELPERS
  // ============================================================

  bool _isPositiveDecimal(
    String value,
  ) {
    final normalized =
        value.trim();

    if (normalized.isEmpty) {
      return false;
    }

    final regex = RegExp(
      r'^\d+(\.\d+)?$',
    );

    if (!regex.hasMatch(normalized)) {
      return false;
    }

    final digits =
        normalized.replaceAll('.', '');

    return BigInt.parse(digits) >
        BigInt.zero;
  }

  int _decimalPlaces(
    String value,
  ) {
    final index = value.indexOf('.');

    if (index == -1) {
      return 0;
    }

    return value.length - index - 1;
  }

  int _compareDecimalStrings(
    String a,
    String b,
  ) {
    final normalizedA =
        _normalizeDecimal(a);
    final normalizedB =
        _normalizeDecimal(b);

    final partsA =
        normalizedA.split('.');
    final partsB =
        normalizedB.split('.');

    final integerA =
        partsA[0].isEmpty
            ? '0'
            : partsA[0];

    final integerB =
        partsB[0].isEmpty
            ? '0'
            : partsB[0];

    final integerComparison =
        BigInt.parse(integerA)
            .compareTo(
      BigInt.parse(integerB),
    );

    if (integerComparison != 0) {
      return integerComparison;
    }

    final fractionA =
        partsA.length > 1
            ? partsA[1]
            : '';

    final fractionB =
        partsB.length > 1
            ? partsB[1]
            : '';

    final maxLength =
        fractionA.length >
                fractionB.length
            ? fractionA.length
            : fractionB.length;

    final paddedA =
        fractionA.padRight(
      maxLength,
      '0',
    );

    final paddedB =
        fractionB.padRight(
      maxLength,
      '0',
    );

    return BigInt.parse(
      paddedA.isEmpty
          ? '0'
          : paddedA,
    ).compareTo(
      BigInt.parse(
        paddedB.isEmpty
            ? '0'
            : paddedB,
      ),
    );
  }

  String _normalizeDecimal(
    String value,
  ) {
    var normalized =
        value.trim();

    if (normalized.startsWith('+')) {
      normalized =
          normalized.substring(1);
    }

    if (normalized.startsWith('.')) {
      normalized =
          '0$normalized';
    }

    final parts =
        normalized.split('.');

    var integerPart =
        parts[0].isEmpty
            ? '0'
            : parts[0];

    var fractionPart =
        parts.length > 1
            ? parts[1]
            : '';

    integerPart =
        integerPart.replaceFirst(
      RegExp(r'^0+(?=\d)'),
      '',
    );

    fractionPart =
        fractionPart.replaceFirst(
      RegExp(r'0+$'),
      '',
    );

    if (fractionPart.isEmpty) {
      return integerPart;
    }

    return '$integerPart.$fractionPart';
  }

  String _multiplyDecimalStrings(
    String a,
    String b,
  ) {
    final normalizedA =
        _normalizeDecimal(a);
    final normalizedB =
        _normalizeDecimal(b);

    final partsA =
        normalizedA.split('.');
    final partsB =
        normalizedB.split('.');

    final digitsA =
        partsA.join('');
    final digitsB =
        partsB.join('');

    final scaleA =
        partsA.length > 1
            ? partsA[1].length
            : 0;

    final scaleB =
        partsB.length > 1
            ? partsB[1].length
            : 0;

    final integerA =
        BigInt.parse(digitsA);
    final integerB =
        BigInt.parse(digitsB);

    final product =
        integerA * integerB;

    final totalScale =
        scaleA + scaleB;

    if (totalScale == 0) {
      return product.toString();
    }

    var productString =
        product.toString();

    while (productString.length <=
        totalScale) {
      productString =
          '0$productString';
    }

    final splitPosition =
        productString.length -
            totalScale;

    var result =
        '${productString.substring(0, splitPosition)}.'
        '${productString.substring(splitPosition)}';

    result =
        result.replaceFirst(
      RegExp(r'0+$'),
      '',
    );

    result =
        result.replaceFirst(
      RegExp(r'\.$'),
      '',
    );

    if (result.isEmpty) {
      return '0';
    }

    return result;
  }
}

// ============================================================
// LISTING HEADER
// ============================================================

class _ListingHeader extends StatelessWidget {
  final Listing listing;
  final String assetName;
  final String tokenCode;

  const _ListingHeader({
    required this.listing,
    required this.assetName,
    required this.tokenCode,
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
          assetName,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Icons.token_rounded,
              label: tokenCode,
            ),
            if (listing.assetType != null &&
                listing.assetType!
                    .trim()
                    .isNotEmpty)
              _InfoChip(
                icon:
                    Icons.category_rounded,
                label:
                    _displayAssetType(
                  listing.assetType!,
                ),
              ),
            _StatusChip(
              status: listing.status,
            ),
          ],
        ),
        if (listing.assetLocation != null &&
            listing.assetLocation!
                .trim()
                .isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 19,
                color: colorScheme
                    .onSurfaceVariant,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  listing.assetLocation!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _displayAssetType(
    String value,
  ) {
    switch (value.toLowerCase()) {
      case 'land':
        return 'Land';
      case 'livestock':
        return 'Livestock';
      case 'produce':
        return 'Produce';
      case 'property':
        return 'Property';
      case 'vehicle':
        return 'Vehicle';
      case 'equipment':
        return 'Equipment';
      case 'other':
        return 'Other';
      default:
        return value;
    }
  }
}

// ============================================================
// PRICE CARD
// ============================================================

class _PriceCard extends StatelessWidget {
  final Listing listing;
  final String currency;

  const _PriceCard({
    required this.listing,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary
                .withValues(alpha: 0.18),
            blurRadius: 24,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Price per Token',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(
                  color: colorScheme
                      .onPrimary
                      .withValues(
                    alpha: 0.78,
                  ),
                  fontWeight:
                      FontWeight.w600,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            '$currency ${listing.pricePerToken}',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
                  color:
                      colorScheme.onPrimary,
                  fontWeight:
                      FontWeight.w900,
                ),
          ),
          const SizedBox(height: 20),
          Divider(
            color: colorScheme
                .onPrimary
                .withValues(alpha: 0.18),
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Available',
                  value:
                      listing.remainingQuantity,
                  color:
                      colorScheme.onPrimary,
                ),
              ),
              Container(
                width: 1,
                height: 42,
                color: colorScheme
                    .onPrimary
                    .withValues(
                  alpha: 0.18,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Total Listed',
                  value: listing.quantity,
                  color:
                      colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QUANTITY CARD
// ============================================================

class _QuantityCard extends StatelessWidget {
  final Listing listing;
  final TextEditingController quantityController;
  final VoidCallback onChanged;

  const _QuantityCard({
    required this.listing,
    required this.quantityController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final decimals =
        listing.token?.decimals ?? 8;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            colorScheme.surfaceContainerLow,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase Quantity',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter the number of tokens you '
            'want to purchase.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: colorScheme
                      .onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller:
                quantityController,
            keyboardType:
                const TextInputType
                    .numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter
                  .allow(
                RegExp(
                  r'^\d*\.?\d*$',
                ),
              ),
            ],
            onChanged: (_) {
              onChanged();
            },
            validator: (value) {
              final quantity =
                  value?.trim() ?? '';

              if (quantity.isEmpty) {
                return 'Enter the quantity you '
                    'want to buy.';
              }

              final valid =
                  RegExp(
                r'^\d+(\.\d+)?$',
              ).hasMatch(quantity);

              if (!valid) {
                return 'Enter a valid quantity.';
              }

              if (quantity == '0' ||
                  quantity.startsWith('0.') &&
                      BigInt.parse(
                            quantity
                                .replaceAll(
                                  '.',
                                  '',
                                ),
                          ) ==
                          BigInt.zero) {
                return 'Quantity must be greater '
                    'than zero.';
              }

              if (_compareDecimalStrings(
                    quantity,
                    listing.remainingQuantity,
                  ) >
                  0) {
                return 'Quantity exceeds the '
                    'available amount.';
              }

              if (_decimalPlaces(quantity) >
                  decimals) {
                return 'Maximum $decimals decimal '
                    'places are supported.';
              }

              return null;
            },
            decoration: InputDecoration(
              labelText: 'Token Quantity',
              hintText:
                  'e.g. 10 or 10.5',
              prefixIcon: const Icon(
                Icons.numbers_rounded,
              ),
              suffixText:
                  listing.token?.tokenCode ??
                  'TOKEN-${listing.tokenId}',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Maximum available: '
            '${listing.remainingQuantity}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: colorScheme
                      .onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  int _decimalPlaces(
    String value,
  ) {
    final index =
        value.indexOf('.');

    if (index == -1) {
      return 0;
    }

    return value.length -
        index -
        1;
  }

  int _compareDecimalStrings(
    String a,
    String b,
  ) {
    final normalizedA =
        _normalizeDecimal(a);
    final normalizedB =
        _normalizeDecimal(b);

    final partsA =
        normalizedA.split('.');
    final partsB =
        normalizedB.split('.');

    final integerA =
        partsA[0].isEmpty
            ? '0'
            : partsA[0];

    final integerB =
        partsB[0].isEmpty
            ? '0'
            : partsB[0];

    final integerComparison =
        BigInt.parse(integerA)
            .compareTo(
      BigInt.parse(integerB),
    );

    if (integerComparison != 0) {
      return integerComparison;
    }

    final fractionA =
        partsA.length > 1
            ? partsA[1]
            : '';

    final fractionB =
        partsB.length > 1
            ? partsB[1]
            : '';

    final maxLength =
        fractionA.length >
                fractionB.length
            ? fractionA.length
            : fractionB.length;

    final paddedA =
        fractionA.padRight(
      maxLength,
      '0',
    );

    final paddedB =
        fractionB.padRight(
      maxLength,
      '0',
    );

    return BigInt.parse(
      paddedA.isEmpty
          ? '0'
          : paddedA,
    ).compareTo(
      BigInt.parse(
        paddedB.isEmpty
            ? '0'
            : paddedB,
      ),
    );
  }

  String _normalizeDecimal(
    String value,
  ) {
    var normalized =
        value.trim();

    if (normalized.startsWith('+')) {
      normalized =
          normalized.substring(1);
    }

    if (normalized.startsWith('.')) {
      normalized =
          '0$normalized';
    }

    final parts =
        normalized.split('.');

    var integerPart =
        parts[0].isEmpty
            ? '0'
            : parts[0];

    var fractionPart =
        parts.length > 1
            ? parts[1]
            : '';

    integerPart =
        integerPart.replaceFirst(
      RegExp(r'^0+(?=\d)'),
      '',
    );

    fractionPart =
        fractionPart.replaceFirst(
      RegExp(r'0+$'),
      '',
    );

    if (fractionPart.isEmpty) {
      return integerPart;
    }

    return '$integerPart.$fractionPart';
  }
}

// ============================================================
// TOTAL CARD
// ============================================================

class _TotalCard extends StatelessWidget {
  final String currency;
  final String total;

  const _TotalCard({
    required this.currency,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            colorScheme.primaryContainer,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary
              .withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color:
                  colorScheme.primary,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.calculate_rounded,
              color:
                  colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Total',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                        color: colorScheme
                            .onPrimaryContainer,
                        fontWeight:
                            FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$currency $total',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        color: colorScheme
                            .onPrimaryContainer,
                        fontWeight:
                            FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFORMATION CARD
// ============================================================

class _InformationCard
    extends StatelessWidget {
  final Listing listing;

  const _InformationCard({
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            colorScheme.surfaceContainerLow,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color:
                colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your purchase will create a buy order '
              'against this marketplace listing. The '
              'final transaction amount is determined '
              'from the quantity and listed token price.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    height: 1.5,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// UNAVAILABLE CARD
// ============================================================

class _UnavailableCard
    extends StatelessWidget {
  final String status;

  const _UnavailableCard({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            colorScheme.errorContainer,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .remove_shopping_cart_rounded,
            color:
                colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Listing Unavailable',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: colorScheme
                            .onErrorContainer,
                        fontWeight:
                            FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'This listing is currently not '
                  'available for purchase. Current '
                  'status: ${_statusLabel(status)}.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: colorScheme
                            .onErrorContainer,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(
    String value,
  ) {
    return value
        .replaceAll('_', ' ')
        .toUpperCase();
  }
}

// ============================================================
// INFO CHIP
// ============================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
            colorScheme.surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color:
                colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATUS CHIP
// ============================================================

class _StatusChip
    extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final normalized =
        status.toLowerCase();

    final available =
        normalized == 'active' ||
        normalized == 'partially_filled';

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: available
            ? colorScheme.primaryContainer
            : colorScheme
                .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Text(
        normalized
            .replaceAll('_', ' ')
            .toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(
              color: available
                  ? colorScheme
                      .onPrimaryContainer
                  : colorScheme
                      .onSurfaceVariant,
              fontWeight:
                  FontWeight.w800,
            ),
      ),
    );
  }
}

// ============================================================
// METRIC
// ============================================================

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: color.withValues(
                    alpha: 0.72,
                  ),
                ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  color: color,
                  fontWeight:
                      FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView
    extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color:
                    colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color: colorScheme
                    .onErrorContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load listing',
              textAlign:
                  TextAlign.center,
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
              'The listing details could not be '
              'loaded. Please try again.',
              textAlign:
                  TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label:
                  const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}