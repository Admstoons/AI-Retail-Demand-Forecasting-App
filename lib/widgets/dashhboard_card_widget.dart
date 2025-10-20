import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/dashboard_screens/dashboard_card_model.dart';

class DashboardCardWidget extends StatelessWidget {
  final DashboardCardModel card;

  const DashboardCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(card.icon, size: 40, color: card.color),
          const SizedBox(height: 10),
          Text(
            card.title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (card.subtitle != null) ...[
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                card.subtitle!,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child:
          card.onTap != null
              ? InkWell(onTap: card.onTap, child: content)
              : content,
    );
  }
}
