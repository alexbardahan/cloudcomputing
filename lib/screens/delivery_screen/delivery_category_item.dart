import 'package:flutter/material.dart';

class CategoryItem extends StatefulWidget {
  final String _categoryName;
  final String _categoryIcon;

  final Function _selectItem;
  final int _selectedCategory;

  final int _index;
  final Function _scrollToItem;

  CategoryItem(
    this._categoryName,
    this._categoryIcon,
    this._selectItem,
    this._selectedCategory,
    this._index,
    this._scrollToItem,
  );

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget._scrollToItem(widget._index);
        widget._selectItem(widget._index);
      },
      child: Container(
        width: 70,
        height: 95,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: widget._index == widget._selectedCategory
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 23,
                child: Image(image: AssetImage(widget._categoryIcon)),
                backgroundColor: Colors.white,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                widget._categoryName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1,
                  fontSize: 14,
                  color: widget._index == widget._selectedCategory
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
