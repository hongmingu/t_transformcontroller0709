/// Flutter code sample for InteractiveViewer.transformationController

// This example shows how transformationController can be used to animate the
// transformation back to its starting position.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:t_transformcontroller0709/custom_interactive_viewer.dart';

void main() => runApp(const MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  Animation<Matrix4>? _animationReset;
  late final AnimationController _controllerReset;
  late GlobalKey _imageKey = GlobalKey();
  late GlobalKey _frameKey = GlobalKey();
  late GlobalKey _grandChildKey = GlobalKey();
  double? selectedPositionX;
  double? selectedPositionY;
  bool isUpdating = false;
  List<Offset> polygonPoints = [];
  Duration durationAnimation = Duration(milliseconds: 200);
  Timer? timer;

  void _onAnimateReset() {
    _transformationController.value = _animationReset!.value;
    if (!_controllerReset.isAnimating) {
      _animationReset!.removeListener(_onAnimateReset);
      _animationReset!.removeStatusListener(_onAnimationStatusChange);
      _animationReset = null;
      _controllerReset.reset();
    }
  }

  void _onAnimationStatusChange(AnimationStatus status) {
    print(status.toString());

    switch (status) {
      case AnimationStatus.dismissed:
        double getScale = _transformationController.value.getMaxScaleOnAxis();

        RenderBox? frameBox = getRenderBoxByKey(_frameKey)!;
        RenderBox? imageBox = getRenderBoxByKey(_imageKey)!;

        Offset framePosition = getPositionByBox(frameBox);
        Offset imagePosition = getPositionByBox(imageBox);
        Size frameSize = getSizeByBox(frameBox);
        Size imageSize = getSizeByBox(imageBox) * getScale;

        double frameLeft = framePosition.dx;
        double frameRight = framePosition.dx + frameSize.width;
        double frameTop = framePosition.dy;
        double frameBottom = framePosition.dy + frameSize.height;
        double frameHorizontallyMid = framePosition.dx + frameSize.width / 2;
        double frameVerticallyMid = framePosition.dy + frameSize.height / 2;

        double imageLeft = imagePosition.dx;
        double imageRight = imagePosition.dx + imageSize.width;
        double imageTop = imagePosition.dy;
        double imageBottom = imagePosition.dy + imageSize.height;
        double imageHorizontallyMid = imagePosition.dx + imageSize.width / 2;
        double imageVerticallyMid = imagePosition.dy + imageSize.height / 2;
        if ((frameLeft - imageLeft).abs() > 1) {
          _animateResetStop();
          _animateResetInitialize();
        }
        break;
      case AnimationStatus.forward:
        // TODO: Handle this case.
        break;
      case AnimationStatus.reverse:
        // TODO: Handle this case.
        break;
      case AnimationStatus.completed:
        // TODO: Handle this case.
        break;
    }
  }

  bool isStopped = false; //global

  sec5Timer() {
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      if (isStopped) {
        timer.cancel();
      }
    });
  }

  void _animateResetInitialize() {
    _controllerReset.reset();

    double getScale = _transformationController.value.getMaxScaleOnAxis();
    double toScale = 1;

    // double xMoved = _transformationController.value.getTranslation().x; //x 이동값이고 panSpeedRatio 로 나눠주면 본래 값이 나온다.
    // double yMoved = _transformationController.value.getTranslation().y; //y 이동값이고 panSpeedRatio 로 나눠주면 본래 값이 나온다.

    RenderBox? frameBox = getRenderBoxByKey(_frameKey)!;
    RenderBox? imageBox = getRenderBoxByKey(_imageKey)!;
    // RenderBox? grandChildBox = getRenderBoxByKey(_grandChildKey)!;

    Offset framePosition = getPositionByBox(frameBox);
    Offset imagePosition = getPositionByBox(imageBox);
    Size frameSize = getSizeByBox(frameBox);
    Size imageSize = getSizeByBox(imageBox) * getScale;


    switch (getRatioBySize(imageSize)) {
      case ImageShape.landscape:
        if (frameSize.height > imageSize.height) {
          toScale = frameSize.height / imageSize.height;
          imageSize = imageSize * frameSize.height / imageSize.height;
        } else if (imageSize.height > getSizeByBox(imageBox).height){
          toScale = getSizeByBox(imageBox).height/imageSize.height;
        }
        break;
      case ImageShape.portrait:
        if (frameSize.width > imageSize.width) {
          toScale = frameSize.width / imageSize.width;
          imageSize = imageSize * frameSize.width / imageSize.width;
        }else if (imageSize.width > getSizeByBox(imageBox).width){
          toScale = getSizeByBox(imageBox).width/imageSize.width;
        }
        break;
      case ImageShape.square:

        if (frameSize.width > imageSize.width) {
          toScale = frameSize.width / imageSize.width;
          imageSize = imageSize * frameSize.width / imageSize.width;
        }else if (imageSize.width > getSizeByBox(imageBox).width){
          toScale = getSizeByBox(imageBox).width/imageSize.width;
        }
        break;
    }

    double frameLeft = framePosition.dx;
    double frameRight = framePosition.dx + frameSize.width;
    double frameTop = framePosition.dy;
    double frameBottom = framePosition.dy + frameSize.height;

    double imageLeft = imagePosition.dx;
    double imageRight = imagePosition.dx + imageSize.width;
    double imageTop = imagePosition.dy;
    double imageBottom = imagePosition.dy + imageSize.height;

    Matrix4Transform mat4Transform =
        Matrix4Transform.from(_transformationController.value);

    if (frameLeft < imageLeft) {
      mat4Transform = mat4Transform.right(frameLeft - imageLeft);
    } else if (imageRight < frameRight) {
      mat4Transform = mat4Transform.right(frameRight - imageRight);
    }

    if (frameTop < imageTop) {
      mat4Transform = mat4Transform.down(frameTop - imageTop);
    } else if (imageBottom < frameBottom) {
      mat4Transform = mat4Transform.down(frameBottom - imageBottom);
    }

    Matrix4 mat4 = mat4Transform.scale(toScale).matrix4;

    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: mat4,
    ).animate(_controllerReset);
    _animationReset!.addListener(_onAnimateReset);
    _controllerReset.forward();

    // Offset grandChildPosition = getPositionByBox(grandChildBox);
    // print("프레임: ${framePosition.dx}, ${framePosition.dy}");
    // print("차일드: ${imagePosition.dx}, ${imagePosition.dy}");
    // print("차일드 사이즈: ${imageSize.width}, ${imageSize.height}");
    // print("그랜드차일드: ${grandChildPosition.dx}, ${grandChildPosition.dy}"); // 그랜드차일드는 있으면 더 헷갈림
    // print("xMoved, yMoved: $xMoved, $yMoved"); // 이것도 헷갈리기만함
    // print("getScale: $getScale");
  }

