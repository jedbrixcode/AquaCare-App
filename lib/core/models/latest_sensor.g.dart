// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latest_sensor.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLatestSensorCollection on Isar {
  IsarCollection<LatestSensor> get latestSensors => this.collection();
}

const LatestSensorSchema = CollectionSchema(
  name: r'LatestSensor',
  id: -904002103378055278,
  properties: {
    r'aquariumId': PropertySchema(
      id: 0,
      name: r'aquariumId',
      type: IsarType.string,
    ),
    r'ph': PropertySchema(
      id: 1,
      name: r'ph',
      type: IsarType.double,
    ),
    r'temperature': PropertySchema(
      id: 2,
      name: r'temperature',
      type: IsarType.double,
    ),
    r'timestampMs': PropertySchema(
      id: 3,
      name: r'timestampMs',
      type: IsarType.long,
    ),
    r'turbidity': PropertySchema(
      id: 4,
      name: r'turbidity',
      type: IsarType.double,
    )
  },
  estimateSize: _latestSensorEstimateSize,
  serialize: _latestSensorSerialize,
  deserialize: _latestSensorDeserialize,
  deserializeProp: _latestSensorDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _latestSensorGetId,
  getLinks: _latestSensorGetLinks,
  attach: _latestSensorAttach,
  version: '3.1.0+1',
);

int _latestSensorEstimateSize(
  LatestSensor object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aquariumId.length * 3;
  return bytesCount;
}

void _latestSensorSerialize(
  LatestSensor object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aquariumId);
  writer.writeDouble(offsets[1], object.ph);
  writer.writeDouble(offsets[2], object.temperature);
  writer.writeLong(offsets[3], object.timestampMs);
  writer.writeDouble(offsets[4], object.turbidity);
}

LatestSensor _latestSensorDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LatestSensor();
  object.aquariumId = reader.readString(offsets[0]);
  object.id = id;
  object.ph = reader.readDouble(offsets[1]);
  object.temperature = reader.readDouble(offsets[2]);
  object.timestampMs = reader.readLong(offsets[3]);
  object.turbidity = reader.readDouble(offsets[4]);
  return object;
}

P _latestSensorDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _latestSensorGetId(LatestSensor object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _latestSensorGetLinks(LatestSensor object) {
  return [];
}

void _latestSensorAttach(
    IsarCollection<dynamic> col, Id id, LatestSensor object) {
  object.id = id;
}

extension LatestSensorQueryWhereSort
    on QueryBuilder<LatestSensor, LatestSensor, QWhere> {
  QueryBuilder<LatestSensor, LatestSensor, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LatestSensorQueryWhere
    on QueryBuilder<LatestSensor, LatestSensor, QWhereClause> {
  QueryBuilder<LatestSensor, LatestSensor, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterWhereClause> idBetween(
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

extension LatestSensorQueryFilter
    on QueryBuilder<LatestSensor, LatestSensor, QFilterCondition> {
  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      aquariumIdEqualTo(
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      aquariumIdBetween(
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      aquariumIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aquariumId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      aquariumIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aquariumId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      aquariumIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aquariumId',
        value: '',
      ));
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      aquariumIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aquariumId',
        value: '',
      ));
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition> phEqualTo(
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition> phGreaterThan(
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition> phLessThan(
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition> phBetween(
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      timestampMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestampMs',
        value: value,
      ));
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      timestampMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestampMs',
        value: value,
      ));
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      timestampMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestampMs',
        value: value,
      ));
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      timestampMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestampMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      turbidityEqualTo(
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      turbidityLessThan(
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

  QueryBuilder<LatestSensor, LatestSensor, QAfterFilterCondition>
      turbidityBetween(
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

extension LatestSensorQueryObject
    on QueryBuilder<LatestSensor, LatestSensor, QFilterCondition> {}

extension LatestSensorQueryLinks
    on QueryBuilder<LatestSensor, LatestSensor, QFilterCondition> {}

extension LatestSensorQuerySortBy
    on QueryBuilder<LatestSensor, LatestSensor, QSortBy> {
  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> sortByAquariumId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.asc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy>
      sortByAquariumIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.desc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> sortByPh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.asc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> sortByPhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.desc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> sortByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy>
      sortByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> sortByTimestampMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampMs', Sort.asc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy>
      sortByTimestampMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampMs', Sort.desc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> sortByTurbidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.asc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> sortByTurbidityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.desc);
    });
  }
}

extension LatestSensorQuerySortThenBy
    on QueryBuilder<LatestSensor, LatestSensor, QSortThenBy> {
  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> thenByAquariumId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.asc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy>
      thenByAquariumIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.desc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> thenByPh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.asc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> thenByPhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ph', Sort.desc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> thenByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy>
      thenByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> thenByTimestampMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampMs', Sort.asc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy>
      thenByTimestampMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampMs', Sort.desc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> thenByTurbidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.asc);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QAfterSortBy> thenByTurbidityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turbidity', Sort.desc);
    });
  }
}

extension LatestSensorQueryWhereDistinct
    on QueryBuilder<LatestSensor, LatestSensor, QDistinct> {
  QueryBuilder<LatestSensor, LatestSensor, QDistinct> distinctByAquariumId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aquariumId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QDistinct> distinctByPh() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ph');
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QDistinct> distinctByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'temperature');
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QDistinct> distinctByTimestampMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestampMs');
    });
  }

  QueryBuilder<LatestSensor, LatestSensor, QDistinct> distinctByTurbidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'turbidity');
    });
  }
}

extension LatestSensorQueryProperty
    on QueryBuilder<LatestSensor, LatestSensor, QQueryProperty> {
  QueryBuilder<LatestSensor, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LatestSensor, String, QQueryOperations> aquariumIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aquariumId');
    });
  }

  QueryBuilder<LatestSensor, double, QQueryOperations> phProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ph');
    });
  }

  QueryBuilder<LatestSensor, double, QQueryOperations> temperatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'temperature');
    });
  }

  QueryBuilder<LatestSensor, int, QQueryOperations> timestampMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestampMs');
    });
  }

  QueryBuilder<LatestSensor, double, QQueryOperations> turbidityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'turbidity');
    });
  }
}
