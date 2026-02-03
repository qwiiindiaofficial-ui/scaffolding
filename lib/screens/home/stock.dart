// lib/screens/stock_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scaffolding_sale/screens/home/Union/stocksummary.dart';
import 'dart:io';
import 'package:scaffolding_sale/screens/home/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

// lib/models/category_item.dart
class CategoryItem {
  final String id;
  final String name;
  final String image;
  final String hsnCode;

  CategoryItem({
    required this.id,
    required this.name,
    required this.image,
    required this.hsnCode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'hsnCode': hsnCode,
      };

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
        id: json['id'],
        name: json['name'],
        image: json['image'],
        hsnCode: json['hsnCode'] ?? '',
      );

  CategoryItem copyWith({
    String? id,
    String? name,
    String? image,
    String? hsnCode,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      hsnCode: hsnCode ?? this.hsnCode,
    );
  }
}

class CategoryService {
  static const String _key = 'categories';

  // Default categories that should always exist
  static final List<CategoryItem> _defaultCategories = [
    CategoryItem(
      id: 'default_coupler',
      name: 'Coupler',
      image: '', // You can set a default image path here
      hsnCode: '73269099',
    ),
    CategoryItem(
      id: 'default_scaffolding_pipe',
      name: 'Scaffolding Pipe',
      image: '', // You can set a default image path here
      hsnCode: '73063000',
    ),
  ];

  // Default stock items for the default categories
  static final List<StockItem> _defaultStockItems = [
    StockItem(
      id: "default_coupler_item_1",
      image: "",
      title: "Coupler 48mm",
      category: "Coupler",
      size: "48mm",
      quantity: 100,
      rate: 8.0,
      saleRate: 120.0,
      weight: 1.2,
      value: 144.0, // weight * saleRate
      available: 100,
      dispatch: 0,
    ),
    StockItem(
      id: "default_coupler_item_2",
      image: "",
      title: "Coupler 50mm",
      category: "Coupler",
      size: "50mm",
      quantity: 80,
      rate: 10.0,
      saleRate: 130.0,
      weight: 1.3,
      value: 169.0, // weight * saleRate
      available: 80,
      dispatch: 0,
    ),
    StockItem(
      id: "default_scaffolding_pipe_1",
      image: "",
      title: "Scaffolding Pipe 6m",
      category: "Scaffolding Pipe",
      size: "6m",
      quantity: 50,
      rate: 15.0,
      saleRate: 85.0,
      weight: 12.5,
      value: 1062.5, // weight * saleRate
      available: 50,
      dispatch: 0,
    ),
    StockItem(
      id: "default_scaffolding_pipe_2",
      image: "",
      title: "Scaffolding Pipe 4m",
      category: "Scaffolding Pipe",
      size: "4m",
      quantity: 75,
      rate: 12.0,
      saleRate: 85.0,
      weight: 8.5,
      value: 722.5, // weight * saleRate
      available: 75,
      dispatch: 0,
    ),
  ];

  static Future<void> initializeDefaults() async {
    final categories = await getCategories();
    final stockItems = await StockService.getStockItems();

    bool needsUpdate = false;

    // Add default categories if they don't exist
    for (final defaultCategory in _defaultCategories) {
      if (!categories.any((cat) => cat.id == defaultCategory.id)) {
        categories.add(defaultCategory);
        needsUpdate = true;
      }
    }

    if (needsUpdate) {
      await saveCategories(categories);
    }

    // Add default stock items if they don't exist
    bool stockNeedsUpdate = false;
    for (final defaultItem in _defaultStockItems) {
      if (!stockItems.any((item) => item.id == defaultItem.id)) {
        await StockService.addStockItem(defaultItem);
        stockNeedsUpdate = true;
      }
    }
  }

  static Future<void> deleteCategory(String categoryId) async {
    // Prevent deletion of default categories
    if (_defaultCategories.any((cat) => cat.id == categoryId)) {
      throw Exception('Cannot delete default categories');
    }

    final categories = await getCategories();
    categories.removeWhere((cat) => cat.id == categoryId);
    await saveCategories(categories);
  }

