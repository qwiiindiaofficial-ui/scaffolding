import 'dart:async';
import 'package:scaffolding_sale/screens/purchase/model.dart';

class PartyService {
  static final PartyService _instance = PartyService._internal();
  factory PartyService() => _instance;
  PartyService._internal();

  final List<Party> _parties = [
    Party(
      name: 'Elatio By Gards LLP',
      address: 'A-388 Ground Floor Sudama Puri, Uttar Pradesh',
      gst: '07ABCDE1234F1Z5',
      mobile: '9876543210',
    ),
    Party(
      name: 'Sharma Steels Pvt Ltd',
      address: 'Industrial Area, Phase 1, Delhi',
      gst: '07XYZAB9876C1Z1',
      mobile: '9988776655',
    ),
    Party(
      name: 'Rajesh Enterprises',
      address: 'Sector 12, Noida, UP',
      gst: '09PQRST5678G2A3',
      mobile: '9123456789',
    ),
    Party(
      name: 'Kumar Trading Co',
      address: 'MG Road, Bangalore',
      gst: '29LMNOP4321H3B4',
      mobile: '9876501234',
    ),
  ];

  List<Party> getParties() => _parties;
}

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;

  final _dataStreamController = StreamController<void>.broadcast();

  final List<Purchase> _purchases = [];
  final List<PaymentEntry> _payments = [];

  PurchaseService._internal() {
    _loadDummyData();
  }

  Stream<void> get dataStream => _dataStreamController.stream;
  List<Purchase> get purchases => _purchases;
  List<PaymentEntry> get payments => _payments;

  void _loadDummyData() {
    // Purchase 1 - Elatio By Gards LLP
    _purchases.add(Purchase(
      purchaseNo: 'PUR-001',
      invoiceNo: 'INV-882',
      partyName: 'Elatio By Gards LLP',
      taxType: 'GST',
      date: DateTime(2024, 11, 15),
      hsnCode: '7308',
      items: [
        Item(name: 'Cuplock Vertical', size: '3M', quantity: 50, rate: 800),
        Item(name: 'Ledger', size: '2M', quantity: 100, rate: 400),
        Item(name: 'Base Jack', quantity: 25, rate: 200),
      ],
      cgst: 4050,
      sgst: 4050,
    )); // Total: 45000, Tax: 8100, Grand: 53100

    // Purchase 2 - Sharma Steels
    _purchases.add(Purchase(
      purchaseNo: 'PUR-002',
      invoiceNo: 'INV-990',
      partyName: 'Sharma Steels Pvt Ltd',
      taxType: 'GST',
      date: DateTime(2024, 11, 20),
      hsnCode: '7308',
      items: [
        Item(name: 'MS Pipe', size: '6M', quantity: 100, rate: 350),
        Item(name: 'Clamps', quantity: 200, rate: 50),
      ],
      cgst: 2385,
      sgst: 2385,
    )); // Total: 45000, Tax: 4770, Grand: 49770

    // Purchase 3 - Elatio By Gards LLP
    _purchases.add(Purchase(
      purchaseNo: 'PUR-003',
      invoiceNo: 'INV-1001',
      partyName: 'Elatio By Gards LLP',
      taxType: 'GST',
      date: DateTime(2024, 11, 25),
      hsnCode: '7308',
      items: [
        Item(name: 'Scaffolding Boards', size: '4M', quantity: 30, rate: 600),
        Item(name: 'Safety Nets', quantity: 10, rate: 1500),
      ],
      cgst: 1935,
      sgst: 1935,
    )); // Total: 33000, Tax: 3870, Grand: 36870

    // Purchase 4 - Rajesh Enterprises
    _purchases.add(Purchase(
      purchaseNo: 'PUR-004',
      invoiceNo: 'INV-445',
      partyName: 'Rajesh Enterprises',
      taxType: 'GST',
      date: DateTime(2024, 11, 28),
      hsnCode: '7308',
      items: [
        Item(name: 'H-Frame', size: '6x4', quantity: 40, rate: 950),
        Item(name: 'Cross Braces', quantity: 80, rate: 180),
      ],
      cgst: 3078,
      sgst: 3078,
    )); // Total: 52400, Tax: 6156, Grand: 58556

    // Purchase 5 - Kumar Trading Co
    _purchases.add(Purchase(
      purchaseNo: 'PUR-005',
      invoiceNo: 'INV-223',
      partyName: 'Kumar Trading Co',
      taxType: 'GST',
      date: DateTime(2024, 12, 1),
      hsnCode: '7308',
      items: [
        Item(name: 'Toe Boards', size: '2M', quantity: 60, rate: 120),
        Item(name: 'Guard Rails', size: '3M', quantity: 40, rate: 280),
      ],
      cgst: 1170,
      sgst: 1170,
    )); // Total: 18400, Tax: 2340, Grand: 20740

    // Payments
    _payments.add(PaymentEntry(
      id: 'PAY-001',
      partyName: 'Elatio By Gards LLP',
      date: DateTime(2024, 11, 18),
      amount: 30000,
      mode: 'Bank Transfer',
    ));

    _payments.add(PaymentEntry(
      id: 'PAY-002',
      partyName: 'Sharma Steels Pvt Ltd',
      date: DateTime(2024, 11, 22),
      amount: 49770,
      mode: 'Cash',
    ));

    _payments.add(PaymentEntry(
      id: 'PAY-003',
      partyName: 'Elatio By Gards LLP',
      date: DateTime(2024, 11, 27),
      amount: 40000,
      mode: 'UPI',
    ));

    _payments.add(PaymentEntry(
      id: 'PAY-004',
      partyName: 'Rajesh Enterprises',
      date: DateTime(2024, 11, 30),
      amount: 20000,
      mode: 'Cheque',
    ));
  }

  List<PartyDueSummary> getPartyDues() {
    Map<String, double> purchaseMap = {};
    Map<String, double> paymentMap = {};
    Set<String> allParties = {};

    for (var p in _purchases) {
      purchaseMap[p.partyName] = (purchaseMap[p.partyName] ?? 0) + p.grandTotal;
      allParties.add(p.partyName);
    }

    for (var p in _payments) {
      paymentMap[p.partyName] = (paymentMap[p.partyName] ?? 0) + p.amount;
      allParties.add(p.partyName);
    }

    List<PartyDueSummary> summary = [];
    for (var party in allParties) {
      summary.add(PartyDueSummary(
        partyName: party,
        totalPurchased: purchaseMap[party] ?? 0,
        totalPaid: paymentMap[party] ?? 0,
      ));
    }

    summary.sort((a, b) => b.balanceDue.compareTo(a.balanceDue));
    return summary;
  }

  // Get ledger entries for a specific party
  List<LedgerEntry> getPartyLedger(String partyName) {
    List<LedgerEntry> entries = [];
    double runningBalance = 0;

    // Combine purchases and payments
    List<dynamic> allTransactions = [];

    for (var purchase in _purchases) {
      if (purchase.partyName == partyName) {
        allTransactions.add({'type': 'purchase', 'data': purchase});
      }
    }

    for (var payment in _payments) {
      if (payment.partyName == partyName) {
        allTransactions.add({'type': 'payment', 'data': payment});
      }
    }

    // Sort by date
    allTransactions.sort((a, b) {
      DateTime dateA = a['type'] == 'purchase'
          ? (a['data'] as Purchase).date
          : (a['data'] as PaymentEntry).date;
      DateTime dateB = b['type'] == 'purchase'
          ? (b['data'] as Purchase).date
          : (b['data'] as PaymentEntry).date;
      return dateA.compareTo(dateB);
    });

    // Create ledger entries
    for (var transaction in allTransactions) {
      if (transaction['type'] == 'purchase') {
        Purchase p = transaction['data'] as Purchase;
        runningBalance += p.grandTotal;
        entries.add(LedgerEntry(
          date: p.date,
          type: 'Purchase',
          referenceNo: p.invoiceNo,
          debit: p.grandTotal,
          credit: 0,
          balance: runningBalance,
        ));
      } else {
        PaymentEntry p = transaction['data'] as PaymentEntry;
        runningBalance -= p.amount;
        entries.add(LedgerEntry(
          date: p.date,
          type: 'Payment',
          referenceNo: p.id,
          debit: 0,
          credit: p.amount,
          balance: runningBalance,
        ));
      }
    }

    return entries;
  }

  void addPurchase(Purchase purchase) {
    _purchases.insert(0, purchase);
    _dataStreamController.add(null);
  }

  void addPayment(PaymentEntry payment) {
    _payments.insert(0, payment);
    _dataStreamController.add(null);
  }

  void dispose() {
    _dataStreamController.close();
  }
}
