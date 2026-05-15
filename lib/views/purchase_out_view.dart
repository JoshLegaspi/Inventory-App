import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/purchase.dart';
import '../models/purchase_repository.dart';
import '../models/purchaser_repository.dart';
import '../models/purchaser.dart';
import '../models/product_repository.dart';
import '../models/product.dart';
import '../models/activity_log_repository.dart';
import 'activity_log_view.dart';
import 'dashboard_view.dart';
import 'inventory_view.dart';
import 'login_view.dart';
import 'purchaser_view.dart';
import 'supplier_view.dart';

class PurchaseOutView extends StatefulWidget {
  const PurchaseOutView({Key? key}) : super(key: key);

  @override
  State<PurchaseOutView> createState() => _PurchaseOutViewState();
}

class _PurchaseOutViewState extends State<PurchaseOutView> {
  final PurchaseRepository _purchaseRepository = PurchaseRepository();
  final PurchaserRepository _purchaserRepository = PurchaserRepository();
  final ProductRepository _productRepository = ProductRepository();
  final ActivityLogRepository _activityLogRepository = ActivityLogRepository();

  late Future<List<Purchase>> _purchasesFuture;
  String _searchQuery = '';
  String _filterBy = 'all'; // all, fully_paid, installments

  @override
  void initState() {
    super.initState();
    _purchasesFuture = _purchaseRepository.getAllPurchases();
  }

  void _refreshPurchases() {
    setState(() {
      _purchasesFuture = _purchaseRepository.getAllPurchases();
    });
  }

