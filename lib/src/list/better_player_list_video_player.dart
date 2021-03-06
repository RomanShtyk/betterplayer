import 'package:better_player/better_player.dart';
import 'package:better_player/src/configuration/better_player_configuration.dart';
import 'package:better_player/src/configuration/better_player_data_source.dart';
import 'package:better_player/src/list/better_player_list_video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

class BetterPlayerListVideoPlayer extends StatefulWidget {
  ///Video to show
  final BetterPlayerDataSource dataSource;

  ///Video player configuration
  final BetterPlayerConfiguration configuration;

  ///Fraction of the screen height that will trigger play/pause. For example
  ///if playFraction is 0.6 video will be played if 60% of player height is
  ///visible.
  final double playFraction;

  ///Flag to determine if video should be auto played
  final bool autoPlay;

  ///Flag to determine if video should be auto paused
  final bool autoPause;

  final BetterPlayerListVideoPlayerController
      betterPlayerListVideoPlayerController;

  final Function stateChangeNotifier;

  const BetterPlayerListVideoPlayer(this.dataSource,
      {this.configuration = const BetterPlayerConfiguration(),
      this.playFraction = 0.6,
      this.autoPlay = true,
      this.autoPause = true,
      this.stateChangeNotifier,
      this.betterPlayerListVideoPlayerController,
      Key key})
      : assert(dataSource != null, "Data source can't be null"),
        assert(configuration != null, "Configuration can't be null"),
        assert(
            playFraction != null && playFraction >= 0.0 && playFraction <= 1.0,
            "Play fraction can't be null and must be between 0.0 and 1.0"),
        assert(autoPlay != null, "Auto play can't be null"),
        assert(autoPause != null, "Auto pause can't be null"),
        super(key: key);

  @override
  _BetterPlayerListVideoPlayerState createState() =>
      _BetterPlayerListVideoPlayerState();
}

class _BetterPlayerListVideoPlayerState
    extends State<BetterPlayerListVideoPlayer>
    with AutomaticKeepAliveClientMixin<BetterPlayerListVideoPlayer> {
  BetterPlayerController _betterPlayerController;
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    _betterPlayerController = BetterPlayerController(
      widget.configuration,
      betterPlayerDataSource: widget.dataSource,
      betterPlayerPlaylistConfiguration: BetterPlayerPlaylistConfiguration(),
    );

    if (widget.betterPlayerListVideoPlayerController != null) {
      widget.betterPlayerListVideoPlayerController
          .setBetterPlayerController(_betterPlayerController);
    }
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    _isDisposing = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return VisibilityDetector(
      child: BetterPlayer(
        key: Key("${_getUniqueKey()}_player"),
        controller: _betterPlayerController,
      ),
      onVisibilityChanged: (visibilityInfo) async {
        bool isPlaying = await _betterPlayerController.isPlaying();
        bool initialized = _betterPlayerController.isVideoInitialized();
        if (visibilityInfo.visibleFraction >= widget.playFraction) {
          if (widget.autoPlay && initialized && !isPlaying && !_isDisposing) {
            _betterPlayerController.play();
            widget.stateChangeNotifier.call(true);
          }
        } else {
          if (widget.autoPause && initialized && isPlaying && !_isDisposing) {
            _betterPlayerController.pause();
            widget.stateChangeNotifier.call(false);
          }
        }
      },
      key: Key(_getUniqueKey()),
    );
  }

  String _getUniqueKey() => widget.dataSource.hashCode.toString();

  @override
  bool get wantKeepAlive => true;
}