  static Future<void> saveCategories(List<CategoryItem> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = categories.map((cat) => cat.toJson()).toList();
    await prefs.setString(_key, jsonEncode(categoriesJson));
  }

  static Future<List<CategoryItem>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString(_key);
    if (categoriesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(categoriesJson);
    return decoded.map((json) => CategoryItem.fromJson(json)).toList();
  }

  static Future<void> addCategory(CategoryItem category) async {
    final categories = await getCategories();
    categories.add(category);
    await saveCategories(categories);
  }

  static Future<void> updateCategoryAndUpdateStockItems(
      CategoryItem oldCategory, CategoryItem newCategory) async {
    // Prevent updating default categories' core properties
    if (_defaultCategories.any((cat) => cat.id == oldCategory.id)) {
      // Allow only image updates for default categories
      if (oldCategory.name != newCategory.name ||
          oldCategory.hsnCode != newCategory.hsnCode) {
        throw Exception('Cannot modify name or HSN code of default categories');
      }
    }

    final categories = await getCategories();
    final index = categories.indexWhere((cat) => cat.id == oldCategory.id);
    if (index != -1) {
      categories[index] = newCategory;
      await saveCategories(categories);
    }

    if (oldCategory.name != newCategory.name ||
        oldCategory.image != newCategory.image) {
      List<StockItem> stockItems = await StockService.getStockItems();
      List<StockItem> updatedStockItems = stockItems.map((item) {
        if (item.category == oldCategory.name) {
          return item.copyWith(
            category: newCategory.name,
            title: '${newCategory.name} ${item.size}',
            image: newCategory.image,
          );
        }
        return item;
      }).toList();
      await StockService.saveStockItems(updatedStockItems);
    }
  }
}

class AddCategoryBottomSheet extends StatefulWidget {
  final Function() onSave;
  final CategoryItem? categoryToEdit;

  const AddCategoryBottomSheet({
    super.key,
    required this.onSave,
    this.categoryToEdit,
  });

  @override
  State<AddCategoryBottomSheet> createState() => _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState extends State<AddCategoryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hsnController = TextEditingController();
  XFile? _image;
  final _picker = ImagePicker();

  bool get isEditing => widget.categoryToEdit != null;
  bool get isDefaultCategory =>
      widget.categoryToEdit != null &&
      CategoryService._defaultCategories
          .any((cat) => cat.id == widget.categoryToEdit!.id);

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final category = widget.categoryToEdit!;
      _nameController.text = category.name;
      _hsnController.text = category.hsnCode;
      if (category.image.isNotEmpty) {
        _image = XFile(category.image);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) return;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      if (croppedFile == null) return;

