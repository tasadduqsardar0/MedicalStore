class StoreSettings {
  final String storeName;
  final String address;
  final String phone;
  final String receiptFooter;
  final int nearExpiryDays; // default 30
  final int autoLogoutMinutes; // default 10, 0 = off
  final bool isFirstRunCompleted;

  const StoreSettings({
    this.storeName = 'Tariq Medical Store',
    this.address = 'Main Bazaar, Hujra Shah Muqeem',
    this.phone = '0300-1234567',
    this.receiptFooter = 'Get well soon! Check medicine expiry before leaving.',
    this.nearExpiryDays = 30,
    this.autoLogoutMinutes = 10,
    this.isFirstRunCompleted = false,
  });

  StoreSettings copyWith({
    String? storeName,
    String? address,
    String? phone,
    String? receiptFooter,
    int? nearExpiryDays,
    int? autoLogoutMinutes,
    bool? isFirstRunCompleted,
  }) {
    return StoreSettings(
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      nearExpiryDays: nearExpiryDays ?? this.nearExpiryDays,
      autoLogoutMinutes: autoLogoutMinutes ?? this.autoLogoutMinutes,
      isFirstRunCompleted: isFirstRunCompleted ?? this.isFirstRunCompleted,
    );
  }
}

