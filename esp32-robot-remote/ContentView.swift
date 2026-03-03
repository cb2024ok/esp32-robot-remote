//
//  ContentView.swift
//  esp32-robot-remote
//
//  Created by baby Enjhon on 2/24/26.
//

import SwiftUI

enum BleCommand {
    case Scan                       // 스캔
    case Connect(String)            // BLE 연결
    case SendMotorAngles([Int])     // 전송명령
    case Stop                       // 일시중지
    case Home                       // 홈으로 이동
}


struct ContentView: View {
    
    @State private var bleManager: BLEManager = .init()
    @State private var isConnected: Bool = true
    @State private var selectedMotor: Int = 0
    
        
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading) {
                
                if bleManager.esp32Peripheral == nil {
                 ProgressView("ESP장치 찾는중 입니다....")
                 .progressViewStyle(.circular)
                 } else if isConnected {
                 
                List {
                    Section("ESP32-Robot_Client") {
                        remoteClient
                    }
                    
                    Button("연결해제") {
                        bleManager.disconnectFromPeripheral()
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                } else {
                    List(bleManager.peripherals) { peripheral in
                                device(peripheral)
                    }
                    .refreshable {
                            bleManager.refreshDevices()
                    }
                }
            }
            .navigationBarTitle("ESP32 Robot Remote")
            //remoteClient
                
        }
    }
    
    private var remoteClient: some View {
        return VStack(spacing: 20) {
            Text(
                bleManager.isConnected ? "ESP32 Connected OK" : "Connecting..."
                //isConnected ? "ESP32 Connected OK" : "Connecting..."
            )
                .font(.headline)
                .foregroundColor(isConnected ? .green : .red)
            
            HStack {
                ForEach(0..<6) { index in
                    Button("#\(index)") {
                        selectedMotor = index
                    }
                    .padding(8)
                    .background(selectedMotor == index ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
        }
        
        // 간단 조이스틱 대신 슬라이더 예시 (나중에 Gesture로 업그레이드)
        VStack {
            Text("Motor #\(selectedMotor): \(bleManager.motorAngles[selectedMotor])°")
            Slider(value: Binding(
                get: { Double(bleManager.motorAngles[selectedMotor]) },
                set: { newValue in
                    bleManager.motorAngles[selectedMotor] = Int(newValue)
                    bleManager.sendMotorAngles()  // 실시간 전송
                }
            ), in: 0...180, step: 1)
            .padding()
        }
        
         Button("STOP") {
            bleManager.motorAngles = Array(repeating: 90, count: 6)  // 홈 포지션
            bleManager.sendMotorAngles()
        }
        .font(.title)
        .padding()
        .background(Color.red)
        .foregroundColor(.white)
        .clipShape(Circle())
        .padding()
    }
    
    private func device(_ peripheral: Peripheral) -> some View {
           VStack(alignment: .leading) {
               HStack {
                   Text(peripheral.name)
                   Spacer()
                   Button(action: {
                       bleManager.connectPeripheral(peripheral: peripheral)
                   }) {
                       Text("Connect")
                   }
                   .buttonStyle(.borderedProminent)
               }
               
               Divider()
               
               VStack(alignment: .leading) {
                   Group {
                       Text("""
                                 Device UUID:
                                 \(peripheral.id.uuidString)
                                 """)
                       .padding([.bottom], 10)
                                          
                                          if let adsServiceUUIDs = peripheral.advertisementServiceUUIDs {
                                              Text("Advertisement Service UUIDs:")
                                              ForEach(adsServiceUUIDs, id: \.self) { uuid in
                                                  Text(uuid)
                                              }
                                          }
                                          
                                          HStack {
                                              Image(systemName: "chart.bar.fill")
                                              Text("\(peripheral.rssi) dBm")
                                          }
                                          .padding([.top], 10)
                                      }
                                      .font(.footnote)
                                  }
                    }
            }
}

#Preview {
    ContentView()
}