      setState(() {
        _image = XFile(croppedFile.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking/cropping image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? 'Edit Category' : 'Add New Category',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (isDefaultCategory)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'This is a default category. Only image can be updated.',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            Image.file(File(_image!.path), fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap to select image',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              enabled: !isDefaultCategory, // Disable for default categories
              decoration: InputDecoration(
                labelText: 'Category Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                fillColor: isDefaultCategory ? Colors.grey[100] : null,
                filled: isDefaultCategory,
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter category name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hsnController,
              enabled: !isDefaultCategory, // Disable for default categories
              decoration: InputDecoration(
                labelText: 'HSN Code',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                fillColor: isDefaultCategory ? Colors.grey[100] : null,
                filled: isDefaultCategory,
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter HSN code' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Add Category',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_image == null && !isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      try {
        if (isEditing) {
          final oldCategory = widget.categoryToEdit!;
          final updatedCategory = oldCategory.copyWith(
            name: isDefaultCategory ? oldCategory.name : _nameController.text,
            hsnCode:
                isDefaultCategory ? oldCategory.hsnCode : _hsnController.text,
            image: _image?.path ?? oldCategory.image,
          );
          await CategoryService.updateCategoryAndUpdateStockItems(
              oldCategory, updatedCategory);
          widget.onSave();
          if (mounted) Navigator.pop(context);
        } else {
          final newCategory = CategoryItem(
            id: DateTime.now().toString(),
            name: _nameController.text,
            hsnCode: _hsnController.text,
            image: _image!.path,
          );
          await CategoryService.addCategory(newCategory);

          if (mounted) {
            Navigator.pop(context);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => AddSizesBottomSheet(
                onSave: widget.onSave,
                category: newCategory,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving category: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hsnController.dispose();
    super.dispose();
  }
}

// Rest of the classes remain the same as in your original code...
// [Include all other classes: AddSizesBottomSheet, Stock, _StockState, etc.]

class Stock extends StatefulWidget {
  const Stock({Key? key}) : super(key: key);

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> with SingleTickerProviderStateMixin {
  List<CategoryItem> allCategories = [];
  List<String> categories = [];
  List<StockItem> items = [];
  List<dynamic> filteredItems = [];
  late TabController _tabController;
  bool isLoading = true;
  bool isShowingCategories = true;
  String? selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    initializeAndLoadStock();
  }

  Future<void> initializeAndLoadStock() async {
    setState(() => isLoading = true);
    try {
      // Initialize default categories and items first
      await CategoryService.initializeDefaults();
      // Then load all stock items
      await loadStockItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing stock: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      filterItems(_tabController.index);
    }
  }

  Future<void> loadStockItems() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        CategoryService.getCategories(),
        StockService.getStockItems(),
      ]);

      allCategories = results[0] as List<CategoryItem>;
      items = results[1] as List<StockItem>;
      categories = allCategories.map((cat) => cat.name).toList();
      filterItems(_tabController.index);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void filterItems(int tabIndex) {
    setState(() {
      if (isShowingCategories) {
        switch (tabIndex) {
          case 0: // Available Value
            filteredItems = categories.map((category) {
              int count = items
                  .where(
                      (item) => item.category == category && item.available > 0)
                  .length;
              return {'category': category, 'count': count};
            }).toList();
            break;
          case 1: // Dispatch Value
            filteredItems = categories.map((category) {
              int count = items
                  .where(
                      (item) => item.category == category && item.dispatch > 0)
                  .length;
              return {'category': category, 'count': count};
            }).toList();
            break;
          case 2: // Short Material
            filteredItems = categories.map((category) {
              int count = items
                  .where(
                      (item) => item.category == category && item.quantity < 10)
                  .length;
              return {'category': category, 'count': count};
            }).toList();
            break;
          case 3: // All items
            filteredItems = categories.map((category) {
              int count =
                  items.where((item) => item.category == category).length;
              return {'category': category, 'count': count};
            }).toList();
            break;
        }
      } else {
        switch (tabIndex) {
          case 0: // Available Value
            filteredItems = items
                .where((item) =>
                    item.category == selectedCategory && item.available > 0)
                .toList();
            break;
          case 1: // Dispatch Value
            filteredItems = items
                .where((item) =>
                    item.category == selectedCategory && item.dispatch > 0)
                .toList();
            break;
          case 2: // Short Material
            filteredItems = items
                .where((item) =>
                    item.category == selectedCategory && item.quantity < 10)
                .toList();
            break;
          case 3: // All items
            filteredItems = items
                .where((item) => item.category == selectedCategory)
                .toList();
            break;
        }
      }
    });
  }

  void searchItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filterItems(_tabController.index);
      } else {
        if (isShowingCategories) {
          filteredItems = categories
              .where((category) =>
                  category.toLowerCase().contains(query.toLowerCase()))
              .map((category) {
            int count = items.where((item) => item.category == category).length;
            return {'category': category, 'count': count};
          }).toList();
        } else {
          filteredItems = items
              .where((item) =>
                  item.category == selectedCategory &&
                  (item.title.toLowerCase().contains(query.toLowerCase()) ||
                      item.category
                          .toLowerCase()
                          .contains(query.toLowerCase())))
              .toList();
        }
      }
    });
  }

  Widget buildCategoryTile(String category, int count) {
    final categoryStockItems = items.where((item) => item.category == category);
    final totalPieces =
        categoryStockItems.fold(0, (sum, item) => sum + item.quantity);
    final totalValue = categoryStockItems.fold(0.0,
        (sum, item) => sum + (item.weight * item.saleRate * item.quantity));

    final categoryData = allCategories.firstWhere(
      (cat) => cat.name == category,
      orElse: () =>
          CategoryItem(id: '', name: category, image: '', hsnCode: ''),
    );

    final isDefaultCategory = CategoryService._defaultCategories
        .any((cat) => cat.id == categoryData.id);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            setState(() {
              isShowingCategories = false;
              selectedCategory = category;
              filterItems(_tabController.index);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDefaultCategory
                            ? Colors.teal.withOpacity(0.1)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: categoryData.image.isNotEmpty
                            ? DecorationImage(
                                image: FileImage(File(categoryData.image)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: categoryData.image.isEmpty
                          ? Center(
                              child: Icon(
                                isDefaultCategory ? Icons.star : Icons.category,
                                color: isDefaultCategory
                                    ? Colors.teal
                                    : Colors.grey,
                                size: 30,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isDefaultCategory)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Purchase',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sizes: $count',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.teal),
                      onPressed: () => _showEditCategoryBottomSheet(category),
                    ),
                    if (totalPieces == 0 &&
                        categoryData.id.isNotEmpty &&
                        !isDefaultCategory)
                      IconButton(
                        tooltip: 'Delete Category',
                        icon:
                            Icon(Icons.delete_forever, color: Colors.red[700]),
                        onPressed: () => _confirmDeleteCategory(categoryData),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Total Pieces',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            totalPieces.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.grey[300]),
                      Column(
                        children: [
                          const Text('Total Value',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            '₹${totalValue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(CategoryItem categoryToDelete) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirm Deletion'),
        content: Text(
            'Are you sure you want to delete the "${categoryToDelete.name}" category?\n\nThis action is irreversible and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await CategoryService.deleteCategory(categoryToDelete.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${categoryToDelete.name}" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await loadStockItems();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting category: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showEditCategoryBottomSheet(String categoryName) async {
    final categoryToEdit = allCategories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => CategoryItem(id: '', name: '', image: '', hsnCode: ''),
    );

    if (categoryToEdit.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Could not find category details.')),
      );
      return;
    }

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddCategoryBottomSheet(
        categoryToEdit: categoryToEdit,
        onSave: () {
          loadStockItems();
        },
      ),
    );
  }

  void _resetList() {
    setState(() {
      items.clear();
      loadStockItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddCategoryBottomSheet(
              onSave: _resetList,
            ),
          );
          if (result == true) {
            await loadStockItems();
            setState(() {});
          }
        },
      ),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        foregroundColor: Colors.teal,
        surfaceTintColor: Colors.teal,
        shadowColor: Colors.teal,
        centerTitle: false,
        backgroundColor: Colors.teal,
        title: Text(
          isShowingCategories ? 'Company Stock' : selectedCategory ?? 'Stock',
          style: const TextStyle(color: Colors.white),
        ),
        leading: isShowingCategories
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isShowingCategories = true;
                    selectedCategory = null;
                    filterItems(_tabController.index);
                  });
                },
              ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              controller: _searchController,
              onChanged: searchItems,
              onInfoPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TotalStockSummaryScreen(),
                  ),
                );
              },
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            tabs: const [
              Tab(text: "Available Value"),
              Tab(text: "Dispatch Value"),
              Tab(text: "Short Material"),
              Tab(text: "All item Value"),
            ],
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          if (isShowingCategories) {
                            final category = filteredItems[index]['category'];
                            final count = filteredItems[index]['count'];
                            return buildCategoryTile(category, count);
                          } else {
                            final item = filteredItems[index];
                            return StockItemTile(
                              item: item,
                              onEdit: () => _showEditItemBottomSheet(item),
                              onDelete: () => _deleteItem(item.id),
                              onAdd: () => _showAddQuantityBottomSheet(item),
                              showInfo: _tabController.index == 3,
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditItemBottomSheet(StockItem item) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => EditStockItemBottomSheet(
          item: item,
          scrollController: controller,
        ),
      ),
    );

    if (result == true) {
      loadStockItems();
    }
  }

