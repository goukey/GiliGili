import 'package:GiliGili/common/widgets/pair.dart';
import 'package:GiliGili/models/common/sponsor_block/action_type.dart';
import 'package:GiliGili/models/common/sponsor_block/segment_type.dart';

class PostSegmentModel {
  PostSegmentModel({
    required this.segment,
    required this.category,
    required this.actionType,
  });
  Pair<int, int> segment;
  SegmentType category;
  ActionType actionType;
}
