import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StockCollectionSection extends StatelessWidget {
  final double stockValue;
  final TimeOfDay fromTime;
  final TimeOfDay untilTime;
  final ValueChanged<double> onStockChanged;
  final VoidCallback onPickFrom;
  final VoidCallback onPickUntil;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onListProduct;
  final bool isSubmitting;

  const StockCollectionSection({
    super.key,
    required this.stockValue,
    required this.fromTime,
    required this.untilTime,
    required this.onStockChanged,
    required this.onPickFrom,
    required this.onPickUntil,
    this.onSaveDraft,
    this.onListProduct,
    this.isSubmitting = false,
  });

  static const _onSurface = Color(0xFF191C1C);
  static const _primary = Color(0xFF006D37);
  static const _primaryContainer = Color(0xFF2ECC71);
  static const _surfaceContainerLow = Color(0xFFF3F4F4);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _surfaceContainerHigh = Color(0xFFE7E8E8);
  static const _outlineVariant = Color(0xFFBBCBBB);
  static const _tertiary = Color(0xFF98472A);

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  Widget _timeCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
           border: Border.all(color: _outlineVariant.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
       color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14006D37),
            blurRadius: 22,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.explore_outlined, 'Explore'),
          _navItem(Icons.eco_outlined, 'Impact'),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: _primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          _navItem(Icons.favorite_border, 'Saved'),
          _navItem(Icons.person_outline, 'Account'),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: Colors.grey.shade600),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: _primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '3',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Stock & Collection',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Stock',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${stockValue.round()} units',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _primary,
                  inactiveTrackColor: _surfaceContainerHigh,
                  thumbColor: _primary,
                  overlayColor: _primary.withValues(alpha: 0.12),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: stockValue,
                  min: 1,
                  max: 50,
                  onChanged: onStockChanged,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1',
                      style: GoogleFonts.manrope(
                          color: Colors.grey.shade500)),
                  Text('25',
                      style: GoogleFonts.manrope(
                          color: Colors.grey.shade500)),
                  Text('50+',
                      style: GoogleFonts.manrope(
                          color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Collection Window',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _timeCard(
                    title: 'From',
                    value: _formatTime(fromTime),
                    icon: Icons.schedule,
                    iconColor: _primary,
                    onTap: onPickFrom,
                  ),
                  const SizedBox(width: 12),
                  _timeCard(
                    title: 'Until',
                    value: _formatTime(untilTime),
                    icon: Icons.history,
                    iconColor: _tertiary,
                    onTap: onPickUntil,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Suggested: Most users collect during evening commutes.',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: _surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: TextButton(
                  onPressed: isSubmitting ? null : onSaveDraft,
                  child: Text(
                    'Save Draft',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22006D37),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: isSubmitting ? null : onListProduct,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.rocket_launch, color: Colors.white),
                  label: Text(
                    'List Product',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        _bottomNav(),
      ],
    );
  }
}