  Future<void> _showAddPurchaseDialog() async {
    final purchasers = await _purchaserRepository.getAllPurchasers();
    final products = await _productRepository.getAllProducts();

    if (!mounted) return;

    Purchaser? selectedPurchaser;
    Product? selectedProduct;
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    String paymentStatus = 'fully_paid';
    final installmentCountController = TextEditingController(text: '1');
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.shopping_cart_checkout, color: Color(0xFF258181)),
                  SizedBox(width: 8),
                  Text('Record Sale (OUT)'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Purchaser Dropdown
                    DropdownButtonFormField<Purchaser>(
                      value: selectedPurchaser,
                      items: purchasers
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text('${p.name} (${p.company})'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPurchaser = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Purchaser',
                        prefixIcon: const Icon(Icons.person),
                        border:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      isExpanded: true,
                    ),
                    const SizedBox(height: 12),

                    // Product Dropdown
                    DropdownButtonFormField<Product>(
                      value: selectedProduct,
                      items: products
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                    '${p.name} (Qty: ${p.quantity}, ₱${p.price.toStringAsFixed(2)})'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProduct = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Product',
                        prefixIcon: const Icon(Icons.shopping_bag),
                        border:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      isExpanded: true,
                    ),
                    const SizedBox(height: 12),

                    // Quantity
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity to Sell',
                        prefixIcon: const Icon(Icons.inventory_2),
                        border:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: '0',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // Payment Status
                    DropdownButtonFormField<String>(
                      value: paymentStatus,
                      items: const [
                        DropdownMenuItem(
                          value: 'fully_paid',
                          child: Text('Fully Paid'),
                        ),
                        DropdownMenuItem(
                          value: 'installments',
                          child: Text('Installment Plan'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          paymentStatus = value ?? 'fully_paid';
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Payment Status',
                        prefixIcon: const Icon(Icons.payment),
                        border:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Installment Count (if installments selected)
                    if (paymentStatus == 'installments')
                      TextField(
                        controller: installmentCountController,
                        decoration: InputDecoration(
                          labelText: 'Number of Installments',
                          prefixIcon: const Icon(Icons.calendar_month),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          hintText: '1',
                        ),
                        keyboardType: TextInputType.number,
                      ),

                    if (paymentStatus == 'installments')
                      const SizedBox(height: 12),

                    // Notes
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        prefixIcon: const Icon(Icons.note),
                        border:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: 'Add any notes about this sale',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    // Validation
                    if (selectedPurchaser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a purchaser'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (selectedProduct == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a product'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (quantityController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter quantity'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final quantityText = quantityController.text;
                    final int quantity = int.tryParse(quantityText) ?? 0;
                    if (quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid quantity'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (quantity > selectedProduct!.quantity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Insufficient stock. Available: ${selectedProduct!.quantity}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      setState(() => isSaving = true);
                      final totalAmount = selectedProduct!.price * quantity;
                      final installmentCount = int.tryParse(installmentCountController.text) ?? 1;
                      final installmentAmount = paymentStatus == 'installments' ? (totalAmount / installmentCount) : 0.0;

                      // Create purchase record
                      await _purchaseRepository.recordSale(
                        productId: selectedProduct!.id,
                        purchaserId: selectedPurchaser!.id,
                        quantity: quantity,
                        unitPrice: selectedProduct!.price, // Added unitPrice
                        totalPrice: totalAmount,
                        paymentStatus: paymentStatus,
                        installmentCount: installmentCount,
                        installmentAmount: installmentAmount,
                        notes: notesController.text, // Added notes
                      );

                      // Update product inventory (deduct quantity)
                      await _productRepository.updateStock(selectedProduct!.id, selectedProduct!.quantity - quantity);

                      // Update purchaser statistics
                      await _purchaserRepository.updatePurchaserStats(
                        selectedPurchaser!.id,
                        addToTotalSpent: totalAmount,
                        addToTotalOrders: 1,
                      );

                      // Log activity
                      await _activityLogRepository.log(
                        'Stock OUT',
                        '$quantity units of "${selectedProduct!.name}" sold to ${selectedPurchaser!.name}',
                      );

                      if (this.mounted) {
                        _refreshPurchases();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sale recorded successfully - $quantity units sold'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Error recording sale: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to record sale: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => isSaving = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF258181),
                  ),
                  child: isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Record Sale', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showClearHistoryConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Stock OUT History'),
          content: const Text(
              'Are you sure you want to clear all sales history? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _purchaseRepository.clearAllPurchases();
                await _activityLogRepository.clearLogsByAction('Stock OUT');
                _refreshPurchases();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sales history cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                    (route) => false,
                  );
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showLogoutConfirmation(context);
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Stock OUT (Sales)'),
        backgroundColor: const Color(0xFF258181),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear History',
            onPressed: () => _showClearHistoryConfirmation(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF258181)),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Inventory (IN)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InventoryView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Sales (OUT)'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Activity Log'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ActivityLogView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Purchaser'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PurchaserView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Supplier'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SupplierView()),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Statistics Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<Purchase>>(
              future: _purchasesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final purchases = snapshot.data!;
                final fullyPaidTotal = purchases
                    .where((p) => p.paymentStatus == 'fully_paid')
                    .fold(0.0, (sum, p) => sum + p.totalAmount);
                final installmentTotal = purchases
                    .where((p) => p.paymentStatus == 'installments')
                    .fold(0.0, (sum, p) => sum + p.totalAmount);
                final totalItems = purchases.fold(0, (sum, p) => sum + p.quantity);

                return Row(
                  children: [
                    _buildStatCard('Total Sales', '₱${(fullyPaidTotal + installmentTotal).toStringAsFixed(2)}', Colors.green),
                    const SizedBox(width: 12),
                    _buildStatCard('Fully Paid', '₱${fullyPaidTotal.toStringAsFixed(2)}', Colors.blue),
                    const SizedBox(width: 12),
                    _buildStatCard('Installments', '₱${installmentTotal.toStringAsFixed(2)}', Colors.orange),
                    const SizedBox(width: 12),
                    _buildStatCard('Items Sold', totalItems.toString(), Colors.purple),
                  ],
                );
              },
            ),
          ),

          // Search and Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search sales...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _filterBy,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(
                        value: 'fully_paid', child: Text('Fully Paid')),
                    DropdownMenuItem(
                        value: 'installments', child: Text('Installments')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterBy = value ?? 'all';
                    });
                  },
                ),
              ],
            ),
          ),

          // Sales List
          Expanded(
            child: FutureBuilder<List<Purchase>>(
              future: _purchasesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF258181)),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No sales recorded yet'),
                  );
                }

                var purchases = snapshot.data!;

                // Apply filter
                if (_filterBy != 'all') {
                  purchases = purchases
                      .where((p) => p.paymentStatus == _filterBy)
                      .toList();
                }

                // Apply search
                if (_searchQuery.isNotEmpty) {
                  purchases = purchases
                      .where((p) =>
                          p.purchaserName
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          p.productName
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                return ListView.builder(
                  itemCount: purchases.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final purchase = purchases[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: purchase.paymentStatus == 'fully_paid'
                              ? Colors.green
                              : Colors.orange,
                          child: Icon(
                            purchase.paymentStatus == 'fully_paid'
                                ? Icons.check
                                : Icons.schedule,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(purchase.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Buyer: ${purchase.purchaserName}'),
                            Text(
                                'Qty: ${purchase.quantity} × ₱${purchase.unitPrice.toStringAsFixed(2)}'),
                            Text(
                              'Total: ₱${purchase.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF258181),
                              ),
                            ),
                            if (purchase.paymentStatus == 'installments')
                              Text(
                                  'Installments: ${purchase.installmentCount} × ₱${purchase.installmentAmount?.toStringAsFixed(2) ?? '0.00'}'),
                          ],
                        ),
                        trailing: Text(
                          purchase.paymentStatus == 'fully_paid'
                              ? 'Paid'
                              : 'Pending',
                          style: TextStyle(
                            color: purchase.paymentStatus == 'fully_paid'
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPurchaseDialog,
        backgroundColor: const Color(0xFF258181),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
