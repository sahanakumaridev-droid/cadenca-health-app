abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For simplicity, we'll assume network is always available
    // In a real app, you would use connectivity_plus package
    return true;
  }
}