  Future<void> _showAddQuantityBottomSheet(StockItem item) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => AddQuantityBottomSheet(
          item: item,
          scrollController: controller,
        ),
      ),
    );

    if (result == true) {
      loadStockItems();
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isLoading = true);
      try {
        await StockService.deleteStockItem(id);
        loadStockItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting item: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }
}

// Include the rest of your existing classes here...
// [All other classes like AddSizesBottomSheet, EditStockItemBottomSheet, etc. remain the same]

class AddSizesBottomSheet extends StatefulWidget {
  final CategoryItem category;
  final Function onSave;

  const AddSizesBottomSheet({
    super.key,
    required this.category,
    required this.onSave,
  });

  @override
  State<AddSizesBottomSheet> createState() => _AddSizesBottomSheetState();
}

class _AddSizesBottomSheetState extends State<AddSizesBottomSheet> {
  final List<Map<String, TextEditingController>> _sizeControllers = [];
  final List<double> _calculatedValues = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _addNewSizeField();
  }

  void _addNewSizeField() {
    setState(() {
      _sizeControllers.add({
        'size': TextEditingController(text: widget.category.name),
        'quantity': TextEditingController(),
        'rate': TextEditingController(),
        'saleRate': TextEditingController(),
        'weight': TextEditingController(),
        'noOfLock': TextEditingController(),
      });
      _calculatedValues.add(0.0);

      final index = _sizeControllers.length - 1;
      _sizeControllers[index]['weight']!.addListener(() => _updateValue(index));
      _sizeControllers[index]['saleRate']!
          .addListener(() => _updateValue(index));
      _sizeControllers[index]['quantity']!
          .addListener(() => _calculateRate(index));
    });
  }

  void _updateValue(int index) {
    final weight =
        double.tryParse(_sizeControllers[index]['weight']!.text) ?? 0;
    final saleRate =
        double.tryParse(_sizeControllers[index]['saleRate']!.text) ?? 0;
    setState(() {
      _calculatedValues[index] = weight * saleRate;
    });
    _calculateRate(index);
  }

  void _calculateRate(int index) {
    final quantity =
        double.tryParse(_sizeControllers[index]['quantity']!.text) ?? 0;
    final value = _calculatedValues[index];

    if (quantity > 0 && value > 0) {
      final calculatedRate = value / quantity;
      _sizeControllers[index]['rate']!
          .removeListener(() => _calculateRate(index));
      _sizeControllers[index]['rate']!.text = calculatedRate.toStringAsFixed(2);
      _sizeControllers[index]['rate']!.addListener(() => _calculateRate(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Sizes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Category: ${widget.category.name}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _sizeControllers.length + 1,
                itemBuilder: (context, index) {
                  if (index == _sizeControllers.length) {
                    return TextButton(
                      onPressed: _addNewSizeField,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          Text('Add Another Size'),
                        ],
                      ),
                    );
                  }

                  final controllers = _sizeControllers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controllers['size'],
                                  decoration: const InputDecoration(
                                    labelText: 'Size',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please enter size'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: controllers['quantity'],
                                  decoration: const InputDecoration(
                                    labelText: 'Quantity',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controllers['noOfLock'],
                                  decoration: const InputDecoration(
                                    labelText: 'Locks',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: controllers['rate'],
                                  decoration: const InputDecoration(
                                    labelText: 'Rate per Pc',
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  readOnly: true,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Auto calculated'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: controllers['saleRate'],
                                  decoration: const InputDecoration(
                                    labelText: 'Rate per KG',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controllers['weight'],
                                  decoration: const InputDecoration(
                                    labelText: 'Weight (KG)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Value (Auto)',
                                    labelStyle: TextStyle(color: Colors.blue),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.currency_rupee,
                                          color: Colors.blue, size: 16),
                                      Text(
                                        _calculatedValues[index]
                                            .toStringAsFixed(2),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_sizeControllers.length > 1)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _sizeControllers.removeAt(index);
                                  _calculatedValues.removeAt(index);
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                'Remove',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSizes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save All Sizes',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSizes() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        for (var i = 0; i < _sizeControllers.length; i++) {
          final controllers = _sizeControllers[i];
          final newItem = StockItem(
            id: DateTime.now().toString(),
            image: widget.category.image,
            title: '${widget.category.name} ${controllers['size']!.text}',
            category: widget.category.name,
            size: controllers['size']!.text,
            quantity: int.parse(controllers['quantity']!.text),
            rate: double.parse(controllers['rate']!.text),
            saleRate: double.parse(controllers['saleRate']!.text),
            weight: double.parse(controllers['weight']!.text),
            value: _calculatedValues[i],
            available: int.parse(controllers['quantity']!.text),
            dispatch: 0,
          );

          await StockService.addStockItem(newItem);
        }

        if (mounted) {
          widget.onSave();
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sizes saved successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving sizes: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controllers in _sizeControllers) {
      controllers.values.forEach((controller) => controller.dispose());
    }
    super.dispose();
  }
}

// Custom Search Bar Widget
class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onInfoPressed;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onInfoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search by name',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.teal),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onInfoPressed,
          icon: const Icon(Icons.info, color: Colors.teal),
          tooltip: 'Stock Summary',
        ),
      ],
    );
  }
}

