// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vacant_room.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBuildingCollection on Isar {
  IsarCollection<Building> get buildings => this.collection();
}

const BuildingSchema = CollectionSchema(
  name: r'Building',
  id: 199638258626961957,
  properties: {
    r'buildingName': PropertySchema(
      id: 0,
      name: r'buildingName',
      type: IsarType.string,
    )
  },
  estimateSize: _buildingEstimateSize,
  serialize: _buildingSerialize,
  deserialize: _buildingDeserialize,
  deserializeProp: _buildingDeserializeProp,
  idName: r'id',
  indexes: {
    r'buildingName': IndexSchema(
      id: 7030556158741369329,
      name: r'buildingName',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'buildingName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'classRooms': LinkSchema(
      id: -3124766504494483283,
      name: r'classRooms',
      target: r'ClassRoom',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _buildingGetId,
  getLinks: _buildingGetLinks,
  attach: _buildingAttach,
  version: '3.1.0+1',
);

int _buildingEstimateSize(
  Building object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.buildingName.length * 3;
  return bytesCount;
}

void _buildingSerialize(
  Building object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.buildingName);
}

Building _buildingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Building(
    buildingName: reader.readString(offsets[0]),
  );
  object.id = id;
  return object;
}

P _buildingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _buildingGetId(Building object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _buildingGetLinks(Building object) {
  return [object.classRooms];
}

void _buildingAttach(IsarCollection<dynamic> col, Id id, Building object) {
  object.id = id;
  object.classRooms
      .attach(col, col.isar.collection<ClassRoom>(), r'classRooms', id);
}

extension BuildingByIndex on IsarCollection<Building> {
  Future<Building?> getByBuildingName(String buildingName) {
    return getByIndex(r'buildingName', [buildingName]);
  }

  Building? getByBuildingNameSync(String buildingName) {
    return getByIndexSync(r'buildingName', [buildingName]);
  }

  Future<bool> deleteByBuildingName(String buildingName) {
    return deleteByIndex(r'buildingName', [buildingName]);
  }

  bool deleteByBuildingNameSync(String buildingName) {
    return deleteByIndexSync(r'buildingName', [buildingName]);
  }

  Future<List<Building?>> getAllByBuildingName(
      List<String> buildingNameValues) {
    final values = buildingNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'buildingName', values);
  }

  List<Building?> getAllByBuildingNameSync(List<String> buildingNameValues) {
    final values = buildingNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'buildingName', values);
  }

  Future<int> deleteAllByBuildingName(List<String> buildingNameValues) {
    final values = buildingNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'buildingName', values);
  }

  int deleteAllByBuildingNameSync(List<String> buildingNameValues) {
    final values = buildingNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'buildingName', values);
  }

  Future<Id> putByBuildingName(Building object) {
    return putByIndex(r'buildingName', object);
  }

  Id putByBuildingNameSync(Building object, {bool saveLinks = true}) {
    return putByIndexSync(r'buildingName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBuildingName(List<Building> objects) {
    return putAllByIndex(r'buildingName', objects);
  }

  List<Id> putAllByBuildingNameSync(List<Building> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'buildingName', objects, saveLinks: saveLinks);
  }
}

