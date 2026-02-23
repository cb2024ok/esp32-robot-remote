🍎 ESP32 Robot Remote (Swift + Rust)
ESP32-P4와 Swift를 연동하여 정밀한 로봇 팔 제어를 구현하는 프로젝트입니다. [cite: 2026-01-28, 2026-01-24]
궁극적인 목표는 가정용 사과 깎기 로봇을 개발하여 실생활에 도움을 주는 것입니다. [cite: 2026-01-24, 2026-02-06]

🚀 프로젝트 철학
Stability over Speed (속도보다 안정성): 급격한 움직임보다는 부드럽고 안전한 정밀 제어를 지향합니다. [cite: 2026-02-13]

Win-Win & Accessibility: 모두가 소외되지 않고 기술의 혜택을 누릴 수 있는 따뜻한 로봇 공학을 추구합니다. [cite: 2026-02-06]

🛠 Tech Stack
Client (Remote): Swift (SwiftUI) [cite: 2026-02-24]

Controller: Rust (ESP32-P4 / ESP-IDF) [cite: 2026-02-02, 2026-01-28]

Communication: BLE (Bluetooth Low Energy) [cite: 2026-02-24]

Actuators: RDS3225 Digital Servo x2 (High Torque) [cite: 2026-02-23]

📱 Key Features (v1.0.0 Prototype)
Slider-based Control: 슬라이더를 이용한 직관적인 서보 각도(0
∘
 ∼180
∘
 ) 조절 [cite: 2026-02-24]

Multi-Channel Selector: 최대 6개의 서보 모터 개별 선택 및 제어 가능 [cite: 2026-02-24]

Emergency STOP: 위급 상황 시 즉각적인 홈 포지션 복귀 및 정지 기능 [cite: 2026-02-24]

Real-time Status: BLE 연결 상태를 시각적으로 즉시 확인 가능 [cite: 2026-02-24]

📅 Roadmap
[x] Swift UI 프로토타입 디자인 (Slider 기반) [cite: 2026-02-24]

[ ] 하드웨어 조립 (RDS3225 + ESP32-P4) [cite: 2026-02-23]

[ ] Rust 기반 BLE 수신 로직 구현 [cite: 2026-02-02]

[ ] 사과 깎기 알고리즘 및 역기구학 적용 [cite: 2026-01-24]

