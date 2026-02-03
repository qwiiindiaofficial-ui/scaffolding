import 'package:flutter/material.dart';

// --- MODELS ---

class Purchase {
  final String purchaseNo;
  final String invoiceNo;
  final String partyName;
  final String taxType;
  final DateTime date;
  final String hsnCode;
  final List<Item> items;
  final double totalAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double grandTotal;

  Purchase({
    required this.purchaseNo,
    required this.invoiceNo,
    required this.partyName,
    required this.taxType,
    required this.date,
    required this.hsnCode,
    required this.items,
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
  })  : totalAmount = items.fold(0, (sum, item) => sum + item.amount),
        grandTotal = items.fold(
            0, (sum, item) => (sum + item.amount) + cgst + sgst + igst);
}

class Item {
  final String name;
  final String? size;
  final int quantity;
  final double rate;
  final double amount;

  Item({
    required this.name,
    this.size,
    required this.quantity,
    required this.rate,
  }) : amount = quantity * rate;
}

class Party {
  final String name;
  final String address;
  final String gst;
  final String mobile;

  Party({
    required this.name,
    required this.address,
    required this.gst,
    required this.mobile,
  });
}

// Payment Entry Model
class PaymentEntry {
  final String id;
  final String partyName;
  final DateTime date;
  final double amount;
  final String mode; // Cash, UPI, Cheque, Bank Transfer

  PaymentEntry({
    required this.id,
    required this.partyName,
    required this.date,
    required this.amount,
    required this.mode,
  });
}

// Party Dues Summary
class PartyDueSummary {
  final String partyName;
  final double totalPurchased;
  final double totalPaid;
  final double balanceDue;

  PartyDueSummary({
    required this.partyName,
    required this.totalPurchased,
    required this.totalPaid,
  }) : balanceDue = totalPurchased - totalPaid;
}

// Ledger Entry for Party Ledger View
class LedgerEntry {
  final DateTime date;
  final String type; // 'Purchase' or 'Payment'
  final String referenceNo; // Invoice No or Payment ID
  final double debit; // Purchase amount
  final double credit; // Payment amount
  final double balance;

  LedgerEntry({
    required this.date,
    required this.type,
    required this.referenceNo,
    required this.debit,
    required this.credit,
    required this.balance,
  });
}