extension BuildingQueryWhereSort on QueryBuilder<Building, Building, QWhere> {
  QueryBuilder<Building, Building, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BuildingQueryWhere on QueryBuilder<Building, Building, QWhereClause> {
  QueryBuilder<Building, Building, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Building, Building, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Building, Building, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Building, Building, QAfterWhereClause> idBetween(
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

  QueryBuilder<Building, Building, QAfterWhereClause> buildingNameEqualTo(
      String buildingName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'buildingName',
        value: [buildingName],
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterWhereClause> buildingNameNotEqualTo(
      String buildingName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'buildingName',
              lower: [],
              upper: [buildingName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'buildingName',
              lower: [buildingName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'buildingName',
              lower: [buildingName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'buildingName',
              lower: [],
              upper: [buildingName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BuildingQueryFilter
    on QueryBuilder<Building, Building, QFilterCondition> {
  QueryBuilder<Building, Building, QAfterFilterCondition> buildingNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'buildingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition>
      buildingNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'buildingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition> buildingNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'buildingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition> buildingNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'buildingName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition>
      buildingNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'buildingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition> buildingNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'buildingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition> buildingNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'buildingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition> buildingNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'buildingName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition>
      buildingNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'buildingName',
        value: '',
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition>
      buildingNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'buildingName',
        value: '',
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Building, Building, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Building, Building, QAfterFilterCondition> idBetween(
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
}

extension BuildingQueryObject
    on QueryBuilder<Building, Building, QFilterCondition> {}

extension BuildingQueryLinks
    on QueryBuilder<Building, Building, QFilterCondition> {
  QueryBuilder<Building, Building, QAfterFilterCondition> classRooms(
      FilterQuery<ClassRoom> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'classRooms');
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition>
      classRoomsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'classRooms', length, true, length, true);
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition> classRoomsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'classRooms', 0, true, 0, true);
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition>
      classRoomsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'classRooms', 0, false, 999999, true);
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition>
      classRoomsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'classRooms', 0, true, length, include);
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition>
      classRoomsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'classRooms', length, include, 999999, true);
    });
  }

  QueryBuilder<Building, Building, QAfterFilterCondition>
      classRoomsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'classRooms', lower, includeLower, upper, includeUpper);
    });
  }
}

extension BuildingQuerySortBy on QueryBuilder<Building, Building, QSortBy> {
  QueryBuilder<Building, Building, QAfterSortBy> sortByBuildingName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buildingName', Sort.asc);
    });
  }

  QueryBuilder<Building, Building, QAfterSortBy> sortByBuildingNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buildingName', Sort.desc);
    });
  }
}

extension BuildingQuerySortThenBy
    on QueryBuilder<Building, Building, QSortThenBy> {
  QueryBuilder<Building, Building, QAfterSortBy> thenByBuildingName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buildingName', Sort.asc);
    });
  }

  QueryBuilder<Building, Building, QAfterSortBy> thenByBuildingNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buildingName', Sort.desc);
    });
  }

  QueryBuilder<Building, Building, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Building, Building, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension BuildingQueryWhereDistinct
    on QueryBuilder<Building, Building, QDistinct> {
  QueryBuilder<Building, Building, QDistinct> distinctByBuildingName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'buildingName', caseSensitive: caseSensitive);
    });
  }
}

extension BuildingQueryProperty
    on QueryBuilder<Building, Building, QQueryProperty> {
  QueryBuilder<Building, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Building, String, QQueryOperations> buildingNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'buildingName');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClassRoomCollection on Isar {
  IsarCollection<ClassRoom> get classRooms => this.collection();
}

const ClassRoomSchema = CollectionSchema(
  name: r'ClassRoom',
  id: 2717467172829419821,
  properties: {
    r'classRoomName': PropertySchema(
      id: 0,
      name: r'classRoomName',
      type: IsarType.string,
    )
  },
  estimateSize: _classRoomEstimateSize,
  serialize: _classRoomSerialize,
  deserialize: _classRoomDeserialize,
  deserializeProp: _classRoomDeserializeProp,
  idName: r'classRoomId',
  indexes: {
    r'classRoomName': IndexSchema(
      id: -8329361363504887383,
      name: r'classRoomName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'classRoomName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'hasClass': LinkSchema(
      id: -2113960530335781888,
      name: r'hasClass',
      target: r'HasClass',
      single: false,
    ),
    r'buildingName': LinkSchema(
      id: 8989502602127022072,
      name: r'buildingName',
      target: r'Building',
      single: true,
      linkName: r'classRooms',
    )
  },
  embeddedSchemas: {},
  getId: _classRoomGetId,
  getLinks: _classRoomGetLinks,
  attach: _classRoomAttach,
  version: '3.1.0+1',
);

int _classRoomEstimateSize(
  ClassRoom object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.classRoomName.length * 3;
  return bytesCount;
}

void _classRoomSerialize(
  ClassRoom object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.classRoomName);
}

