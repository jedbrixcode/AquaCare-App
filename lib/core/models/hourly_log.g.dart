// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hourly_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHourlyLogCollection on Isar {
  IsarCollection<HourlyLog> get hourlyLogs => this.collection();
}

const HourlyLogSchema = CollectionSchema(
  name: r'HourlyLog',
  id: -5768363723978166212,
  properties: {
    r'aquariumId': PropertySchema(
      id: 0,
      name: r'aquariumId',
      type: IsarType.string,
    ),
    r'hourIndex': PropertySchema(
      id: 1,
      name: r'hourIndex',
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
  estimateSize: _hourlyLogEstimateSize,
  serialize: _hourlyLogSerialize,
  deserialize: _hourlyLogDeserialize,
  deserializeProp: _hourlyLogDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _hourlyLogGetId,
  getLinks: _hourlyLogGetLinks,
  attach: _hourlyLogAttach,
  version: '3.1.0+1',
);

int _hourlyLogEstimateSize(
  HourlyLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aquariumId.length * 3;
  return bytesCount;
}

void _hourlyLogSerialize(
  HourlyLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aquariumId);
  writer.writeLong(offsets[1], object.hourIndex);
  writer.writeDouble(offsets[2], object.ph);
  writer.writeDouble(offsets[3], object.temperature);
  writer.writeDouble(offsets[4], object.turbidity);
}

HourlyLog _hourlyLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HourlyLog();
  object.aquariumId = reader.readString(offsets[0]);
  object.hourIndex = reader.readLong(offsets[1]);
  object.id = id;
  object.ph = reader.readDouble(offsets[2]);
  object.temperature = reader.readDouble(offsets[3]);
  object.turbidity = reader.readDouble(offsets[4]);
  return object;
}

P _hourlyLogDeserializeProp<P>(
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

Id _hourlyLogGetId(HourlyLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _hourlyLogGetLinks(HourlyLog object) {
  return [];
}

void _hourlyLogAttach(IsarCollection<dynamic> col, Id id, HourlyLog object) {
  object.id = id;
}

extension HourlyLogQueryWhereSort
    on QueryBuilder<HourlyLog, HourlyLog, QWhere> {
  QueryBuilder<HourlyLog, HourlyLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HourlyLogQueryWhere
    on QueryBuilder<HourlyLog, HourlyLog, QWhereClause> {
  QueryBuilder<HourlyLog, HourlyLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterWhereClause> idBetween(
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

extension HourlyLogQueryFilter
    on QueryBuilder<HourlyLog, HourlyLog, QFilterCondition> {
  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> aquariumIdEqualTo(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition>
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> aquariumIdLessThan(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> aquariumIdBetween(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition>
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> aquariumIdEndsWith(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> aquariumIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aquariumId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> aquariumIdMatches(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition>
      aquariumIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aquariumId',
        value: '',
      ));
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition>
      aquariumIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aquariumId',
        value: '',
      ));
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> hourIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hourIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition>
      hourIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hourIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> hourIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hourIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> hourIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hourIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> phEqualTo(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> phGreaterThan(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> phLessThan(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> phBetween(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> temperatureEqualTo(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition>
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> temperatureLessThan(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> temperatureBetween(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> turbidityEqualTo(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition>
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> turbidityLessThan(
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

  QueryBuilder<HourlyLog, HourlyLog, QAfterFilterCondition> turbidityBetween(
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

extension HourlyLogQueryObject
    on QueryBuilder<HourlyLog, HourlyLog, QFilterCondition> {}

extension HourlyLogQueryLinks
    on QueryBuilder<HourlyLog, HourlyLog, QFilterCondition> {}

extension HourlyLogQuerySortBy on QueryBuilder<HourlyLog, HourlyLog, QSortBy> {
  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> sortByAquariumId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.asc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> sortByAquariumIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.desc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> sortByHourIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourIndex', Sort.asc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> sortByHourIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourIndex', Sort.desc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> sortByPh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.asc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> sortByPhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.desc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> sortByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> sortByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> sortByTurbidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.asc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> sortByTurbidityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.desc);
    });
  }
}

extension HourlyLogQuerySortThenBy
    on QueryBuilder<HourlyLog, HourlyLog, QSortThenBy> {
  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenByAquariumId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.asc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenByAquariumIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.desc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenByHourIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourIndex', Sort.asc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenByHourIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourIndex', Sort.desc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenByPh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.asc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenByPhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.desc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenByTurbidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.asc);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QAfterSortBy> thenByTurbidityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.desc);
    });
  }
}

extension HourlyLogQueryWhereDistinct
    on QueryBuilder<HourlyLog, HourlyLog, QDistinct> {
  QueryBuilder<HourlyLog, HourlyLog, QDistinct> distinctByAquariumId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aquariumId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QDistinct> distinctByHourIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hourIndex');
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QDistinct> distinctByPh() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ph');
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QDistinct> distinctByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'temperature');
    });
  }

  QueryBuilder<HourlyLog, HourlyLog, QDistinct> distinctByTurbidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'turbidity');
    });
  }
}

extension HourlyLogQueryProperty
    on QueryBuilder<HourlyLog, HourlyLog, QQueryProperty> {
  QueryBuilder<HourlyLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HourlyLog, String, QQueryOperations> aquariumIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aquariumId');
    });
  }

  QueryBuilder<HourlyLog, int, QQueryOperations> hourIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hourIndex');
    });
  }

  QueryBuilder<HourlyLog, double, QQueryOperations> phProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ph');
    });
  }

  QueryBuilder<HourlyLog, double, QQueryOperations> temperatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'temperature');
    });
  }

  QueryBuilder<HourlyLog, double, QQueryOperations> turbidityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'turbidity');
    });
  }
}
