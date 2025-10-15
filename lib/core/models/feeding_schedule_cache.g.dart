// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeding_schedule_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFeedingScheduleCacheCollection on Isar {
  IsarCollection<FeedingScheduleCache> get feedingScheduleCaches =>
      this.collection();
}

const FeedingScheduleCacheSchema = CollectionSchema(
  name: r'FeedingScheduleCache',
  id: 2093766089907394140,
  properties: {
    r'aquariumId': PropertySchema(
      id: 0,
      name: r'aquariumId',
      type: IsarType.string,
    ),
    r'cycles': PropertySchema(
      id: 1,
      name: r'cycles',
      type: IsarType.long,
    ),
    r'daily': PropertySchema(
      id: 2,
      name: r'daily',
      type: IsarType.bool,
    ),
    r'foodType': PropertySchema(
      id: 3,
      name: r'foodType',
      type: IsarType.string,
    ),
    r'isEnabled': PropertySchema(
      id: 4,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'scheduleId': PropertySchema(
      id: 5,
      name: r'scheduleId',
      type: IsarType.string,
    ),
    r'time': PropertySchema(
      id: 6,
      name: r'time',
      type: IsarType.string,
    )
  },
  estimateSize: _feedingScheduleCacheEstimateSize,
  serialize: _feedingScheduleCacheSerialize,
  deserialize: _feedingScheduleCacheDeserialize,
  deserializeProp: _feedingScheduleCacheDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _feedingScheduleCacheGetId,
  getLinks: _feedingScheduleCacheGetLinks,
  attach: _feedingScheduleCacheAttach,
  version: '3.1.0+1',
);

int _feedingScheduleCacheEstimateSize(
  FeedingScheduleCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aquariumId.length * 3;
  bytesCount += 3 + object.foodType.length * 3;
  bytesCount += 3 + object.scheduleId.length * 3;
  bytesCount += 3 + object.time.length * 3;
  return bytesCount;
}

void _feedingScheduleCacheSerialize(
  FeedingScheduleCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aquariumId);
  writer.writeLong(offsets[1], object.cycles);
  writer.writeBool(offsets[2], object.daily);
  writer.writeString(offsets[3], object.foodType);
  writer.writeBool(offsets[4], object.isEnabled);
  writer.writeString(offsets[5], object.scheduleId);
  writer.writeString(offsets[6], object.time);
}

FeedingScheduleCache _feedingScheduleCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FeedingScheduleCache();
  object.aquariumId = reader.readString(offsets[0]);
  object.cycles = reader.readLong(offsets[1]);
  object.daily = reader.readBool(offsets[2]);
  object.foodType = reader.readString(offsets[3]);
  object.id = id;
  object.isEnabled = reader.readBool(offsets[4]);
  object.scheduleId = reader.readString(offsets[5]);
  object.time = reader.readString(offsets[6]);
  return object;
}

P _feedingScheduleCacheDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _feedingScheduleCacheGetId(FeedingScheduleCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _feedingScheduleCacheGetLinks(
    FeedingScheduleCache object) {
  return [];
}

void _feedingScheduleCacheAttach(
    IsarCollection<dynamic> col, Id id, FeedingScheduleCache object) {
  object.id = id;
}

extension FeedingScheduleCacheQueryWhereSort
    on QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QWhere> {
  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FeedingScheduleCacheQueryWhere
    on QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QWhereClause> {
  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterWhereClause>
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterWhereClause>
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

extension FeedingScheduleCacheQueryFilter on QueryBuilder<FeedingScheduleCache,
    FeedingScheduleCache, QFilterCondition> {
  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> aquariumIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aquariumId',
        value: '',
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> aquariumIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aquariumId',
        value: '',
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> cyclesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cycles',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> cyclesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cycles',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> cyclesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cycles',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> cyclesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cycles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> dailyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'daily',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> foodTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> foodTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> foodTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> foodTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foodType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> foodTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> foodTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
          QAfterFilterCondition>
      foodTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
          QAfterFilterCondition>
      foodTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'foodType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> foodTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodType',
        value: '',
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> foodTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'foodType',
        value: '',
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
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

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> isEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> scheduleIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> scheduleIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> scheduleIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> scheduleIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> scheduleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scheduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> scheduleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scheduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
          QAfterFilterCondition>
      scheduleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scheduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
          QAfterFilterCondition>
      scheduleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scheduleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> scheduleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduleId',
        value: '',
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> scheduleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scheduleId',
        value: '',
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> timeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> timeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> timeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> timeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'time',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> timeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> timeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
          QAfterFilterCondition>
      timeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
          QAfterFilterCondition>
      timeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'time',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> timeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: '',
      ));
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache,
      QAfterFilterCondition> timeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'time',
        value: '',
      ));
    });
  }
}

extension FeedingScheduleCacheQueryObject on QueryBuilder<FeedingScheduleCache,
    FeedingScheduleCache, QFilterCondition> {}

extension FeedingScheduleCacheQueryLinks on QueryBuilder<FeedingScheduleCache,
    FeedingScheduleCache, QFilterCondition> {}

extension FeedingScheduleCacheQuerySortBy
    on QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QSortBy> {
  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByAquariumId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByAquariumIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycles', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByCyclesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycles', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByDaily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daily', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByDailyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daily', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByFoodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodType', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByFoodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodType', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByScheduleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleId', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByScheduleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleId', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }
}

extension FeedingScheduleCacheQuerySortThenBy
    on QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QSortThenBy> {
  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByAquariumId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByAquariumIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aquariumId', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycles', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByCyclesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycles', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByDaily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daily', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByDailyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daily', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByFoodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodType', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByFoodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodType', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByScheduleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleId', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByScheduleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleId', Sort.desc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QAfterSortBy>
      thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }
}

extension FeedingScheduleCacheQueryWhereDistinct
    on QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QDistinct> {
  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QDistinct>
      distinctByAquariumId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aquariumId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QDistinct>
      distinctByCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cycles');
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QDistinct>
      distinctByDaily() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daily');
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QDistinct>
      distinctByFoodType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foodType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QDistinct>
      distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QDistinct>
      distinctByScheduleId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeedingScheduleCache, FeedingScheduleCache, QDistinct>
      distinctByTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time', caseSensitive: caseSensitive);
    });
  }
}

extension FeedingScheduleCacheQueryProperty on QueryBuilder<
    FeedingScheduleCache, FeedingScheduleCache, QQueryProperty> {
  QueryBuilder<FeedingScheduleCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FeedingScheduleCache, String, QQueryOperations>
      aquariumIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aquariumId');
    });
  }

  QueryBuilder<FeedingScheduleCache, int, QQueryOperations> cyclesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cycles');
    });
  }

  QueryBuilder<FeedingScheduleCache, bool, QQueryOperations> dailyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daily');
    });
  }

  QueryBuilder<FeedingScheduleCache, String, QQueryOperations>
      foodTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foodType');
    });
  }

  QueryBuilder<FeedingScheduleCache, bool, QQueryOperations>
      isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<FeedingScheduleCache, String, QQueryOperations>
      scheduleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduleId');
    });
  }

  QueryBuilder<FeedingScheduleCache, String, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }
}