ClassRoom _classRoomDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClassRoom(
    classRoomName: reader.readString(offsets[0]),
  );
  return object;
}

P _classRoomDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _classRoomGetId(ClassRoom object) {
  return object.classRoomId;
}

List<IsarLinkBase<dynamic>> _classRoomGetLinks(ClassRoom object) {
  return [object.hasClass, object.buildingName];
}

void _classRoomAttach(IsarCollection<dynamic> col, Id id, ClassRoom object) {
  object.hasClass.attach(col, col.isar.collection<HasClass>(), r'hasClass', id);
  object.buildingName
      .attach(col, col.isar.collection<Building>(), r'buildingName', id);
}

extension ClassRoomQueryWhereSort
    on QueryBuilder<ClassRoom, ClassRoom, QWhere> {
  QueryBuilder<ClassRoom, ClassRoom, QAfterWhere> anyClassRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ClassRoomQueryWhere
    on QueryBuilder<ClassRoom, ClassRoom, QWhereClause> {
  QueryBuilder<ClassRoom, ClassRoom, QAfterWhereClause> classRoomIdEqualTo(
      Id classRoomId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: classRoomId,
        upper: classRoomId,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterWhereClause> classRoomIdNotEqualTo(
      Id classRoomId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: classRoomId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(
                  lower: classRoomId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(
                  lower: classRoomId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: classRoomId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterWhereClause> classRoomIdGreaterThan(
      Id classRoomId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: classRoomId, includeLower: include),
      );
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterWhereClause> classRoomIdLessThan(
      Id classRoomId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: classRoomId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterWhereClause> classRoomIdBetween(
    Id lowerClassRoomId,
    Id upperClassRoomId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerClassRoomId,
        includeLower: includeLower,
        upper: upperClassRoomId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterWhereClause> classRoomNameEqualTo(
      String classRoomName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'classRoomName',
        value: [classRoomName],
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterWhereClause> classRoomNameNotEqualTo(
      String classRoomName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'classRoomName',
              lower: [],
              upper: [classRoomName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'classRoomName',
              lower: [classRoomName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'classRoomName',
              lower: [classRoomName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'classRoomName',
              lower: [],
              upper: [classRoomName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ClassRoomQueryFilter
    on QueryBuilder<ClassRoom, ClassRoom, QFilterCondition> {
  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition> classRoomIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classRoomId',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      classRoomIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'classRoomId',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition> classRoomIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'classRoomId',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition> classRoomIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'classRoomId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      classRoomNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classRoomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      classRoomNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'classRoomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      classRoomNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'classRoomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      classRoomNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'classRoomName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      classRoomNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'classRoomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      classRoomNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'classRoomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      classRoomNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'classRoomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      classRoomNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'classRoomName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      classRoomNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classRoomName',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      classRoomNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classRoomName',
        value: '',
      ));
    });
  }
}

extension ClassRoomQueryObject
    on QueryBuilder<ClassRoom, ClassRoom, QFilterCondition> {}

extension ClassRoomQueryLinks
    on QueryBuilder<ClassRoom, ClassRoom, QFilterCondition> {
  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition> hasClass(
      FilterQuery<HasClass> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'hasClass');
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      hasClassLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'hasClass', length, true, length, true);
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition> hasClassIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'hasClass', 0, true, 0, true);
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      hasClassIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'hasClass', 0, false, 999999, true);
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      hasClassLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'hasClass', 0, true, length, include);
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      hasClassLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'hasClass', length, include, 999999, true);
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      hasClassLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'hasClass', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition> buildingName(
      FilterQuery<Building> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'buildingName');
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterFilterCondition>
      buildingNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'buildingName', 0, true, 0, true);
    });
  }
}

extension ClassRoomQuerySortBy on QueryBuilder<ClassRoom, ClassRoom, QSortBy> {
  QueryBuilder<ClassRoom, ClassRoom, QAfterSortBy> sortByClassRoomName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classRoomName', Sort.asc);
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterSortBy> sortByClassRoomNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classRoomName', Sort.desc);
    });
  }
}

