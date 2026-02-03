import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart'; // Necesario para formatear la fecha

// --- Clases y variables de marcador de posición ---
// He creado estas clases para que el código sea autoejecutable.
// Deberías usar tus propios widgets y colores definidos en tu proyecto.

// --- Fin de las clases de marcador de posición ---
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Icon? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

class OnedayDiscount extends StatefulWidget {
  const OnedayDiscount({super.key});

  @override
  State<OnedayDiscount> createState() => _OnedayDiscountState();
}

class _OnedayDiscountState extends State<OnedayDiscount> {
  // Controladores y variables de estado para gestionar los datos del formulario
  final _dateController = TextEditingController();
  final _discountController = TextEditingController();

  String? _selectedDiscountType;
  DateTime? _selectedDate;

  // Lista de todos los artículos disponibles y los artículos seleccionados
  final Map<String, bool> _items = {
    'Standar 1.0m': false,
    'Standar 1.5m': false,
  };

  // Función para mostrar el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            DateFormat('dd-MM-yyyy').format(picked); // Formatear fecha
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "One Day Discount",
          color: ThemeColors.kWhiteTextColor,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de selección de fecha
              const CustomText(
                text: "Select Date",
                weight: FontWeight.w500,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _dateController,
                hintText: "DD-MM-YYYY",
                readOnly: true,
                prefixIcon: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 24),

              // Menú desplegable de tipo de descuento
              const CustomText(
                text: "Discount Type",
                weight: FontWeight.w500,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDiscountType,
                decoration: InputDecoration(
                  hintText: 'Select Discount Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'area',
                    child: Text('One Day Discount on Area'),
                  ),
                  DropdownMenuItem(
                    value: 'all_item',
                    child: Text('One Day on All Item'),
                  ),
                  DropdownMenuItem(
                    value: 'no_discount',
                    child: Text('No Discount'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDiscountType = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Selección de artículos con checkboxes
              const CustomText(
                text: "Select Items",
                weight: FontWeight.w500,
              ),
              const SizedBox(height: 10),
              ..._items.keys.map((String key) {
                return CheckboxListTile(
                  title: Text(key),
                  value: _items[key],
                  onChanged: (bool? value) {
                    setState(() {
                      _items[key] = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
              const SizedBox(height: 16),

              // Campo para el porcentaje de descuento
              const CustomText(
                text: "Discount Percentage (%)",
                weight: FontWeight.w500,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _discountController,
                hintText: "Enter discount %",
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.percent),
              ),
              const SizedBox(height: 32),

              // Botón para guardar
              PrimaryButton(
                onTap: () {
                  // Lógica para guardar los datos
                  final selectedItems = _items.entries
                      .where((entry) => entry.value)
                      .map((entry) => entry.key)
                      .toList();

                  // Imprimir en la consola para verificar
                  print("------ Saving Data ------");
                  print("Date: ${_dateController.text}");
                  print("Discount Type: $_selectedDiscountType");
                  print("Selected Items: $selectedItems");
                  print("Discount %: ${_discountController.text}");
                  print("-------------------------");

                  // Muestra un mensaje de éxito y vuelve a la pantalla anterior
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Discount saved successfully!')),
                  );
                  Navigator.pop(context);
                },
                text: "Save All",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
