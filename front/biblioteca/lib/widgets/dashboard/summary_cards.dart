import 'package:flutter/material.dart';
import 'summary_card.dart';

class SummaryCards extends StatelessWidget {
  final int loansToday;                // Total de empréstimos do dia
  final int returnsToday;              // Total de devoluções do dia
  final int delaysToday;               // Total de empréstimos em atraso
  final VoidCallback onReportsPressed; // Função chamada ao pressionar o cartão de relatórios

  const SummaryCards({
    super.key,
    required this.loansToday,
    required this.returnsToday,
    required this.delaysToday,
    required this.onReportsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      alignment: WrapAlignment.center,
      children: [
        SummaryCard(
          title: 'Empréstimos do dia',
          count: loansToday,
          color: Colors.green,
        ),
        SummaryCard(
          title: 'Devoluções do dia',
          count: returnsToday,
          color: Colors.orange,
        ),
        SummaryCard(
          title: 'Empréstimos em Atraso',
          count: delaysToday,
          color: Colors.red,
        ),
        SummaryCard(
          title: 'Relatórios',
          icon: Icons.list_alt_sharp,
          color: const Color.fromRGBO(38, 42, 79, 1),
          onPressed: onReportsPressed,
        ),
      ],
    );
  }
}
