//
//  Generated code. Do not modify.
//  source: bilibili/dagw/component/avatar/common/common.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ResourceSource_LocalRes extends $pb.ProtobufEnum {
  static const ResourceSource_LocalRes LOCAL_RES_INVALID = ResourceSource_LocalRes._(0, _omitEnumNames ? '' : 'LOCAL_RES_INVALID');
  static const ResourceSource_LocalRes LOCAL_RES_ICON_VIP = ResourceSource_LocalRes._(1, _omitEnumNames ? '' : 'LOCAL_RES_ICON_VIP');
  static const ResourceSource_LocalRes LOCAL_RES_ICON_SMALL_VIP = ResourceSource_LocalRes._(2, _omitEnumNames ? '' : 'LOCAL_RES_ICON_SMALL_VIP');
  static const ResourceSource_LocalRes LOCAL_RES_ICON_PERSONAL_VERIFY = ResourceSource_LocalRes._(3, _omitEnumNames ? '' : 'LOCAL_RES_ICON_PERSONAL_VERIFY');
  static const ResourceSource_LocalRes LOCAL_RES_ICON_ENTERPRISE_VERIFY = ResourceSource_LocalRes._(4, _omitEnumNames ? '' : 'LOCAL_RES_ICON_ENTERPRISE_VERIFY');
  static const ResourceSource_LocalRes LOCAL_RES_ICON_NFT_MAINLAND = ResourceSource_LocalRes._(5, _omitEnumNames ? '' : 'LOCAL_RES_ICON_NFT_MAINLAND');
  static const ResourceSource_LocalRes LOCAL_RES_DEFAULT_AVATAR = ResourceSource_LocalRes._(6, _omitEnumNames ? '' : 'LOCAL_RES_DEFAULT_AVATAR');

  static const $core.List<ResourceSource_LocalRes> values = <ResourceSource_LocalRes> [
    LOCAL_RES_INVALID,
    LOCAL_RES_ICON_VIP,
    LOCAL_RES_ICON_SMALL_VIP,
    LOCAL_RES_ICON_PERSONAL_VERIFY,
    LOCAL_RES_ICON_ENTERPRISE_VERIFY,
    LOCAL_RES_ICON_NFT_MAINLAND,
    LOCAL_RES_DEFAULT_AVATAR,
  ];

  static final $core.Map<$core.int, ResourceSource_LocalRes> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ResourceSource_LocalRes? valueOf($core.int value) => _byValue[value];

  const ResourceSource_LocalRes._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
