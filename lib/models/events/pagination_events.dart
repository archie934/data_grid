import 'dart:math' as math;
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';

class SetPageEvent extends DataGridEvent {
  final int page;

  SetPageEvent({required this.page});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final currentContextState = context.state;

    if (!currentContextState.pagination.enabled) return null;

    final paginationState = currentContextState.pagination;

    final totalPages = paginationState.totalPages(
      currentContextState.totalItems,
    );
    final validPage = math.max(1, math.min(page, totalPages));

    if (validPage == paginationState.currentPage) return null;

    final newPagination = paginationState.copyWith(currentPage: validPage);

    final List<double> newDisplayOrder;
    if (paginationState.serverSide) {
      newDisplayOrder = currentContextState.displayOrder;
    } else {
      final startIndex = newPagination.startIndex(
        currentContextState.totalItems,
      );
      final endIndex = newPagination.endIndex(currentContextState.totalItems);
      final allIds = currentContextState.rowsById.keys.toList();
      newDisplayOrder = allIds.sublist(
        math.min(startIndex, allIds.length),
        math.min(endIndex, allIds.length),
      );
    }

    return currentContextState.copyWith(
      pagination: newPagination,
      displayOrder: newDisplayOrder,
    );
  }
}

class SetPageSizeEvent extends DataGridEvent {
  final int pageSize;

  SetPageSizeEvent({required this.pageSize});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final currentContextState = context.state;
    final paginationState = currentContextState.pagination;

    if (!paginationState.enabled) return null;
    if (pageSize <= 0) return null;

    final newPagination = paginationState.copyWith(pageSize: pageSize);
    final totalPages = newPagination.totalPages(currentContextState.totalItems);
    final currentPage = math.min(paginationState.currentPage, totalPages);
    final adjustedPagination = newPagination.copyWith(currentPage: currentPage);

    final List<double> newDisplayOrder;
    if (paginationState.serverSide) {
      newDisplayOrder = currentContextState.displayOrder;
    } else {
      final startIndex = adjustedPagination.startIndex(
        currentContextState.totalItems,
      );
      final endIndex = adjustedPagination.endIndex(
        currentContextState.totalItems,
      );
      final allIds = currentContextState.rowsById.keys.toList();
      newDisplayOrder = allIds.sublist(
        math.min(startIndex, allIds.length),
        math.min(endIndex, allIds.length),
      );
    }

    return currentContextState.copyWith(
      pagination: adjustedPagination,
      displayOrder: newDisplayOrder,
    );
  }
}

class NextPageEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final currentContextState = context.state;
    final paginationState = currentContextState.pagination;

    if (!paginationState.enabled) return null;
    if (!currentContextState.hasNextPage) return null;

    final newPage = paginationState.currentPage + 1;
    final newPagination = paginationState.copyWith(currentPage: newPage);

    final List<double> newDisplayOrder;
    if (paginationState.serverSide) {
      newDisplayOrder = currentContextState.displayOrder;
    } else {
      final startIndex = newPagination.startIndex(
        currentContextState.totalItems,
      );
      final endIndex = newPagination.endIndex(currentContextState.totalItems);
      final allIds = currentContextState.rowsById.keys.toList();
      newDisplayOrder = allIds.sublist(
        math.min(startIndex, allIds.length),
        math.min(endIndex, allIds.length),
      );
    }

    return currentContextState.copyWith(
      pagination: newPagination,
      displayOrder: newDisplayOrder,
    );
  }
}

class PreviousPageEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final currentContextState = context.state;
    final paginationState = currentContextState.pagination;

    if (!paginationState.enabled) return null;
    if (!currentContextState.hasPreviousPage) return null;

    final newPage = paginationState.currentPage - 1;
    final newPagination = paginationState.copyWith(currentPage: newPage);

    final List<double> newDisplayOrder;
    if (paginationState.serverSide) {
      newDisplayOrder = currentContextState.displayOrder;
    } else {
      final startIndex = newPagination.startIndex(
        currentContextState.totalItems,
      );
      final endIndex = newPagination.endIndex(currentContextState.totalItems);
      final allIds = currentContextState.rowsById.keys.toList();
      newDisplayOrder = allIds.sublist(
        math.min(startIndex, allIds.length),
        math.min(endIndex, allIds.length),
      );
    }

    return currentContextState.copyWith(
      pagination: newPagination,
      displayOrder: newDisplayOrder,
    );
  }
}

class FirstPageEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final currentContextState = context.state;
    final paginationState = currentContextState.pagination;

    if (!paginationState.enabled) return null;
    if (paginationState.currentPage == 1) return null;

    final newPagination = paginationState.copyWith(currentPage: 1);

    final List<double> newDisplayOrder;
    if (paginationState.serverSide) {
      newDisplayOrder = currentContextState.displayOrder;
    } else {
      final startIndex = newPagination.startIndex(
        currentContextState.totalItems,
      );
      final endIndex = newPagination.endIndex(currentContextState.totalItems);
      final allIds = currentContextState.rowsById.keys.toList();
      newDisplayOrder = allIds.sublist(
        math.min(startIndex, allIds.length),
        math.min(endIndex, allIds.length),
      );
    }

    return currentContextState.copyWith(
      pagination: newPagination,
      displayOrder: newDisplayOrder,
    );
  }
}

class LastPageEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final currentContextState = context.state;
    final paginationState = currentContextState.pagination;

    if (!paginationState.enabled) return null;

    final totalPages = paginationState.totalPages(
      currentContextState.totalItems,
    );
    if (paginationState.currentPage == totalPages) return null;

    final newPagination = paginationState.copyWith(currentPage: totalPages);

    final List<double> newDisplayOrder;
    if (paginationState.serverSide) {
      newDisplayOrder = currentContextState.displayOrder;
    } else {
      final startIndex = newPagination.startIndex(
        currentContextState.totalItems,
      );
      final endIndex = newPagination.endIndex(currentContextState.totalItems);
      final allIds = currentContextState.rowsById.keys.toList();
      newDisplayOrder = allIds.sublist(
        math.min(startIndex, allIds.length),
        math.min(endIndex, allIds.length),
      );
    }

    return currentContextState.copyWith(
      pagination: newPagination,
      displayOrder: newDisplayOrder,
    );
  }
}

class EnablePaginationEvent extends DataGridEvent {
  final bool enabled;

  EnablePaginationEvent({required this.enabled});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final currentContextState = context.state;
    final paginationState = currentContextState.pagination;

    if (paginationState.enabled == enabled) return null;

    final newPagination = paginationState.copyWith(enabled: enabled);
    final List<double> newDisplayOrder;
    int totalItems = currentContextState.totalItems;

    if (enabled) {
      if (paginationState.serverSide) {
        newDisplayOrder = currentContextState.displayOrder;
      } else {
        final allIds = currentContextState.displayOrder;
        totalItems = allIds.length;
        final startIndex = newPagination.startIndex(totalItems);
        final endIndex = newPagination.endIndex(totalItems);
        newDisplayOrder = allIds.sublist(
          math.min(startIndex, allIds.length),
          math.min(endIndex, allIds.length),
        );
      }
    } else {
      final allIds = currentContextState.rowsById.keys.toList();
      totalItems = allIds.length;
      newDisplayOrder = allIds;
    }

    return currentContextState.copyWith(
      pagination: newPagination,
      displayOrder: newDisplayOrder,
      totalItems: totalItems,
    );
  }
}

class SetServerSidePaginationEvent extends DataGridEvent {
  final bool serverSide;

  SetServerSidePaginationEvent({required this.serverSide});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final currentContextState = context.state;
    final paginationState = currentContextState.pagination;

    if (paginationState.serverSide == serverSide) return null;

    return currentContextState.copyWith(
      pagination: paginationState.copyWith(serverSide: serverSide),
    );
  }
}
