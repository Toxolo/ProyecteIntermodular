class User {
  late int id;
  late String name;
  String? accesToken;
  late String? refreshToken;
  late bool isAdmin;
  late bool hasSuscription;
  DateTime? tokenExpiration;

  // ==================== SETTERS =====================

  void setId(int id) => this.id = id;

  void setName(String name) => this.name = name;

  void setAccesToken(String token) => accesToken = token;

  void setRefreshToken(String token) => refreshToken = token;

  void setIsAdmin(bool isAdmin) => this.isAdmin = isAdmin;

  void setHasSuscription(bool sub) => hasSuscription = sub;

  void setTokenExpiration(DateTime d) => tokenExpiration = d;

  // ==================== GETTERS =====================
  int getId() {
    return id;
  }

  String getName() {
    return name;
  }

  String? getAccesToken() {
    return accesToken;
  }

  String? getRefreshToken() {
    return refreshToken;
  }

  bool getIsAdmin() {
    return isAdmin;
  }

  bool getHasSuscription() {
    return hasSuscription;
  }

  DateTime? getTokenExpiration() {
    return tokenExpiration;
  }

  // ==================== Metodes =====================

  /// Checks if token is about to expire (within 10 seconds by default)
  bool isTokenExpiringSoon({
    Duration warningTime = const Duration(seconds: 10),
  }) {
    if (tokenExpiration == null) return false;
    final now = DateTime.now().toUtc();
    final timeUntilExpiry = tokenExpiration!.difference(now);
    return timeUntilExpiry.isNegative || timeUntilExpiry <= warningTime;
  }

  /// Call this to handle token refresh when expiration is near
  void onTokenExpirationWarning(Function() onExpire) {
    if (isTokenExpiringSoon()) {
      onExpire();
    }
  }

  void clearTokens() {
    setAccesToken("");
    setRefreshToken("");
  }

  DateTime formatExp(int exp) {
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
  }
}