// Stock Item Tile Widget
class StockItemTile extends StatelessWidget {
  final StockItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAdd;
  final bool showInfo;

  const StockItemTile({
    Key? key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    this.showInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double value = item.weight * item.saleRate * item.quantity;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.teal,
        child: ClipOval(
          child: item.image.isNotEmpty
              ? Image.file(
                  File(item.image),
                  fit: BoxFit.cover,
                  width: 44,
                  height: 44,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, color: Colors.white);
                  },
                )
              : const Icon(Icons.category, color: Colors.white),
        ),
      ),
      title: Text(
        item.title.split(' ').length > 2
            ? item.title.split(' ').sublist(1).join(' ')
            : item.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Value: ₹${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Quantity: ${item.quantity}',
            style: const TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: showInfo
          ? IconButton(
              icon: const Icon(Icons.info, color: Colors.teal),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TotalStockSummaryScreen(),
                  ),
                );
              },
            )
          : PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.teal),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'add',
                  onTap: onAdd,
                  child: const Text('Add Item'),
                ),
                PopupMenuItem(
                  value: 'edit',
                  onTap: onEdit,
                  child: const Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  onTap: onDelete,
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
    );
  }
}

// lib/widgets/edit_stock_item_bottom_sheet.dart
class EditStockItemBottomSheet extends StatefulWidget {
  final StockItem item;
  final ScrollController scrollController;

