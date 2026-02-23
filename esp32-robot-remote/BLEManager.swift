//
//  BLEManager.swift
//  esp32-robot-remote
//
//  Created by baby Enjhon on 2/24/26.
//

import SwiftUI
import CoreBluetooth

@Observable
class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager?
    var targetPeripheral: CBPeripheral?
    var motorCharacteristic: CBCharacteristic?
    
    var isConnected = false
    var motorAngles: [Int] = Array(repeating: 90, count: 6)  // #0~#5 각도
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // 스캔 시작 (서비스 UUID로 필터링 추천)
            central.scanForPeripherals(withServices: [CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "BabyRobotArm" {  // ESP32 BLE 이름
            targetPeripheral = peripheral
            central.connect(peripheral)
            central.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for char in characteristics {
            if char.uuid == CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
                motorCharacteristic = char
                print("Found motor control characteristic!")
            }
        }
    }
    
    // 각도 전송 함수 (앱에서 호출)
    func sendMotorAngles() {
        guard let char = motorCharacteristic, let peripheral = targetPeripheral else { return }
        
        var data = Data()
        for (index, angle) in motorAngles.enumerated() {
            data.append(UInt8(index))       // 모터 번호
            data.append(UInt8(angle))       // 각도 (0~180)
        }
        
        peripheral.writeValue(data, for: char, type: .withResponse)
        print("Sent angles: \(motorAngles)")
    }
}
