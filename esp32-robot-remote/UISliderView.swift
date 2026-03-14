//
//  UISliderView.swift
//  esp32-robot-remote
//
//  Created by baby Enjhon on 3/14/26.
//

import SwiftUI

struct UISliderView: UIViewRepresentable {
    @Binding var value: Double
    var minValue: Double
    var maxValue: Double
    
    var thumbColor: UIColor = .white
    var minTrackColor: UIColor? = nil
    var maxTrackColor: UIColor? = nil
    
    // 추가된 부분: 편집 상태 변화를 알리는 클로저
    var onEditingChanged: (Bool) -> Void = { _ in }

    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.minimumValue = Float(minValue)
        slider.maximumValue = Float(maxValue)
        
        slider.thumbTintColor = thumbColor
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        
        slider.value = Float(value)
        
        // 1. 값이 변할 때 (실시간 업데이트)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        
        // 2. 터치 시작 (Editing 시작)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.editingDidBegin(_:)), for: .touchDown)
        
        // 3. 터치 종료 (Editing 끝)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.editingDidEnd(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.value = Float(value)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value, onEditingChanged: onEditingChanged)
    }

    class Coordinator: NSObject {
        var value: Binding<Double>
        var onEditingChanged: (Bool) -> Void

        init(value: Binding<Double>, onEditingChanged: @escaping (Bool) -> Void) {
            self.value = value
            self.onEditingChanged = onEditingChanged
        }

        @objc func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = Double(sender.value)
        }

        @objc func editingDidBegin(_ sender: UISlider) {
            onEditingChanged(true) // 사용자가 슬라이더를 잡았을 때
        }

        @objc func editingDidEnd(_ sender: UISlider) {
            // --- 햅틱 피드백 추가 ---
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            // -----------------------
                        
            onEditingChanged(false)
            print("최종 목적지 도착: SU-57 패킷 및 햅틱 전송 완료!")
        }
    }
}
#Preview {
    // Provide a constant binding for 'value' and example values for 'minValue' and 'maxValue'.
    UISliderView(value: .constant(0.5), minValue: 0.0, maxValue: 1.0)
}
