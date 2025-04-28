import 'package:flutter/material.dart';

  class SummaryCard extends StatelessWidget {
    final String title;            // Título do cartão
    final int? count;              // Contagem a ser exibida (pode ser nula)
    final IconData? icon;          // Ícone a ser exibido (pode ser nulo)
    final Color color;             // Cor de fundo do cartão
    final VoidCallback? onPressed; // Função a ser chamada ao pressionar o cartão (pode ser nula)

    const SummaryCard({
      super.key,
      required this.title,
      this.count,
      this.icon,
      required this.color,
      this.onPressed,
    });

    @override
    Widget build(BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 350;
          return SizedBox(
            width: isSmallScreen ? constraints.maxWidth : 300,
            height: isSmallScreen ? 80 : 100,
            child: Card(
              color: color,
              child: InkWell(
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (count != null)
                        Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      else if (icon != null)
                        Icon(icon, size: isSmallScreen ? 30 : 38, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }