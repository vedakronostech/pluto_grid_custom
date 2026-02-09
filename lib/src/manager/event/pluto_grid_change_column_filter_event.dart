import 'package:collection/collection.dart' show IterableExtension;
import 'package:pluto_grid/pluto_grid.dart';

/// Event called when the value of the TextField
/// that handles the filter under the column changes.
class PlutoGridChangeColumnFilterEvent extends PlutoGridEvent {
  final PlutoColumn column;
  final PlutoFilterType filterType;
  final String filterValue;
  final int? debounceMilliseconds;

  PlutoGridChangeColumnFilterEvent({
    required this.column,
    required this.filterType,
    required this.filterValue,
    this.debounceMilliseconds,
  }) : super(
          type: PlutoGridEventType.debounce,
          duration: Duration(
            milliseconds: debounceMilliseconds == null
                ? PlutoGridSettings.debounceMillisecondsForColumnFilter
                : debounceMilliseconds < 0
                    ? 0
                    : debounceMilliseconds,
          ),
        );

  List<PlutoRow> _getFilterRows(PlutoGridStateManager? stateManager) {
    List<PlutoRow> foundFilterRows = stateManager!.filterRowsByField(column.field);

    // If filter value is empty, remove all filters for this column
    if (filterValue.isEmpty) {
      return stateManager.filterRows.where((row) => row.cells[FilterHelper.filterFieldColumn]!.value != column.field).toList();
    }

    if (foundFilterRows.isEmpty) {
      // No existing filter for this column, add a new one
      return [
        ...stateManager.filterRows,
        FilterHelper.createFilterRow(
          columnField: column.field,
          filterType: filterType,
          filterValue: filterValue,
        ),
      ];
    }

    // Update the first matching filter with the same type, or add a new filter
    final existingFilterWithSameType = foundFilterRows.firstWhereOrNull(
      (row) => row.cells[FilterHelper.filterFieldType]!.value == filterType,
    );

    if (existingFilterWithSameType != null) {
      // Update existing filter value
      existingFilterWithSameType.cells[FilterHelper.filterFieldValue]!.value = filterValue;
    } else {
      // Add new filter with different type for the same column
      stateManager.filterRows.add(
        FilterHelper.createFilterRow(
          columnField: column.field,
          filterType: filterType,
          filterValue: filterValue,
        ),
      );
    }

    return stateManager.filterRows;
  }

  @override
  void handler(PlutoGridStateManager stateManager) {
    stateManager.setFilterWithFilterRows(_getFilterRows(stateManager));
  }
}
