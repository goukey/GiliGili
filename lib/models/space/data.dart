import 'package:json_annotation/json_annotation.dart';

import 'archive.dart';
import 'attention_tip.dart';
import 'audios.dart';
import 'card.dart';
import 'coin_archive.dart';
import 'favourite2.dart';
import 'images.dart';
import 'like_archive.dart';
import 'season.dart';
import 'series.dart';
import 'setting.dart';
import 'tab.dart';
import 'tab2.dart';
import 'package:GiliGili/models/space_article/data.dart' as space;

part 'data.g.dart';

@JsonSerializable()
class Data {
  int? relation;
  @JsonKey(name: 'rel_special')
  int? relSpecial;
  @JsonKey(name: 'guest_relation')
  int? guestRelation;
  @JsonKey(name: 'default_tab')
  String? defaultTab;
  @JsonKey(name: 'is_params')
  bool? isParams;
  Setting? setting;
  Tab? tab;
  Card? card;
  Images? images;
  Archive? archive;
  Series? series;
  space.Data? article;
  Season? season;
  @JsonKey(name: 'coin_archive')
  CoinArchive? coinArchive;
  @JsonKey(name: 'like_archive')
  LikeArchive? likeArchive;
  Audios? audios;
  Favourite2? favourite2;
  @JsonKey(name: 'attention_tip')
  AttentionTip? attentionTip;
  @JsonKey(name: 'fans_effect')
  // FansEffect? fansEffect;
  List<Tab2>? tab2;
  @JsonKey(name: 'nft_face_button')
  dynamic nftFaceButton;
  @JsonKey(name: 'digital_button')
  dynamic digitalButton;
  dynamic entry;
  dynamic live;
  UgcSeason? ugcSeason;

  Data({
    this.relation,
    this.relSpecial,
    this.guestRelation,
    this.defaultTab,
    this.isParams,
    this.setting,
    this.tab,
    this.card,
    this.images,
    this.archive,
    this.series,
    this.article,
    this.season,
    this.coinArchive,
    this.likeArchive,
    this.audios,
    this.favourite2,
    this.attentionTip,
    // this.fansEffect,
    this.tab2,
    this.nftFaceButton,
    this.digitalButton,
    this.entry,
    this.live,
    this.ugcSeason,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

class UgcSeason {
  int? count;

  UgcSeason({
    this.count,
  });

  UgcSeason.fromJson(Map<String, dynamic> json) {
    count = json['count'];
  }
}
