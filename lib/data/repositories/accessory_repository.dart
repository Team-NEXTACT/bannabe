import '../models/accessory.dart';

class AccessoryRepository {
  Future<List<Accessory>> getAll() async {
    // 시뮬레이션을 위한 더미 데이터
    await Future.delayed(const Duration(seconds: 1));
    return [
      // 충전기
      Accessory(
        itemTypeId: 'charger-1',
        name: '노트북 고출력 충전기',
        description: '100W PD 고속 충전기',
        price: 2000,
        category: AccessoryCategory.charger,
        stock: 0,
        imageUrl: 'assets/images/items/charger-1.png', // canva
      ),
      Accessory(
        itemTypeId: 'charger-2',
        name: '노트북 PD 충전기',
        description: '65W PD 충전기',
        price: 1500,
        category: AccessoryCategory.charger,
        stock: 3,
        imageUrl: 'assets/images/items/charger-2.png', // canva
      ),
      Accessory(
        itemTypeId: 'charger-3',
        name: 'C타입 충전기',
        description: '25W 고속 충전기',
        price: 1000,
        category: AccessoryCategory.charger,
        stock: 4,
        imageUrl:
            'assets/images/items/charger-3.png', // [Freepik] charger-usb-cable-type-c-white-isolated-background
      ),
      Accessory(
        itemTypeId: 'charger-4',
        name: '8핀 충전기',
        description: '20W 고속 충전기',
        price: 1000,
        category: AccessoryCategory.charger,
        stock: 5,
        imageUrl: 'assets/images/items/charger-4.png', // GettyImages-1479104893
      ),

      // 케이블
      Accessory(
        itemTypeId: 'cable-1',
        name: 'HDMI 케이블',
        description: '4K 지원 HDMI 2.0',
        price: 1000,
        category: AccessoryCategory.cable,
        stock: 6,
        imageUrl: 'assets/images/items/cable-1.png', // GettyImages-478051415
      ),
      Accessory(
        itemTypeId: 'cable-2',
        name: 'DP 케이블',
        description: '4K 지원 DisplayPort 1.4',
        price: 1000,
        category: AccessoryCategory.cable,
        stock: 4,
        imageUrl: 'assets/images/items/cable-2.png', // canva
      ),
      Accessory(
        itemTypeId: 'cable-3',
        name: 'C to C 케이블',
        description: '100W PD 지원',
        price: 500,
        category: AccessoryCategory.cable,
        stock: 8,
        imageUrl: 'assets/images/items/cable-3.png', // canva
      ),
      Accessory(
        itemTypeId: 'cable-4',
        name: 'C to A 케이블',
        description: '고속 데이터 전송',
        price: 500,
        category: AccessoryCategory.cable,
        stock: 0,
        imageUrl:
            'assets/images/items/cable-4.png', // [Freepik] usb-cable-type-c-white-isolated-background
      ),

      // 독
      Accessory(
        itemTypeId: 'dock-1',
        name: 'SD 카드 독 (Type-C)',
        description: 'SD/MicroSD 지원',
        price: 1500,
        category: AccessoryCategory.dock,
        stock: 3,
        imageUrl: 'assets/images/items/dock-1.png', // canva
      ),
      Accessory(
        itemTypeId: 'dock-2',
        name: 'USB 독 (Type-C)',
        description: 'USB 3.0 4포트',
        price: 1500,
        category: AccessoryCategory.dock,
        stock: 4,
        imageUrl:
            'assets/images/items/dock-2.png', // [Freepik] usb-hubs-digital-device
      ),
      Accessory(
        itemTypeId: 'dock-3',
        name: '멀티 독 (Type-C)',
        description: 'HDMI, USB, SD 카드 지원',
        price: 2000,
        category: AccessoryCategory.dock,
        stock: 0,
        imageUrl:
            'assets/images/items/dock-3.png', // [pexels] pexels-rann-vijay-677553-7742582
      ),

      // 보조배터리
      Accessory(
        itemTypeId: 'powerbank-1',
        name: '노트북용 보조배터리',
        description: '30000mAh, 100W PD',
        price: 3000,
        category: AccessoryCategory.powerBank,
        stock: 2,
        imageUrl:
            'assets/images/items/powerbank-1.png', // [Freepik] png-power-bank-isolated-white-background
      ),
      Accessory(
        itemTypeId: 'powerbank-2',
        name: '휴대폰용 보조배터리',
        description: '10000mAh, 25W',
        price: 1500,
        category: AccessoryCategory.powerBank,
        stock: 0,
        imageUrl:
            'assets/images/items/powerbank-2.png', // [Freepik] png-power-bank-isolated-white-background
      ),

      // 기타
      Accessory(
        itemTypeId: 'etc-1',
        name: '발표용 리모콘',
        description: '레이저 포인터 내장',
        price: 1000,
        category: AccessoryCategory.etc,
        stock: 0,
        imageUrl: 'assets/images/items/etc-1.png', // canva
      ),
    ];
  }

  Future<Accessory> get(String id) async {
    final accessories = await getAll();
    return accessories.firstWhere((a) => a.itemTypeId == id);
  }
}
