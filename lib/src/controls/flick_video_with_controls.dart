import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

/// Default Video with Controls.
///
/// Returns a Stack with the following arrangement.
///    * [FlickVideoPlayer]
///    * Stack (Wrapped with [Positioned.fill()])
///      * Video Player loading fallback (conditionally rendered if player is not initialized).
///      * Video player error fallback (conditionally rendered if error in initializing the player).
///      * Controls.
class FlickVideoWithControls extends StatefulWidget {
  const FlickVideoWithControls({
    Key? key,
    this.controls,
    this.videoFit = BoxFit.cover,
    this.playerLoadingFallback = const Center(
      child: CircularProgressIndicator(),
    ),
    this.playerErrorFallback = const Center(
      child: const Icon(
        Icons.error,
        color: Colors.white,
      ),
    ),
    this.backgroundColor = Colors.black,
    this.iconThemeData = const IconThemeData(
      color: Colors.white,
      size: 20,
    ),
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
    this.backgroundImage,
    this.backgroundImageFit = BoxFit.cover,
    this.aspectRatioWhenLoading = 16 / 9,
    this.willVideoPlayerControllerChange = true,
    this.closedCaptionTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
  }) : super(key: key);

  /// Create custom controls or use any of these [FlickPortraitControls], [FlickLandscapeControls]
  final Widget? controls;

  /// Conditionally rendered if player is not initialized.
  final Widget playerLoadingFallback;

  /// Conditionally rendered if player is has errors.
  final Widget playerErrorFallback;

  /// Property passed to [FlickVideoPlayer]
  final BoxFit videoFit;
  final Color backgroundColor;

  /// Used in [FlickVideoPlayer] background image decoration.
  final Image? backgroundImage;

  /// The fit for video the background image.
  final BoxFit backgroundImageFit;

  /// Used in [DefaultTextStyle]
  ///
  /// Use this property if you require to override the text style provided by the default Flick widgets.
  ///
  /// If any text style property is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final TextStyle textStyle;

  /// Used in [DefaultTextStyle]
  ///
  /// Use this property if you require to override the text style provided by the default ClosedCaption widgets.
  ///
  /// If any text style property is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final TextStyle closedCaptionTextStyle;

  /// Used in [IconTheme]
  ///
  /// Use this property if you require to override the icon style provided by the default Flick widgets.
  ///
  /// If any icon style is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final IconThemeData iconThemeData;

  /// If [FlickPlayer] has unbounded constraints this aspectRatio is used to take the size on the screen.
  ///
  /// Once the video is initialized, video determines size taken.
  final double aspectRatioWhenLoading;

  /// If false videoPlayerController will not be updated.
  final bool willVideoPlayerControllerChange;

  get videoPlayerController => null;

  @override
  _FlickVideoWithControlsState createState() => _FlickVideoWithControlsState();
}

class _FlickVideoWithControlsState extends State<FlickVideoWithControls> {
  VideoPlayerController? _videoPlayerController;
  @override
  void didChangeDependencies() {
    VideoPlayerController? newController =
        Provider.of<FlickVideoManager>(context).videoPlayerController;
    if ((widget.willVideoPlayerControllerChange &&
            _videoPlayerController != newController) ||
        _videoPlayerController == null) {
      _videoPlayerController = newController;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    bool _showVideoCaption = controlManager.isSub;
    return IconTheme(
      data: widget.iconThemeData,
      child: LayoutBuilder(builder: (context, size) {
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            image: widget.backgroundImage == null
                ? null
                : DecorationImage(
                    image: widget.backgroundImage!.image,
                    fit: widget.backgroundImageFit,
                  ),
          ),
          child: DefaultTextStyle(
            style: widget.textStyle,
            child: Stack(
              children: <Widget>[
                Center(
                  child: _videoPlayerController != null
                      ? FlickNativeVideoPlayer(
                          videoPlayerController: _videoPlayerController!,
                          fit: widget.videoFit,
                          aspectRatioWhenLoading: widget.aspectRatioWhenLoading,
                        )
                      : widget.playerLoadingFallback,
                ),
                Positioned.fill(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      _videoPlayerController?.closedCaptionFile != null &&
                              _showVideoCaption
                          ? Positioned(
                              bottom: 5,
                              child: Transform.scale(
                                scale: 0.7,
                                child: ClosedCaption(
                                    textStyle: widget.closedCaptionTextStyle,
                                    text: _videoPlayerController!
                                        .value.caption.text),
                              ),
                            )
                          : SizedBox(),
                      if (_videoPlayerController?.value.hasError == false &&
                          _videoPlayerController?.value.isInitialized == false)
                        widget.playerLoadingFallback,
                      if (_videoPlayerController?.value.hasError == true)
                        widget.playerErrorFallback,
                      if (_videoPlayerController != null &&
                          _videoPlayerController!.value.isInitialized)
                        widget.controls ?? Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