  const EditStockItemBottomSheet({
    Key? key,
    required this.item,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<EditStockItemBottomSheet> createState() =>
      _EditStockItemBottomSheetState();
}

class _EditStockItemBottomSheetState extends State<EditStockItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sizeController;
  late TextEditingController _qtyController;
  late TextEditingController _rateController;
  late TextEditingController _saleRateController;
  late TextEditingController _weightController;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _sizeController = TextEditingController(text: widget.item.size);
    _qtyController =
        TextEditingController(text: widget.item.quantity.toString());
    _rateController = TextEditingController(text: widget.item.rate.toString());
    _saleRateController =
        TextEditingController(text: widget.item.saleRate.toString());
    _weightController =
        TextEditingController(text: widget.item.weight.toString());
    _selectedCategory = widget.item.category;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _image = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          children: [
            Text(
              'Edit Stock Item :  ${widget.item.category}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _image != null
                    ? Image.file(File(_image!.path), fit: BoxFit.cover)
                    : Image.file(File(widget.item.image), fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 16),

            // Size
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sizeController,
                    decoration: InputDecoration(
                      labelText: 'Size',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter size' : null,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quantity and Rate
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: false,
                    controller: TextEditingController(text: "20"),
                    decoration: InputDecoration(
                      labelText: 'Locks',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    onChanged: (s) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: 'Weight (KG)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter weight' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _saleRateController,
                    onChanged: (s) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: 'Sale Rate (Per kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
                    decoration: InputDecoration(
                      labelText: 'Rate (per day)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter sale rate'
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Weight

                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: _rateController.text == "" ||
                                _weightController.text == ""
                            ? "0"
                            : (num.parse(_rateController.text) *
                                    num.parse(_weightController.text))
                                .toString()),
                    decoration: InputDecoration(
                      labelText: 'Value (Per Piece)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),

            // Sale Rate

            const SizedBox(height: 12),

            const SizedBox(height: 32),
            // Save Button
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final updatedItem = widget.item.copyWith(
          image: _image?.path ?? widget.item.image,
          category: _selectedCategory!,
          size: _sizeController.text,
          quantity: int.parse(_qtyController.text),
          rate: double.parse(_rateController.text),
          saleRate: double.parse(_saleRateController.text),
          weight: double.parse(_weightController.text),
        );

        await StockService.updateStockItem(updatedItem);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _qtyController.dispose();
    _rateController.dispose();
    _saleRateController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}

// lib/widgets/add_quantity_bottom_sheet.dart
class AddQuantityBottomSheet extends StatefulWidget {
  final StockItem item;
  final ScrollController scrollController;

  const AddQuantityBottomSheet({
    Key? key,
    required this.item,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<AddQuantityBottomSheet> createState() => _AddQuantityBottomSheetState();
}

class _AddQuantityBottomSheetState extends State<AddQuantityBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          children: [
            const Text(
              'Add Quantity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Item Details
            Text(
              'Item: ${widget.item.title}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Current Quantity: ${widget.item.quantity}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Add Quantity
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Additional Quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter quantity';
                if (int.tryParse(value!) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) <= 0) {
                  return 'Please enter a positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Add Button
            ElevatedButton(
              onPressed: _addQuantity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add Quantity',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addQuantity() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final additionalQuantity = int.parse(_quantityController.text);
        final updatedItem = widget.item.copyWith(
          quantity: widget.item.quantity + additionalQuantity,
          available: widget.item.available + additionalQuantity,
        );

        await StockService.updateStockItem(updatedItem);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding quantity: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}

// lib/widgets/opening_stock_add_item_bottom_sheet.dart
class OpeningStockAddItemBottomSheet extends StatefulWidget {
  final ScrollController scrollController;

  const OpeningStockAddItemBottomSheet({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<OpeningStockAddItemBottomSheet> createState() =>
      _OpeningStockAddItemBottomSheetState();
}

class _OpeningStockAddItemBottomSheetState
    extends State<OpeningStockAddItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  final _saleRateController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedCategory;
  XFile? _image;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() => _image = image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          children: [
            const Text(
              'Opening Stock Add Item',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const Text(
              'Select category and size, item name will be created automatically',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_image!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap to select image',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Base/Jack', child: Text('Base/Jack')),
                DropdownMenuItem(value: 'Challie', child: Text('Challie')),
                DropdownMenuItem(value: 'Channel', child: Text('Channel')),
                DropdownMenuItem(value: 'Clamps', child: Text('Clamps')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _itemNameController.text = value ?? '';
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // Size
            TextFormField(
              controller: _sizeController,
              decoration: InputDecoration(
                labelText: 'Size',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter size' : null,
            ),
            const SizedBox(height: 16),

            // Item Name
            TextFormField(
              controller: _itemNameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Quantity and Rate
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    decoration: InputDecoration(
                      labelText: 'Available Qty',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
                    decoration: InputDecoration(
                      labelText: 'Rate (per day)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sale Rate
            TextFormField(
              controller: _saleRateController,
              decoration: InputDecoration(
                labelText: 'Rate For Sale',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter sale rate' : null,
            ),
            const SizedBox(height: 16),

            // Weight
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Per Piece Weight In KG',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter weight' : null,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      try {
        final newItem = StockItem(
          id: DateTime.now().toString(),
          value: 0.0,
          image: _image!.path,
          title: _itemNameController.text,
          category: _selectedCategory!,
          size: _sizeController.text,
          quantity: int.parse(_qtyController.text),
          rate: double.parse(_rateController.text),
          saleRate: double.parse(_saleRateController.text),
          weight: double.parse(_weightController.text),
          available: int.parse(_qtyController.text),
          dispatch: 0,
        );

        await StockService.addStockItem(newItem);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving item: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _sizeController.dispose();
    _qtyController.dispose();
    _rateController.dispose();
    _saleRateController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
