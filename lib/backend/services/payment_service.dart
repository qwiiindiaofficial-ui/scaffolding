import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class PaymentService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getPayments({
    required String companyId,
    String? partyId,
    String? paymentType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var query = _client
        .from('payments')
        .select('*, parties(name, company_name)')
        .eq('company_id', companyId);

    if (partyId != null) {
      query = query.eq('party_id', partyId);
    }

    if (paymentType != null) {
      query = query.eq('payment_type', paymentType);
    }

    if (fromDate != null) {
      query = query.gte('payment_date', fromDate.toIso8601String().split('T')[0]);
    }

    if (toDate != null) {
      query = query.lte('payment_date', toDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('payment_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createPayment({
    required String companyId,
    String? partyId,
    String? invoiceId,
    required String paymentType,
    required DateTime paymentDate,
    required double amount,
    required String paymentMode,
    String? referenceNumber,
    String? notes,
  }) async {
    final data = {
      'company_id': companyId,
      'party_id': partyId,
      'invoice_id': invoiceId,
      'payment_type': paymentType,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'amount': amount,
      'payment_mode': paymentMode,
      'reference_number': referenceNumber,
      'notes': notes,
      'created_by': SupabaseService.currentUserId,
    };

    final response = await _client
        .from('payments')
        .insert(data)
        .select()
        .single();

    if (invoiceId != null) {
      await _updateInvoicePayment(invoiceId, amount);
    }

    if (partyId != null) {
      await _createLedgerEntry(
        companyId: companyId,
        partyId: partyId,
        entryDate: paymentDate,
        entryType: 'payment',
        referenceType: 'payment',
        referenceId: response['id'],
        creditAmount: amount,
        description: 'Payment received via $paymentMode',
      );
    }

    return response;
  }

  Future<void> _updateInvoicePayment(String invoiceId, double paymentAmount) async {
    final invoice = await _client
        .from('invoices')
        .select('paid_amount, total_amount')
        .eq('id', invoiceId)
        .single();

    final paidAmount = (invoice['paid_amount'] ?? 0.0) + paymentAmount;
    final totalAmount = invoice['total_amount'] ?? 0.0;
    final dueAmount = totalAmount - paidAmount;

    await _client.from('invoices').update({
      'paid_amount': paidAmount,
      'due_amount': dueAmount,
      'status': dueAmount <= 0 ? 'billed' : 'current',
    }).eq('id', invoiceId);
  }

  Future<void> _createLedgerEntry({
    required String companyId,
    required String partyId,
    required DateTime entryDate,
    required String entryType,
    String? referenceType,
    String? referenceId,
    String? referenceNumber,
    double debitAmount = 0,
    double creditAmount = 0,
    String? description,
  }) async {
    final previousBalance = await _getPartyBalance(partyId);
    final balance = previousBalance + debitAmount - creditAmount;

    final data = {
      'company_id': companyId,
      'party_id': partyId,
      'entry_date': entryDate.toIso8601String().split('T')[0],
      'entry_type': entryType,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'reference_number': referenceNumber,
      'debit_amount': debitAmount,
      'credit_amount': creditAmount,
      'balance': balance,
      'description': description,
    };

    await _client.from('ledger_entries').insert(data);
  }

  Future<double> _getPartyBalance(String partyId) async {
    final result = await _client
        .from('ledger_entries')
        .select('balance')
        .eq('party_id', partyId)
        .order('created_at', ascending: false)
        .limit(1);

    if (result.isEmpty) {
      return 0.0;
    }

    return (result[0]['balance'] ?? 0.0).toDouble();
  }

  Future<List<Map<String, dynamic>>> getLedgerEntries({
    required String partyId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var query = _client
        .from('ledger_entries')
        .select()
        .eq('party_id', partyId);

    if (fromDate != null) {
      query = query.gte('entry_date', fromDate.toIso8601String().split('T')[0]);
    }

    if (toDate != null) {
      query = query.lte('entry_date', toDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('entry_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getPartySummary(String partyId) async {
    final ledgerEntries = await _client
        .from('ledger_entries')
        .select()
        .eq('party_id', partyId);

    double totalDebit = 0;
    double totalCredit = 0;
    double balance = 0;

    for (var entry in ledgerEntries) {
      totalDebit += (entry['debit_amount'] ?? 0.0);
      totalCredit += (entry['credit_amount'] ?? 0.0);
      balance = (entry['balance'] ?? 0.0);
    }

    return {
      'total_debit': totalDebit,
      'total_credit': totalCredit,
      'balance': balance,
    };
  }

  Future<Map<String, dynamic>> createExpense({
    required String companyId,
    required DateTime expenseDate,
    required String category,
    required double amount,
    required String paymentMode,
    String? description,
    String? receiptUrl,
  }) async {
    final data = {
      'company_id': companyId,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
      'category': category,
      'amount': amount,
      'payment_mode': paymentMode,
      'description': description,
      'receipt_url': receiptUrl,
      'created_by': SupabaseService.currentUserId,
    };

    final response = await _client
        .from('expenses')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getExpenses({
    required String companyId,
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    var query = _client
        .from('expenses')
        .select()
        .eq('company_id', companyId);

    if (fromDate != null) {
      query = query.gte('expense_date', fromDate.toIso8601String().split('T')[0]);
    }

    if (toDate != null) {
      query = query.lte('expense_date', toDate.toIso8601String().split('T')[0]);
    }

    if (category != null) {
      query = query.eq('category', category);
    }

    final response = await query.order('expense_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _client.from('expenses').delete().eq('id', expenseId);
  }

  Future<void> createInvoiceLedgerEntry({
    required String companyId,
    required String partyId,
    required String invoiceId,
    required String invoiceNumber,
    required DateTime invoiceDate,
    required double amount,
  }) async {
    await _createLedgerEntry(
      companyId: companyId,
      partyId: partyId,
      entryDate: invoiceDate,
      entryType: 'invoice',
      referenceType: 'invoice',
      referenceId: invoiceId,
      referenceNumber: invoiceNumber,
      debitAmount: amount,
      description: 'Invoice #$invoiceNumber',
    );
  }
}