extension ClassRoomQuerySortThenBy
    on QueryBuilder<ClassRoom, ClassRoom, QSortThenBy> {
  QueryBuilder<ClassRoom, ClassRoom, QAfterSortBy> thenByClassRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classRoomId', Sort.asc);
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterSortBy> thenByClassRoomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classRoomId', Sort.desc);
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterSortBy> thenByClassRoomName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classRoomName', Sort.asc);
    });
  }

  QueryBuilder<ClassRoom, ClassRoom, QAfterSortBy> thenByClassRoomNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classRoomName', Sort.desc);
    });
  }
}

extension ClassRoomQueryWhereDistinct
    on QueryBuilder<ClassRoom, ClassRoom, QDistinct> {
  QueryBuilder<ClassRoom, ClassRoom, QDistinct> distinctByClassRoomName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classRoomName',
          caseSensitive: caseSensitive);
    });
  }
}

extension ClassRoomQueryProperty
    on QueryBuilder<ClassRoom, ClassRoom, QQueryProperty> {
  QueryBuilder<ClassRoom, int, QQueryOperations> classRoomIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classRoomId');
    });
  }

  QueryBuilder<ClassRoom, String, QQueryOperations> classRoomNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classRoomName');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHasClassCollection on Isar {
  IsarCollection<HasClass> get hasClass => this.collection();
}

const HasClassSchema = CollectionSchema(
  name: r'HasClass',
  id: 3212262577366027092,
  properties: {
    r'period': PropertySchema(
      id: 0,
      name: r'period',
      type: IsarType.long,
    ),
    r'quarter': PropertySchema(
      id: 1,
      name: r'quarter',
      type: IsarType.string,
    ),
    r'weekday': PropertySchema(
      id: 2,
      name: r'weekday',
      type: IsarType.long,
    )
  },
  estimateSize: _hasClassEstimateSize,
  serialize: _hasClassSerialize,
  deserialize: _hasClassDeserialize,
  deserializeProp: _hasClassDeserializeProp,
  idName: r'hasClassId',
  indexes: {},
  links: {
    r'classRoomName': LinkSchema(
      id: -1244200815120769403,
      name: r'classRoomName',
      target: r'ClassRoom',
      single: false,
      linkName: r'hasClass',
    )
  },
  embeddedSchemas: {},
  getId: _hasClassGetId,
  getLinks: _hasClassGetLinks,
  attach: _hasClassAttach,
  version: '3.1.0+1',
);

int _hasClassEstimateSize(
  HasClass object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.quarter.length * 3;
  return bytesCount;
}

void _hasClassSerialize(
  HasClass object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.period);
  writer.writeString(offsets[1], object.quarter);
  writer.writeLong(offsets[2], object.weekday);
}

HasClass _hasClassDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HasClass(
    period: reader.readLong(offsets[0]),
    quarter: reader.readString(offsets[1]),
    weekday: reader.readLong(offsets[2]),
  );
  return object;
}

P _hasClassDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _hasClassGetId(HasClass object) {
  return object.hasClassId;
}

List<IsarLinkBase<dynamic>> _hasClassGetLinks(HasClass object) {
  return [object.classRoomName];
}

void _hasClassAttach(IsarCollection<dynamic> col, Id id, HasClass object) {
  object.classRoomName
      .attach(col, col.isar.collection<ClassRoom>(), r'classRoomName', id);
}

