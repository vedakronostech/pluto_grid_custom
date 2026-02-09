import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'popup_cell.dart';

class PlutoSelectCell extends StatefulWidget implements PopupCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoSelectCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  PlutoSelectCellState createState() => PlutoSelectCellState();
}

class PlutoSelectCellState extends State<PlutoSelectCell> with PopupCellState<PlutoSelectCell> {
  @override
  List<PlutoColumn> popupColumns = [];

  @override
  List<PlutoRow> popupRows = [];

  @override
  IconData? get icon => widget.column.type.select.popupIcon;

  @override
  PlutoGridMode get popupMode => _shouldAutoOpenPopup ? PlutoGridMode.selectWithOneTap : PlutoGridMode.select;

  late bool enableColumnFilter;

  @override
  void initState() {
    super.initState();

    if (_shouldAutoOpenPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || isOpenedPopup) {
          return;
        }

        openPopup();
      });
    }

    enableColumnFilter = widget.column.type.select.enableColumnFilter;

    final columnFilterHeight = enableColumnFilter ? widget.stateManager.configuration.style.columnFilterHeight : 0;

    final rowsHeight = widget.column.type.select.items.length * widget.stateManager.rowTotalHeight;

    popupHeight = widget.stateManager.configuration.style.columnHeight + columnFilterHeight + rowsHeight + PlutoGridSettings.gridInnerSpacing + PlutoGridSettings.gridBorderWidth;

    fieldOnSelected = widget.column.title;

    popupColumns = [
      PlutoColumn(
        title: widget.column.title,
        field: widget.column.title,
        readOnly: true,
        type: PlutoColumnType.text(),
        formatter: widget.column.formatter,
        enableFilterMenuItem: enableColumnFilter,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
      )
    ];

    popupRows = widget.column.type.select.items.map((dynamic item) {
      return PlutoRow(
        cells: {
          widget.column.title: PlutoCell(value: item),
        },
      );
    }).toList();
  }

  bool get _shouldAutoOpenPopup {
    return widget.stateManager.mode.isPopup && (widget.column.field == FilterHelper.filterFieldType || widget.column.field == FilterHelper.filterFieldColumn);
  }

  @override
  void onLoaded(PlutoGridOnLoadedEvent event) {
    super.onLoaded(event);

    if (enableColumnFilter) {
      event.stateManager.setShowColumnFilter(true, notify: false);
    }

    event.stateManager.setSelectingMode(PlutoGridSelectingMode.none);
  }
}
