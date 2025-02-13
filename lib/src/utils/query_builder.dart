mixin QueryBuilderFields {
  String? _table;
  List<String> _columns = ['*'];
  String? _where;
  String? _orderBy;
  int? _limit;
}

class QueryBuilder with QueryBuilderFields {
  QueryBuilder table(String table) {
    _table = table;
    return this;
  }

  QueryBuilder select(List<String> columns) {
    _columns = columns;
    return this;
  }

  QueryBuilder where(String condition) {
    _where = condition;
    return this;
  }

  QueryBuilder orderBy(String field, {bool descending = false}) {
    _orderBy = '$field ${descending ? 'DESC' : 'ASC'}';
    return this;
  }

  QueryBuilder limit(int limit) {
    _limit = limit;
    return this;
  }

  String? getTable() => _table;
  List<String> getColumns() => _columns;
  String? getWhere() => _where;
  String? getOrderBy() => _orderBy;
  int? getLimit() => _limit;

  String build() {
    return 'SELECT ${_columns.join(", ")} FROM $_table${_where != null ? ' WHERE $_where' : ''}${_orderBy != null ? ' ORDER BY $_orderBy' : ''}${_limit != null ? ' LIMIT $_limit' : ''}';
  }
}