// Stop a running reset to home transform animation.
  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset?.removeStatusListener(_onAnimationStatusChange);
    _animationReset?.removeListener(_onAnimateReset);
    _animationReset = null;
    _controllerReset.reset();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    this.isUpdating = true;
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    // _animateResetStop();

    if (_controllerReset.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }

  @override
  void initState() {
    super.initState();
    _controllerReset = AnimationController(
      vsync: this,
      duration: durationAnimation,
    );
    timer = Timer.periodic(new Duration(milliseconds: 10), rewindImage);
  }

  void rewindImage(Timer timer) {
    if ((_controllerReset.status != AnimationStatus.forward) &&
        !this.isUpdating) {
      _controllerReset.reset();

      double getScale = _transformationController.value.getMaxScaleOnAxis();
      double toScale = 1;

      RenderBox? frameBox = getRenderBoxByKey(_frameKey)!;
      RenderBox? imageBox = getRenderBoxByKey(_imageKey)!;

      Offset framePosition = getPositionByBox(frameBox);
      Offset imagePosition = getPositionByBox(imageBox);
      Size frameSize = getSizeByBox(frameBox);
      Size imageSize = getSizeByBox(imageBox) * getScale;

      switch (getRatioBySize(imageSize)) {
        case ImageShape.landscape:
          if (frameSize.height > imageSize.height) {
            toScale = frameSize.height / imageSize.height;
            imageSize = imageSize * frameSize.height / imageSize.height;
          } else if (imageSize.height > getSizeByBox(imageBox).height){
            toScale = getSizeByBox(imageBox).height/imageSize.height;
          }
          break;
        case ImageShape.portrait:
          if (frameSize.width > imageSize.width) {
            toScale = frameSize.width / imageSize.width;
            imageSize = imageSize * frameSize.width / imageSize.width;
          }else if (imageSize.width > getSizeByBox(imageBox).width){
            toScale = getSizeByBox(imageBox).width/imageSize.width;
          }
          break;
        case ImageShape.square:

          if (frameSize.width > imageSize.width) {
            toScale = frameSize.width / imageSize.width;
            imageSize = imageSize * frameSize.width / imageSize.width;
          }else if (imageSize.width > getSizeByBox(imageBox).width){
            toScale = getSizeByBox(imageBox).width/imageSize.width;
          }
          break;
      }

      double frameLeft = framePosition.dx;
      double frameRight = framePosition.dx + frameSize.width;
      double frameTop = framePosition.dy;
      double frameBottom = framePosition.dy + frameSize.height;

      double imageLeft = imagePosition.dx;
      double imageRight = imagePosition.dx + imageSize.width;
      double imageTop = imagePosition.dy;
      double imageBottom = imagePosition.dy + imageSize.height;

      Matrix4Transform mat4Transform =
      Matrix4Transform.from(_transformationController.value);

      int needToBeChange = 4;

      if (frameLeft < imageLeft) {
        mat4Transform = mat4Transform.right(frameLeft - imageLeft);
        needToBeChange = 0;
      } else if (imageRight < frameRight) {
        mat4Transform = mat4Transform.right(frameRight - imageRight);
        needToBeChange = 1;
      }

      if (frameTop < imageTop) {
        mat4Transform = mat4Transform.down(frameTop - imageTop);
        needToBeChange = 2;
      } else if (imageBottom < frameBottom) {
        mat4Transform = mat4Transform.down(frameBottom - imageBottom);
        needToBeChange = 3;
      }

      switch(needToBeChange){
        case 0:
          if ((frameLeft - imageLeft).abs() > 1) {
            _animateResetStop();
            _animateResetInitialize();
          }
          break;
        case 1:

          if ((imageRight - frameRight).abs() > 1) {
            _animateResetStop();
            _animateResetInitialize();
          }
          break;
        case 2:

          if ((frameTop - imageTop).abs() > 1) {
            _animateResetStop();
            _animateResetInitialize();
          }
          break;
        case 3:

          if ((imageBottom - frameBottom).abs() > 1) {
            _animateResetStop();
            _animateResetInitialize();
          }
          break;
        case 4:
          break;
      }

    }
  }

  @override
  void dispose() {
    _controllerReset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Container(
          color: Colors.yellow,
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          child: CustomInteractiveViewer(
            key: _frameKey,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            transformationController: _transformationController,
            minScale: 0.1,
            maxScale: 2.0,
            onInteractionStart: _onInteractionStart,
            onInteractionUpdate: (details) {},
            onInteractionEnd: (details) {
              this.isUpdating = false;

              _animateResetInitialize();
            },
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Container(
                key: _imageKey,
                height: MediaQuery.of(context).size.width * 2,
                width: MediaQuery.of(context).size.height * 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Colors.purpleAccent,
                      Colors.red,
                      Colors.white,
                      Colors.greenAccent,
                      Colors.amber,
                      Colors.black
                    ],
                    stops: <double>[0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      persistentFooterButtons: <Widget>[
        IconButton(
          onPressed: _animateResetInitialize,
          tooltip: 'Reset',
          color: Theme.of(context).colorScheme.surface,
          icon: const Icon(Icons.replay),
        ),
      ],
    );
  }

  Size getSizeByBox(RenderBox box) {
    return box.size;
  }

  Offset getPositionByBox(RenderBox box) {
    return box.localToGlobal(Offset.zero);
  }

  RenderBox? getRenderBoxByKey(GlobalKey key) {
    if (key.currentContext != null) {
      RenderBox box = key.currentContext!.findRenderObject()! as RenderBox;
      return box;
    } else {
      return null;
    }
  }

  dynamic getRatioBySize(Size size) {
    if (size.width > size.height) {
      return ImageShape.landscape;
    } else if (size.width < size.height) {
      return ImageShape.portrait;
    } else {
      return ImageShape.square;
    }
  }
}

typedef Frame(double left, double right, double top, double bottom);

enum ImageShape { portrait, landscape, square }
