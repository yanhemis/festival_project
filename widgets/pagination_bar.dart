import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int startPageNumber;
  final void Function(int) onPageSelected;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.startPageNumber,
    required this.onPageSelected,
    this.onPreviousPressed,
    this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onPreviousPressed,
              icon: const Icon(Icons.arrow_back_ios),
            ),
            for (int i = 0; i < 5; i++)
              if (startPageNumber + i <= totalPages)
                _buildPageNumberBox(startPageNumber + i),
            IconButton(
              onPressed: onNextPressed,
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageNumberBox(int pageNumber) {
    final bool isSelected = pageNumber == currentPage;
    return GestureDetector(
      onTap: () => onPageSelected(pageNumber),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.black,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$pageNumber',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}