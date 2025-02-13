import 'query_builder.dart';

class AdvancedQueryBuilder extends QueryBuilder {
  final List<String> _joins = [];
  final List<String> _groupBy = [];
  final List<String> _having = [];
  final Map<String, String> _aliases = {};
  final List<String> _unions = [];

  AdvancedQueryBuilder innerJoin(String table, String condition, {String? alias}) {
    final tableWithAlias = alias != null ? '$table AS $alias' : table;
    _joins.add('INNER JOIN $tableWithAlias ON $condition');
    if (alias != null) _aliases[alias] = table;
    return this;
  }

  AdvancedQueryBuilder leftJoin(String table, String condition, {String? alias}) {
    final tableWithAlias = alias != null ? '$table AS $alias' : table;
    _joins.add('LEFT JOIN $tableWithAlias ON $condition');
    if (alias != null) _aliases[alias] = table;
    return this;
  }

  AdvancedQueryBuilder groupBy(List<String> columns) {
    _groupBy.addAll(columns);
    return this;
  }

  AdvancedQueryBuilder having(String condition) {
    _having.add(condition);
    return this;
  }

  AdvancedQueryBuilder union(QueryBuilder query) {
    _unions.add('UNION ${query.build()}');
    return this;
  }

  AdvancedQueryBuilder unionAll(QueryBuilder query) {
    _unions.add('UNION ALL ${query.build()}');
    return this;
  }

  String subQuery(QueryBuilder query, String alias) {
    return '(${query.build()}) AS $alias';
  }

  @override
  String build() {
    final parts = [
      'SELECT ${getColumns().join(", ")}',
      'FROM ${getTable()}',
      ..._joins,
      if (getWhere() != null) 'WHERE ${getWhere()}',
      if (_groupBy.isNotEmpty) 'GROUP BY ${_groupBy.join(", ")}',
      if (_having.isNotEmpty) 'HAVING ${_having.join(" AND ")}',
      if (getOrderBy() != null) 'ORDER BY ${getOrderBy()}',
      if (getLimit() != null) 'LIMIT ${getLimit()}',
      ..._unions,
    ];

    return parts.join(' ');
  }
}
