// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(billingQuota)
final billingQuotaProvider = BillingQuotaProvider._();

final class BillingQuotaProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          FutureOr<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  BillingQuotaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingQuotaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingQuotaHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    return billingQuota(ref);
  }
}

String _$billingQuotaHash() => r'b6e9670aa64603cfa4d099758b1cd47154f3c4ac';
