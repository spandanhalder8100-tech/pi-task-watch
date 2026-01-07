import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String hint;
  final Function(T?) onChanged;
  final bool isRequired;
  final double height;
  final TextEditingController searchController;
  final String Function(T) itemToString;

  const SearchableDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    required this.searchController,
    this.isRequired = false,
    this.height = 32,
    required this.itemToString,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showSearchableDropdown(
          context,
          widget.items,
          widget.value,
          widget.hint,
          widget.searchController,
          widget.onChanged,
          widget.itemToString,
        );
      },
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            Icon(Icons.search, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                widget.value != null
                    ? widget.itemToString(widget.value as T)
                    : widget.hint,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      widget.value != null
                          ? Colors.grey.shade800
                          : Colors.grey.shade600,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade700, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showSearchableDropdown(
    BuildContext context,
    List<T> items,
    T? currentValue,
    String hint,
    TextEditingController searchController,
    Function(T?) onChanged,
    String Function(T) itemToString,
  ) async {
    searchController.text = '';
    List<T> filteredItems = [...items];
    final FocusNode searchFocusNode = FocusNode();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          searchFocusNode.requestFocus();
        });

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Prepare the items list with selected item at top
            List<T> displayItems = [];
            if (currentValue != null) {
              displayItems.add(currentValue);
              filteredItems =
                  filteredItems.where((item) => item != currentValue).toList();
            }
            displayItems.addAll(filteredItems);

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                  maxHeight: 250,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and search row
                      Row(
                        children: [
                          Text(
                            hint,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, size: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Search field with focus node
                      SizedBox(
                        height: 28,
                        child: TextField(
                          controller: searchController,
                          focusNode: searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Type to search',
                            hintStyle: const TextStyle(fontSize: 10),
                            isDense: true,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.search,
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                          style: const TextStyle(fontSize: 11),
                          onChanged: (value) {
                            setStateDialog(() {
                              filteredItems =
                                  items
                                      .where(
                                        (element) => itemToString(element)
                                            .toLowerCase()
                                            .contains(value.toLowerCase()),
                                      )
                                      .toList();
                              displayItems = [];
                              if (currentValue != null) {
                                displayItems.add(currentValue);
                                filteredItems =
                                    filteredItems
                                        .where((item) => item != currentValue)
                                        .toList();
                              }
                              displayItems.addAll(filteredItems);
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Items list
                      Expanded(
                        child:
                            displayItems.isEmpty
                                ? Center(
                                  child: Text(
                                    'No items found',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: displayItems.length,
                                  itemExtent: 28, // fixed height for each item
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    final item = displayItems[index];
                                    final isSelected = currentValue == item;

                                    return InkWell(
                                      onTap: () {
                                        onChanged(item);
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? Colors.grey.shade200
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            if (isSelected)
                                              Icon(
                                                Icons.check,
                                                size: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            if (isSelected)
                                              const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                itemToString(item),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      isSelected
                                                          ? FontWeight.w500
                                                          : FontWeight.normal,
                                                  color: Colors.grey.shade800,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    searchFocusNode.dispose();
  }
}
