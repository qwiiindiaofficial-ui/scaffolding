import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/auth/register/form.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class RadiusSelectionDialog extends StatefulWidget {
  final int initialRadius;

  const RadiusSelectionDialog({
    Key? key,
    required this.initialRadius,
  }) : super(key: key);

  @override
  State<RadiusSelectionDialog> createState() => _RadiusSelectionDialogState();
}

class _RadiusSelectionDialogState extends State<RadiusSelectionDialog>
    with SingleTickerProviderStateMixin {
  late int _radius;
  late AnimationController _animationController;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _radius = widget.initialRadius;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _radiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Play initial animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addMoreRadius() {
    setState(() {
      _radius += 25;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Service Radius'),
          backgroundColor: ThemeColors.kPrimaryThemeColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(_radius),
              child: const Text(
                'SAVE',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // India map background
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          scale: 2,
                          image: NetworkImage(
                            'https://i.pinimg.com/736x/e4/26/4a/e4264af50836a4d71345ad3c6362a1bc.jpg',
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Current location marker
                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    ),

                    // Animated radius circle
                    AnimatedBuilder(
                      animation: _radiusAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.width, // Make it square
                          ),
                          painter: RadiusCirclePainter(
                            progress: _radiusAnimation.value,
                            radius: _radius,
                          ),
                        );
                      },
                    ),

                    // Radius text
                    Positioned(
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CustomText(
                          text: "Radius: $_radius km",
                          size: 16,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomText(
                    text:
                        "Your service area covers the selected radius from your location",
                    size: 14,
                    color: Colors.grey,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addMoreRadius,
                    icon: const Icon(Icons.add),
                    label: const Text("Add 25 km"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.kPrimaryThemeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
