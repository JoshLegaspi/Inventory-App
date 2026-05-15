class StockCalculator {
  /// Calculate stock alert level based on product category
  static int getReorderLevel(String category) {
    return switch (category) {
      'Electronics' => 10,
      'Accessories' => 20,
      'Software' => 5,
      'Services' => 0,
      _ => 15,
    };
  }

  /// Calculate optimal order quantity using EOQ formula
  static int getEconomicOrderQuantity({
    required int annualDemand,
    required double orderingCost,
    required double holdingCost,
  }) {
    if (orderingCost <= 0 || holdingCost <= 0) return 100;
    double eoq = 2 * annualDemand * orderingCost / holdingCost;
    return (eoq).ceil();
  }

  /// Check if stock level is low
  static bool isLowStock(int currentQuantity, int threshold) {
    return currentQuantity < threshold;
  }

  /// Calculate days of stock based on daily usage
  static int getDaysOfStock(int currentQuantity, int dailyUsage) {
    if (dailyUsage == 0) return 0;
    return (currentQuantity / dailyUsage).ceil();
  }

  /// Calculate stock turnover ratio
  static double getStockTurnoverRatio({
    required double costOfGoodsSold,
    required double averageInventoryValue,
  }) {
    if (averageInventoryValue == 0) return 0;
    return costOfGoodsSold / averageInventoryValue;
  }

  /// Get stock status with color indicator
  static StockStatus getStockStatus(
    int currentQuantity,
    int reorderLevel,
    int optimalLevel,
  ) {
    if (currentQuantity > optimalLevel) {
      return StockStatus.overstocked;
    } else if (currentQuantity >= reorderLevel) {
      return StockStatus.optimal;
    } else if (currentQuantity > 0) {
      return StockStatus.low;
    } else {
      return StockStatus.outOfStock;
    }
  }

  /// Calculate weighted average cost
  static double getWeightedAverageCost(
    List<Map<String, dynamic>> purchases,
  ) {
    double totalCost = 0;
    int totalQuantity = 0;

    for (var purchase in purchases) {
      totalCost += (purchase['quantity'] as int) * (purchase['cost'] as double);
      totalQuantity += purchase['quantity'] as int;
    }

    if (totalQuantity == 0) return 0;
    return totalCost / totalQuantity;
  }

  /// Forecast future stock level
  static int forecastStock({
    required int currentQuantity,
    required int dailyUsage,
    required int daysAhead,
  }) {
    return currentQuantity - (dailyUsage * daysAhead);
  }

  /// Calculate safety stock
  static int calculateSafetyStock({
    required int maxDailyUsage,
    required int maxLeadTime,
    int zScore = 2, // 95% service level
  }) {
    return (zScore * maxDailyUsage * maxLeadTime).toInt();
  }

  /// Calculate reorder point
  static int calculateReorderPoint({
    required int averageDailyUsage,
    required int leadTimeDays,
    required int safetyStock,
  }) {
    return (averageDailyUsage * leadTimeDays) + safetyStock;
  }

  /// Get stock health percentage
  static double getStockHealth(int currentQuantity, int optimalQuantity) {
    if (optimalQuantity == 0) return 0;
    return (currentQuantity / optimalQuantity).clamp(0, 2) * 100; // Max 200%
  }
}

enum StockStatus {
  outOfStock,
  low,
  optimal,
  overstocked,
}

extension StockStatusExtension on StockStatus {
  String get displayName {
    return switch (this) {
      StockStatus.outOfStock => 'Out of Stock',
      StockStatus.low => 'Low Stock',
      StockStatus.optimal => 'Optimal',
      StockStatus.overstocked => 'Overstocked',
    };
  }

  String get color {
    return switch (this) {
      StockStatus.outOfStock => '#FF0000', // Red
      StockStatus.low => '#FFA500', // Orange
      StockStatus.optimal => '#4CAF50', // Green
      StockStatus.overstocked => '#2196F3', // Blue
    };
  }

  String get icon {
    return switch (this) {
      StockStatus.outOfStock => 'error',
      StockStatus.low => 'warning',
      StockStatus.optimal => 'check_circle',
      StockStatus.overstocked => 'inventory_2',
    };
  }
}
