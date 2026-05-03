import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductListingHeader extends StatelessWidget {
  const ProductListingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006D37);
    const onSurface = Color(0xFF191C1C);
    const surfaceContainerHigh = Color(0xFFE7E8E8);
    const surfaceVariant = Color(0xFFE1E3E3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: primary),
            ),
            Expanded(
              child: Text(
                'List New Product',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
            ),
            Text(
              'Step 2 of 3',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBmAntlVBzqNE4swhblVXnCazOdQiSCB8j2qGCNvpiTgsWkfIOAMJ-LYeCNlYf1XHAx_7wq1x3WgiIYur130wE-fe6sNbeBegdHfuUgkgoxv71C_41IZK02bH2gDkOxRwHPQqL2VZdUk03HAs82-C9VPqSVtd0WKt4F4rdnMDc4vdmcveNKnijc66qh94424h_p5uYWyBv_U2lUzgyaB_mrdddO99hyOoPzjimKWwMZC7XJyZkvBxQSU-UorEV1ssklNUEyKz7zfqU0',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

