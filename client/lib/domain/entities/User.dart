class User {
  late int id;
  late String name;
  String? accesToken;
  late String? refreshToken;
  late bool isAdmin;
  late bool hasSuscription;

  // ==================== SETTERS =====================

  void setId(int id) => this.id = id;

  void setName(String name) => this.name = name;

  void setAccesToken(String token) => accesToken = token;

  void setRefreshToken(String token) => refreshToken = token;

  void setIsAdmin(bool isAdmin) => this.isAdmin = isAdmin;

  void setHasSuscription(bool sub) => hasSuscription = sub;

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

  // ==================== METHODS =====================

  void clearTokens() {
    setAccesToken("");
    setRefreshToken("");
  }
}
