// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'one_time_schedule_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOneTimeScheduleCacheCollection on Isar {
  IsarCollection<OneTimeScheduleCache> get oneTimeScheduleCaches =>
      this.collection();
}

const OneTimeScheduleCacheSchema = CollectionSchema(
  name: r'OneTimeScheduleCache',
  id: -3520475187986926669,
  properties: {
    r'aquariumId': PropertySchema(
      id: 0,
      name: r'aquariumId',
      type: IsarType.string,
    ),
    r'cycle': PropertySchema(
      id: 1,
      name: r'cycle',
      type: IsarType.long,
    ),
    r'documentId': PropertySchema(
      id: 2,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'food': PropertySchema(
      id: 3,
      name: r'food',
      type: IsarType.string,
    ),
    r'scheduleTime': PropertySchema(
      id: 4,
      name: r'scheduleTime',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.string,
    )
  },
  estimateSize: _oneTimeScheduleCacheEstimateSize,
  serialize: _oneTimeScheduleCacheSerialize,
  deserialize: _oneTimeScheduleCacheDeserialize,
  deserializeProp: _oneTimeScheduleCacheDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _oneTimeScheduleCacheGetId,
  getLinks: _oneTimeScheduleCacheGetLinks,
  attach: _oneTimeScheduleCacheAttach,
  version: '3.1.0+1',
);

int _oneTimeScheduleCacheEstimateSize(
  OneTimeScheduleCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aquariumId.length * 3;
  bytesCount += 3 + object.documentId.length * 3;
  bytesCount += 3 + object.food.length * 3;
  bytesCount += 3 + object.scheduleTime.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _oneTimeScheduleCacheSerialize(
  OneTimeScheduleCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aquariumId);
  writer.writeLong(offsets[1], object.cycle);
  writer.writeString(offsets[2], object.documentId);
  writer.writeString(offsets[3], object.food);
  writer.writeString(offsets[4], object.scheduleTime);
  writer.writeString(offsets[5], object.status);
}

OneTimeScheduleCache _oneTimeScheduleCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OneTimeScheduleCache();
  object.aquariumId = reader.readString(offsets[0]);
  object.cycle = reader.readLong(offsets[1]);
  object.documentId = reader.readString(offsets[2]);
  object.food = reader.readString(offsets[3]);
  object.id = id;
  object.scheduleTime = reader.readString(offsets[4]);
  object.status = reader.readString(offsets[5]);
  return object;
}

P _oneTimeScheduleCacheDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _oneTimeScheduleCacheGetId(OneTimeScheduleCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _oneTimeScheduleCacheGetLinks(
    OneTimeScheduleCache object) {
  return [];
}

void _oneTimeScheduleCacheAttach(
    IsarCollection<dynamic> col, Id id, OneTimeScheduleCache object) {
  object.id = id;
}

extension OneTimeScheduleCacheQueryWhereSort
    on QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QWhere> {
  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OneTimeScheduleCacheQueryWhere
    on QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QWhereClause> {
  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterWhereClause>
      idBetween(
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

extension OneTimeScheduleCacheQueryFilter on QueryBuilder<OneTimeScheduleCache,
    OneTimeScheduleCache, QFilterCondition> {
  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> aquariumIdEqualTo(
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

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> aquariumIdGreaterThan(
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

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> aquariumIdLessThan(
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

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> aquariumIdBetween(
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

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> aquariumIdStartsWith(
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

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> aquariumIdEndsWith(
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

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
          QAfterFilterCondition>
      aquariumIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aquariumId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
          QAfterFilterCondition>
      aquariumIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aquariumId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> aquariumIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aquariumId',
        value: '',
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> aquariumIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aquariumId',
        value: '',
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> cycleEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cycle',
        value: value,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> cycleGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cycle',
        value: value,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> cycleLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cycle',
        value: value,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> cycleBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cycle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> documentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
          QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
          QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> foodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'food',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> foodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'food',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> foodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'food',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> foodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'food',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> foodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'food',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> foodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'food',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
          QAfterFilterCondition>
      foodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'food',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
          QAfterFilterCondition>
      foodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'food',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> foodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'food',
        value: '',
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> foodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'food',
        value: '',
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> scheduleTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduleTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> scheduleTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduleTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> scheduleTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduleTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> scheduleTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduleTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> scheduleTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scheduleTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> scheduleTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scheduleTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
          QAfterFilterCondition>
      scheduleTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scheduleTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
          QAfterFilterCondition>
      scheduleTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scheduleTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> scheduleTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduleTime',
        value: '',
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> scheduleTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scheduleTime',
        value: '',
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
          QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
          QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }
}

extension OneTimeScheduleCacheQueryObject on QueryBuilder<OneTimeScheduleCache,
    OneTimeScheduleCache, QFilterCondition> {}

extension OneTimeScheduleCacheQueryLinks on QueryBuilder<OneTimeScheduleCache,
    OneTimeScheduleCache, QFilterCondition> {}

extension OneTimeScheduleCacheQuerySortBy
    on QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QSortBy> {
  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByAquariumId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByAquariumIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.desc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByCycle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycle', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByCycleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycle', Sort.desc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByFood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'food', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByFoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'food', Sort.desc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByScheduleTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleTime', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByScheduleTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleTime', Sort.desc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension OneTimeScheduleCacheQuerySortThenBy
    on QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QSortThenBy> {
  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByAquariumId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByAquariumIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.desc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByCycle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycle', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByCycleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycle', Sort.desc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByFood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'food', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByFoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'food', Sort.desc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByScheduleTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleTime', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByScheduleTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleTime', Sort.desc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension OneTimeScheduleCacheQueryWhereDistinct
    on QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QDistinct> {
  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QDistinct>
      distinctByAquariumId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aquariumId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QDistinct>
      distinctByCycle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cycle');
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QDistinct>
      distinctByDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QDistinct>
      distinctByFood({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'food', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QDistinct>
      distinctByScheduleTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduleTime', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OneTimeScheduleCache, OneTimeScheduleCache, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension OneTimeScheduleCacheQueryProperty on QueryBuilder<
    OneTimeScheduleCache, OneTimeScheduleCache, QQueryProperty> {
  QueryBuilder<OneTimeScheduleCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OneTimeScheduleCache, String, QQueryOperations>
      aquariumIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aquariumId');
    });
  }

  QueryBuilder<OneTimeScheduleCache, int, QQueryOperations> cycleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cycle');
    });
  }

  QueryBuilder<OneTimeScheduleCache, String, QQueryOperations>
      documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<OneTimeScheduleCache, String, QQueryOperations> foodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'food');
    });
  }

  QueryBuilder<OneTimeScheduleCache, String, QQueryOperations>
      scheduleTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduleTime');
    });
  }

  QueryBuilder<OneTimeScheduleCache, String, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
