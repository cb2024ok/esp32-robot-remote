//
//  ContentView.swift
//  esp32-robot-remote
//
//  Created by baby Enjhon on 2/24/26.
//

import SwiftUI
import Combine

enum BleCommand {
    case Scan                       // 스캔
    case Connect(String)            // BLE 연결
    case SendMotorAngles([Int])     // 전송명령
    case Stop                       // 일시중지
    case Home                       // 홈으로 이동
}


struct ContentView: View {
    
    //@State private var bleManager: BLEManager = .init()
    @ObservedObject var bleManager = BLEManager()
    @State private var isConnected: Bool = true
    //@State private var selectedMotor: Int = 0
    
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var cancellable: AnyCancellable?
    
    // 모터 슬라이드 상태관리
    @State private var motorXactive: Bool = true
    @State private var motorYactive: Bool = true
    
        
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading) {
                
                if bleManager.peripherals.isEmpty {
                 ProgressView("ESP장치 찾는중 입니다....")
                 .progressViewStyle(.circular)
                } else if bleManager.isConnected {
                 
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
                        bleManager.selectedMotor = index // BLE 모터변경...
                    }
                    .id(index)  //  버튼 ID에 따른 슬라이드 컨트롤을 위한 체크..
                    .padding(8)
                    .background(
                        bleManager.selectedMotor == index ? Color.blue : Color.gray
                            .opacity(0.3)
                    )
                    .onTapGesture {
                        bleManager.selectedMotor = index // BLE 모터변경...
                        print("변경된 Motor 번호: \(index)")
                   
                        switch index {
                        case 0:
                            motorXactive = true
                            motorYactive = false
                        case 1:
                            motorYactive = true
                            motorXactive = false
                        case 2:
                            motorYactive = true
                            motorXactive = false
                        case 3:
                            motorYactive = true
                            motorXactive = false
                        case 4:
                            motorXactive = true
                            motorYactive = false
                        case 5:
                            motorXactive = true
                            motorYactive = false
                        default:
                            motorXactive = true
                            motorYactive = true
                        }
                        
                   
                    }
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
            
            
            // 간단 조이스틱 대신 슬라이더 예시 (나중에 Gesture로 업그레이드)
                VStack {
                    Text(
                        "Motor #\(bleManager.selectedMotor): \(bleManager.motorXAngles[bleManager.selectedMotor])°"
                    )
                    Slider(value: Binding(get: {
                        Double(bleManager.motorXAngles[bleManager.selectedMotor])
                        },
                        set: { newValue in
                            bleManager
                                .motorXAngles[bleManager.selectedMotor] = Int(
                                    newValue
                                )
                        }
                    ),in:
                            0...180,
                           step: 1,
                           onEditingChanged: { isEditing in
                            if !isEditing {
                                bleManager.sendMotorAngles(for: bleManager.selectedMotor) // 실시간 전송
                                print("최종 목적지 도착: 패킷 전송 완료 SU-57!")
                            }
                    })
                    .padding()
                }
                .opacity(motorXactive ? 1.0 : 0.0)
                .padding(10)
                
                VStack(alignment: .leading) {
                    Text(
                        "Motor #\(bleManager.selectedMotor): \(bleManager.motorYAngles[bleManager.selectedMotor])°"
                    )
                    Slider(
                        value: Binding(
                            get: {
                                Double(bleManager.motorYAngles[bleManager.selectedMotor])
                            },
                            set: { newValue in
                            bleManager
                                .motorYAngles[bleManager.selectedMotor] = Int(
                                    newValue
                                )
                            bleManager.selectedMotor = Int(newValue) // 선택한 모터번호
                        }
                    ),
                        in: 0...180,
                        step: 1,
                        onEditingChanged: { isEditing in
                        if !isEditing {
                            bleManager.sendMotorAngles(for: bleManager.selectedMotor) // 실시간 전송
                            print("최종 목적지 도착: 패킷 전송 완료 SU-57!")
                        }
                    })
                    .rotationEffect(.degrees(-90))
                    .padding()
                }
                .opacity(motorYactive ? 1.0 : 0.0)
                .padding(50)
                
                Button("HOME") {
                    bleManager.motorXAngles = Array(repeating: 90, count: 6)  // 홈 포지션
                    bleManager.sendMotorAngles(for: bleManager.selectedMotor)
                }
            .font(.title)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Circle())
            .padding()
        }
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

