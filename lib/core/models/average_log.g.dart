// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'average_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAverageLogCollection on Isar {
  IsarCollection<AverageLog> get averageLogs => this.collection();
}

const AverageLogSchema = CollectionSchema(
  name: r'AverageLog',
  id: -5203787494128958938,
  properties: {
    r'aquariumId': PropertySchema(
      id: 0,
      name: r'aquariumId',
      type: IsarType.string,
    ),
    r'dayIndex': PropertySchema(
      id: 1,
      name: r'dayIndex',
      type: IsarType.long,
    ),
    r'ph': PropertySchema(
      id: 2,
      name: r'ph',
      type: IsarType.double,
    ),
    r'temperature': PropertySchema(
      id: 3,
      name: r'temperature',
      type: IsarType.double,
    ),
    r'turbidity': PropertySchema(
      id: 4,
      name: r'turbidity',
      type: IsarType.double,
    )
  },
  estimateSize: _averageLogEstimateSize,
  serialize: _averageLogSerialize,
  deserialize: _averageLogDeserialize,
  deserializeProp: _averageLogDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _averageLogGetId,
  getLinks: _averageLogGetLinks,
  attach: _averageLogAttach,
  version: '3.1.0+1',
);

int _averageLogEstimateSize(
  AverageLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aquariumId.length * 3;
  return bytesCount;
}

void _averageLogSerialize(
  AverageLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aquariumId);
  writer.writeLong(offsets[1], object.dayIndex);
  writer.writeDouble(offsets[2], object.ph);
  writer.writeDouble(offsets[3], object.temperature);
  writer.writeDouble(offsets[4], object.turbidity);
}

AverageLog _averageLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AverageLog();
  object.aquariumId = reader.readString(offsets[0]);
  object.dayIndex = reader.readLong(offsets[1]);
  object.id = id;
  object.ph = reader.readDouble(offsets[2]);
  object.temperature = reader.readDouble(offsets[3]);
  object.turbidity = reader.readDouble(offsets[4]);
  return object;
}

P _averageLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _averageLogGetId(AverageLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _averageLogGetLinks(AverageLog object) {
  return [];
}

void _averageLogAttach(IsarCollection<dynamic> col, Id id, AverageLog object) {
  object.id = id;
}

extension AverageLogQueryWhereSort
    on QueryBuilder<AverageLog, AverageLog, QWhere> {
  QueryBuilder<AverageLog, AverageLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AverageLogQueryWhere
    on QueryBuilder<AverageLog, AverageLog, QWhereClause> {
  QueryBuilder<AverageLog, AverageLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AverageLogQueryFilter
    on QueryBuilder<AverageLog, AverageLog, QFilterCondition> {
  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> aquariumIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aquariumId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      aquariumIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aquariumId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      aquariumIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aquariumId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> aquariumIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aquariumId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      aquariumIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aquariumId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      aquariumIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aquariumId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      aquariumIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aquariumId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> aquariumIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aquariumId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      aquariumIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aquariumId',
        value: '',
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      aquariumIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aquariumId',
        value: '',
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> dayIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dayIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      dayIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dayIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> dayIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dayIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> dayIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dayIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> phEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ph',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> phGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ph',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> phLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ph',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> phBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ph',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      temperatureEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      temperatureGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      temperatureLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      temperatureBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'temperature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> turbidityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'turbidity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition>
      turbidityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'turbidity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> turbidityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'turbidity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterFilterCondition> turbidityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'turbidity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension AverageLogQueryObject
    on QueryBuilder<AverageLog, AverageLog, QFilterCondition> {}

extension AverageLogQueryLinks
    on QueryBuilder<AverageLog, AverageLog, QFilterCondition> {}

extension AverageLogQuerySortBy
    on QueryBuilder<AverageLog, AverageLog, QSortBy> {
  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> sortByAquariumId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.asc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> sortByAquariumIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.desc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> sortByDayIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayIndex', Sort.asc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> sortByDayIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayIndex', Sort.desc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> sortByPh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.asc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> sortByPhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.desc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> sortByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> sortByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> sortByTurbidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.asc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> sortByTurbidityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.desc);
    });
  }
}

extension AverageLogQuerySortThenBy
    on QueryBuilder<AverageLog, AverageLog, QSortThenBy> {
  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenByAquariumId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.asc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenByAquariumIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.desc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenByDayIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayIndex', Sort.asc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenByDayIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayIndex', Sort.desc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenByPh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.asc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenByPhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.desc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenByTurbidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.asc);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QAfterSortBy> thenByTurbidityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.desc);
    });
  }
}

extension AverageLogQueryWhereDistinct
    on QueryBuilder<AverageLog, AverageLog, QDistinct> {
  QueryBuilder<AverageLog, AverageLog, QDistinct> distinctByAquariumId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aquariumId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AverageLog, AverageLog, QDistinct> distinctByDayIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dayIndex');
    });
  }

  QueryBuilder<AverageLog, AverageLog, QDistinct> distinctByPh() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ph');
    });
  }

  QueryBuilder<AverageLog, AverageLog, QDistinct> distinctByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'temperature');
    });
  }

  QueryBuilder<AverageLog, AverageLog, QDistinct> distinctByTurbidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'turbidity');
    });
  }
}

extension AverageLogQueryProperty
    on QueryBuilder<AverageLog, AverageLog, QQueryProperty> {
  QueryBuilder<AverageLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AverageLog, String, QQueryOperations> aquariumIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aquariumId');
    });
  }

  QueryBuilder<AverageLog, int, QQueryOperations> dayIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dayIndex');
    });
  }

  QueryBuilder<AverageLog, double, QQueryOperations> phProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ph');
    });
  }

  QueryBuilder<AverageLog, double, QQueryOperations> temperatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'temperature');
    });
  }

  QueryBuilder<AverageLog, double, QQueryOperations> turbidityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'turbidity');
    });
  }
}
