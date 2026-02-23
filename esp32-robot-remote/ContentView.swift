//
//  ContentView.swift
//  esp32-robot-remote
//
//  Created by baby Enjhon on 2/24/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var bleManager: BLEManager = .init()
    @State private var isConnected: Bool = true
    @State private var selectedMotor: Int = 0
    
        
    var body: some View {
        VStack(spacing: 20) {
            Text(isConnected ? "ESP32 Connected OK" : "Connecting...")
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
}

#Preview {
    ContentView()
}