extension HasClassQueryWhereSort on QueryBuilder<HasClass, HasClass, QWhere> {
  QueryBuilder<HasClass, HasClass, QAfterWhere> anyHasClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HasClassQueryWhere on QueryBuilder<HasClass, HasClass, QWhereClause> {
  QueryBuilder<HasClass, HasClass, QAfterWhereClause> hasClassIdEqualTo(
      Id hasClassId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: hasClassId,
        upper: hasClassId,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterWhereClause> hasClassIdNotEqualTo(
      Id hasClassId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: hasClassId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: hasClassId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: hasClassId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: hasClassId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterWhereClause> hasClassIdGreaterThan(
      Id hasClassId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: hasClassId, includeLower: include),
      );
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterWhereClause> hasClassIdLessThan(
      Id hasClassId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: hasClassId, includeUpper: include),
      );
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterWhereClause> hasClassIdBetween(
    Id lowerHasClassId,
    Id upperHasClassId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerHasClassId,
        includeLower: includeLower,
        upper: upperHasClassId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension HasClassQueryFilter
    on QueryBuilder<HasClass, HasClass, QFilterCondition> {
  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> hasClassIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasClassId',
        value: value,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> hasClassIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hasClassId',
        value: value,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> hasClassIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hasClassId',
        value: value,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> hasClassIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hasClassId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> periodEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'period',
        value: value,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> periodGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'period',
        value: value,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> periodLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'period',
        value: value,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> periodBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'period',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> quarterEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quarter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> quarterGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quarter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> quarterLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quarter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> quarterBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quarter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> quarterStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'quarter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> quarterEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'quarter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> quarterContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'quarter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> quarterMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'quarter',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> quarterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quarter',
        value: '',
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> quarterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'quarter',
        value: '',
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> weekdayEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekday',
        value: value,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> weekdayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekday',
        value: value,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> weekdayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekday',
        value: value,
      ));
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> weekdayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekday',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension HasClassQueryObject
    on QueryBuilder<HasClass, HasClass, QFilterCondition> {}

extension HasClassQueryLinks
    on QueryBuilder<HasClass, HasClass, QFilterCondition> {
  QueryBuilder<HasClass, HasClass, QAfterFilterCondition> classRoomName(
      FilterQuery<ClassRoom> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'classRoomName');
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition>
      classRoomNameLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'classRoomName', length, true, length, true);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition>
      classRoomNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'classRoomName', 0, true, 0, true);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition>
      classRoomNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'classRoomName', 0, false, 999999, true);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition>
      classRoomNameLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'classRoomName', 0, true, length, include);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition>
      classRoomNameLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'classRoomName', length, include, 999999, true);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterFilterCondition>
      classRoomNameLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'classRoomName', lower, includeLower, upper, includeUpper);
    });
  }
}

extension HasClassQuerySortBy on QueryBuilder<HasClass, HasClass, QSortBy> {
  QueryBuilder<HasClass, HasClass, QAfterSortBy> sortByPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.asc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> sortByPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.desc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> sortByQuarter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quarter', Sort.asc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> sortByQuarterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quarter', Sort.desc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> sortByWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekday', Sort.asc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> sortByWeekdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekday', Sort.desc);
    });
  }
}

extension HasClassQuerySortThenBy
    on QueryBuilder<HasClass, HasClass, QSortThenBy> {
  QueryBuilder<HasClass, HasClass, QAfterSortBy> thenByHasClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasClassId', Sort.asc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> thenByHasClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasClassId', Sort.desc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> thenByPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.asc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> thenByPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.desc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> thenByQuarter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quarter', Sort.asc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> thenByQuarterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quarter', Sort.desc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> thenByWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekday', Sort.asc);
    });
  }

  QueryBuilder<HasClass, HasClass, QAfterSortBy> thenByWeekdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekday', Sort.desc);
    });
  }
}

extension HasClassQueryWhereDistinct
    on QueryBuilder<HasClass, HasClass, QDistinct> {
  QueryBuilder<HasClass, HasClass, QDistinct> distinctByPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'period');
    });
  }

  QueryBuilder<HasClass, HasClass, QDistinct> distinctByQuarter(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quarter', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HasClass, HasClass, QDistinct> distinctByWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekday');
    });
  }
}

extension HasClassQueryProperty
    on QueryBuilder<HasClass, HasClass, QQueryProperty> {
  QueryBuilder<HasClass, int, QQueryOperations> hasClassIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasClassId');
    });
  }

  QueryBuilder<HasClass, int, QQueryOperations> periodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'period');
    });
  }

  QueryBuilder<HasClass, String, QQueryOperations> quarterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quarter');
    });
  }

  QueryBuilder<HasClass, int, QQueryOperations> weekdayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekday');
    });
  }
}
