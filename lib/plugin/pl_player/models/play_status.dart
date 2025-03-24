import 'package:get/get.dart';

enum PlayerStatus { completed, playing, paused, error }

class PlPlayerStatus {
  Rx<PlayerStatus> status = Rx(PlayerStatus.paused);

  bool get playing {
    return status.value == PlayerStatus.playing;
  }

  bool get isPlaying {
    return status.value == PlayerStatus.playing;
  }

  bool get paused {
    return status.value == PlayerStatus.paused;
  }

  bool get completed {
    return status.value == PlayerStatus.completed;
  }
  
  void reset() {
    status.value = PlayerStatus.paused;
  }
}
