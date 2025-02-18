import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../viewmodels/qr_scan_viewmodel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../app/routes.dart';
import '../../../core/widgets/loading_animation.dart';

class QRScanView extends StatefulWidget {
  final int rentalDuration;
  final bool isReturn;
  final dynamic initialRental;

  const QRScanView({
    Key? key,
    required this.rentalDuration,
    required this.isReturn,
    this.initialRental,
  }) : super(key: key);

  @override
  State<QRScanView> createState() => _QRScanViewState();
}

class _QRScanViewState extends State<QRScanView> {
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QRScanViewModel(
        rentalDuration: widget.rentalDuration,
        isReturn: widget.isReturn,
        initialRental: widget.initialRental,
      ),
      child: Consumer<QRScanViewModel>(
        builder: (context, viewModel, child) {
          // rental 값이 변경될 때마다 체크
          if (viewModel.rental != null) {
            // 마이크로태스크 큐에 네비게이션 작업 추가
            Future.microtask(() {
              if (widget.isReturn) {
                Navigator.of(context).pop(true);
              } else {
                Navigator.of(context).pushReplacementNamed(
                  Routes.payment,
                  arguments: viewModel.rental,
                );
              }
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.isReturn ? 'QR 스캔하여 반납' : 'QR 스캔하여 대여'),
              centerTitle: true,
              actions: [
                // 디버깅용 스킵 버튼
                TextButton(
                  onPressed: () async {
                    if (widget.isReturn) {
                      Navigator.of(context).pop(true);
                    } else {
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.payment);
                    }
                  },
                  child: const Text(
                    '[DEV] 스킵',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            body: Builder(
              builder: (context) {
                if (!viewModel.hasCameraPermission) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '카메라 권한이 필요합니다',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'QR 코드를 스캔하기 위해\n카메라 권한이 필요합니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          child: const Text('카메라 권한 허용'),
                          onPressed: () async {
                            final hasPermission =
                                await viewModel.requestCameraPermission();
                            if (!hasPermission && context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('카메라 권한 필요'),
                                  content: const Text(
                                    'QR 코드를 스캔하기 위해 카메라 권한이 필요합니다.\n설정에서 카메라 권한을 허용해주세요.',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('취소'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // TODO: 시스템 설정으로 이동
                                      },
                                      child: const Text('설정으로 이동'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.isProcessing) {
                  return const Center(
                    child: HoneyLoadingAnimation(
                      isStationSelected: false,
                    ),
                  );
                }

                if (viewModel.error != null) {
                  return Stack(
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null) {
                              if (widget.isReturn) {
                                viewModel
                                    .processReturnQRCode(barcode.rawValue!);
                              } else {
                                viewModel
                                    .processRentalQRCode(barcode.rawValue!);
                              }
                              break;
                            }
                          }
                        },
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppColors.error,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      viewModel.error!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: viewModel.clearError,
                                child: const Text('다시 시도'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Stack(
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            if (widget.isReturn) {
                              viewModel.processReturnQRCode(barcode.rawValue!);
                            } else {
                              viewModel.processRentalQRCode(barcode.rawValue!);
                            }
                            break;
                          }
                        }
                      },
                    ),
                    CustomPaint(
                      painter: ScannerOverlayPainter(),
                      child: const SizedBox.expand(),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Text(
                        widget.isReturn
                            ? '반납할 스테이션의 QR 코드를 스캔해주세요'
                            : '대여할 물품의 QR 코드를 스캔해주세요',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2;

    // 스캔 영역 외부를 어둡게 처리
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(
        scanAreaLeft,
        scanAreaTop,
        scanAreaSize,
        scanAreaSize,
      ));

    canvas.drawPath(path, paint);

    // 스캔 영역 테두리
    final borderPaint = Paint()
      ..color = const Color(0xFFFFBE00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(
      Rect.fromLTWH(
        scanAreaLeft,
        scanAreaTop,
        scanAreaSize,
        scanAreaSize,
      ),
      borderPaint,
    );

    // 모서리 표시
    final cornerLength = scanAreaSize * 0.1;
    final cornerPaint = Paint()
      ..color = const Color(0xFFFFBE00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // 좌상단
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft + cornerLength, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft, scanAreaTop + cornerLength),
      cornerPaint,
    );

    // 우상단
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + cornerLength),
      cornerPaint,
    );

    // 좌하단
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + cornerLength, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize - cornerLength),
      cornerPaint,
    );

    // 우하단
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize - cornerLength,
          scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize,
          scanAreaTop + scanAreaSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
