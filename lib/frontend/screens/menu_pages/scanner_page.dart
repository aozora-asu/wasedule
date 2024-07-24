import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerWidget extends StatefulWidget {
  late TextEditingController idController;

  ScannerWidget({
    required this.idController,
    super.key});

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget>
    with SingleTickerProviderStateMixin {
  // スキャナーの作用を制御するコントローラーのオブジェクト
  MobileScannerController controller = MobileScannerController();
  bool isStarted = true; // カメラがオンしているかどうか
  double zoomFactor = 0.0; // ズームの程度。0から1まで。多いほど近い

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(backButton: true),
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // カメラの画面の部分
              SizedBox(
                height: MediaQuery.of(context).size.width * 4 / 3,
                child: MobileScanner(
                  controller: controller,
                  fit: BoxFit.contain,
                  // QRコードかバーコードが見つかった後すぐ実行する関数
                  onDetect: (scandata) {
                    setState(() {
                      controller.stop(); //カメラを止める
                      // 結果を表す画面に切り替える
                      Navigator.of(context).pop();
                      widget.idController.text = scandata.barcodes.first.displayValue ?? "";
                    });
                  },
                ),
              ),
              // ズームを調整するスライダー
              Slider(
                value: zoomFactor,
                // スライダーの値が変えられた時に実行する関数
                onChanged: (sliderValue) {
                  // sliderValueは変化した後の数字
                  setState(() {
                    zoomFactor = sliderValue;
                    controller.setZoomScale(sliderValue); // 新しい値をカメラに設定する
                  });
                },
              ),
              // 下の方にある3つのボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // フラッシュのオン／オフを操るボタン
                  IconButton(
                      // アイコンの表示はオン／オフによって変わる
                      icon: ValueListenableBuilder<TorchState>(
                        valueListenable: controller.torchState,
                        builder: (context, state, child) {
                          switch (state) {
                            // オフしている場合、オンにする
                            case TorchState.off:
                              return const Icon(
                                Icons.flash_off,
                                color: Colors.grey,
                              );
                            // オンしている場合、オフにする
                            case TorchState.on:
                              return const Icon(
                                Icons.flash_on,
                                color:Color(0xFFBBDDFF),
                              );
                          }
                        },
                      ),
                      iconSize: 50,
                      // ボタンが押されたら切り替えを実行する
                      onPressed: () => controller.toggleTorch()),
                  // カメラのオン／オフのボタン
                  IconButton(
                    color: const Color(0xFFBBDDFF),
                    // オン／オフの状態によって表示するアイコンが変わる
                    icon: isStarted
                        ? const Icon(Icons.stop) // ストップのアイコン
                        : const Icon(Icons.play_arrow), // プレイのアイコン
                    iconSize: 50,
                    // ボタンが押されたらオン／オフを実行する
                    onPressed: () => setState(() {
                      isStarted ? controller.stop() : controller.start();
                      isStarted = !isStarted;
                    }),
                  ),
                  // アイコン前のカメラと裏のカメラを切り替えるボタン
                  IconButton(
                    color: const Color(0xFFBBDDFF),
                    icon: ValueListenableBuilder<CameraFacing>(
                      // アイコンの表示は使っているカメラによって変わる
                      valueListenable: controller.cameraFacingState,
                      builder: (context, state, child) {
                        switch (state) {
                          // 前のカメラの場合
                          case CameraFacing.front:
                            return const Icon(Icons.camera_front);
                          // 後ろのカメラの場合
                          case CameraFacing.back:
                            return const Icon(Icons.camera_rear);
                        }
                      },
                    ),
                    iconSize: 50,
                    onPressed: () {
                      if (isStarted) {
                        controller.switchCamera();
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

