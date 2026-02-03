import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String labelText;
  final IconData? prefixIcon;
  final T? selectedItem;
  final List<T> items;
  final String Function(T) itemAsString;
  final void Function(T?) onChanged;
  final Future<void> Function() onAddNew;
  final String? Function(String?)? validator;

  const SearchableDropdown({
    super.key,
    required this.labelText,
    this.prefixIcon,
    this.selectedItem,
    required this.items,
    required this.itemAsString,
    required this.onChanged,
    required this.onAddNew,
    this.validator,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      }
    });
    // Set initial text if an item is already selected
    if (widget.selectedItem != null) {
      _controller.text = widget.itemAsString(widget.selectedItem as T);
    }
  }

  // Update controller text if the selectedItem changes from outside
  @override
  void didUpdateWidget(covariant SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      _controller.text = widget.selectedItem != null
          ? widget.itemAsString(widget.selectedItem as T)
          : '';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: _buildOverlayContent(),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  Widget _buildOverlayContent() {
    return Material(
      elevation: 8.0,
      borderRadius: BorderRadius.circular(8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 250, // Set a max height for the dropdown
        ),
        child: _SearchSelectionPage<T>(
          items: widget.items,
          itemAsString: widget.itemAsString,
          onAddNew: () async {
            _removeOverlay();
            await widget.onAddNew();
          },
          onItemSelected: (item) {
            widget.onChanged(item);
            _controller.text = widget.itemAsString(item);
            _removeOverlay();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        readOnly: true,
        decoration: InputDecoration(
          labelText: widget.labelText,
          prefixIcon: Icon(widget.prefixIcon),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        onTap: _showOverlay,
        validator: widget.validator,
      ),
    );
  }
}

// A new version of the search page, designed to live inside the overlay
class _SearchSelectionPage<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemAsString;
  final Future<void> Function() onAddNew;
  final void Function(T) onItemSelected;

  const _SearchSelectionPage({
    required this.items,
    required this.itemAsString,
    required this.onAddNew,
    required this.onItemSelected,
  });

  @override
  State<_SearchSelectionPage<T>> createState() =>
      _SearchSelectionPageState<T>();
}

class _SearchSelectionPageState<T> extends State<_SearchSelectionPage<T>> {
  List<T> _filteredItems = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        return widget.itemAsString(item).toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search TextField
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        // List of items
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _filteredItems.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading:
                      const Icon(Icons.add_circle_outline, color: Colors.blue),
                  title: const Text("Add New...",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                  onTap: widget.onAddNew,
                );
              }
              final item = _filteredItems[index - 1];
              return ListTile(
                title: Text(widget.itemAsString(item)),
                onTap: () => widget.onItemSelected(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
