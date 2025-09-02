# 🌐 RISC-V_CPU

## 🔍 Project Overview

> 

## 🎛️ 핵심 설계 기여 : Custom Pulser System
저는 본 프로젝트에서 **Verilog HDL을 사용하여 설계한 디지털 펄스 생성 시스템**의 구현을 담당했습니다:

- **FSM Design**: 안정적인 펄스 시퀀싱을 위한 FSM 구현
   (drawio FSM chart 그림 첨부) 

## 🏗️ System Architecture

### 1. Hardware Components
- **FPGA Board**: Opal Kelly XEM7320 (Xilinx Artix-7 기반)

### 2. Software Components
- **FPGA Gateware**: Verilog 기반 하드웨어 제어 및 데이터 수집

## 🚀 Key Features


### 📡 Data Acquisition
- **High-Speed Sampling**: 최대 125 MSPS 데이터 수집

### 🔬 Signal Processing
- **Bandpass Filtering**: 4-7 MHz 주파수 대역 필터링

### 🤖 Automated Scanning
- ** 2D Grid Scanning**: 프로그래머블 X-Y 축 스캐닝 패턴

### 🧠 Machine Learning
- **CNN Architecture**: 패턴 인식을 위한 컨볼루션 신경망

## 📁 Project Structure

```
NDT_diagnosis_system/
├── 🔧 gateware/                    # FPGA Verilog 코드
│   ├── xem7320_adc.v              # FPGA 최상위 모듈 (Pulser 제어 포함)
│   ├── syzygy-adc-top.v           # ADC 제어 모듈
│   ├── syzygy_dac_spi_module.v    # DAC SPI 인터페이스
│   ├── ip/                        # Xilinx IP 코어(FIFO, IBUFDS
│   ├── oklib/                     # Opal Kelly 라이브러리
│   └── testbench/                 # 시뮬레이션 파일
├── 🐍 python/                      # Python 애플리케이션
│   ├── ULTRAprojectDEMO.py        # 메인 GUI 애플리케이션
│   ├── ULTRAprojectDEMO.ui        # Qt Designer UI 파일
│   ├── ok.py                      # Opal Kelly Python API
│   ├── requirements.txt           # Python 의존성
│   └── datafile/                  # CSV 데이터 저장소
├── vivado_project_bit/         # Vivado 합성 프로젝트
├── vivado_project_sim/         # Vivado 시뮬레이션 프로젝트
└── SZG-ADC-LTC2264-12.gen/    # 생성된 IP 파일
```

## 🛠️ Installation and Setup

### 📋 Prerequisites
- **Hardware**: Opal Kelly XEM7320 FPGA 보드 + SYZYGY ADC 모듈
- **Software**: 
  - Xilinx Vivado (FPGA 개발용)
  - Python 3.7+
  - Arduino IDE (스캐닝 컨트롤러용)
- **Main Python Packages**:

### 🔧 Hardware Setup
1. **연결**: SYZYGY ADC 모듈을 XEM7320 보드에 연결
2. **Bitfile 로드**: FPGA에 `xem7320_adc.bit` 로드

## 🖥️ Usage

### 📋 Basic Operation Workflow

#### 1. **System Initialization**
   - FPGA bitfile 로드
   - FIFO 크기 및 샘플링 파라미터 구성
   - 버스트 카운트 및 주파수 파라미터 설정

#### 2. **⚙️ Pulser Configuration (핵심 기능)**
   - **펄스 모드 선택**: Transmission/Reflection 모드
   - **PWS 설정**: 펄스 폭 제어
   - **POS/NEG 제어**: 양극/음극 펄스 타이밍
   - **주파수 설정**: 사용자 정의 펄스 주파수

#### 3. **🗺️ Scanning Configuration**
   - X-Y 축 그리드 차원 설정
   - 데이터 파일 저장 디렉토리 선택

#### 4. **📊 Data Acquisition**
   - 자동화된 스캐닝 프로세스 시작
   - 실시간 신호 시각화
   - 스캔 포인트별 자동 CSV 파일 생성

#### 5. **🧠 Data Analysis**
   - 수집된 데이터 훈련용 로드
   - 패턴 인식을 위한 CNN 모델 훈련
   - 실시간 추론 및 진단 수행

### 🎯 Key Parameters
- **FIFO Size**: 2044 샘플 (구성 가능)
- **Sampling Rate**: 시스템 클록에 의해 결정

## 📊 Data Format

### 📄 CSV Output Structure
각 스캔 포인트는 다음 구조의 CSV 파일을 생성:
- **Column 1**: 시간축 (μs)

### 🔄 Signal Processing Chain
1. **📡 Raw ADC Data** → 12-bit 부호있는 정수
2. **⚡ Voltage Conversion** → ±1.25V 범위 정규화
3. **🎚️ Bandpass Filtering** → 4-7 MHz 주파수 선택
4. **📊 FFT Analysis** → 주파수 도메인 표현
5. **🌈 Intensity Mapping** → 2D 시각화 데이터

## 🔧 Configuration

### ⚙️ FPGA Parameters
- **⏰ Clock Frequency**: 125 MHz (시스템 클록 기반)
- **📊 ADC Resolution**: 12-bit
- **💾 Sample Buffer**: 구성 가능한 FIFO 깊이
- **🎯 Trigger Mode**: 소프트웨어 제어 수집

### 🔌 Arduino Communication
- **📡 Serial Port**: COM3 (구성 가능)
- **⚡ Baud Rate**: 9600
- **📝 Protocol**: 단순 ASCII 명령 인터페이스

### 🎛️ Pulser System Configuration (핵심 설계)
- **⚡ PWS Control**: 펄스 폭 선택 신호
- **📈 POS/NEG Timing**: 양극/음극 펄스 타이밍 제어
- **🔄 Burst Count**: 프로그래머블 버스트 시퀀스

## 🚨 Troubleshooting

## 📈 Performance Specifications

- **⚡ Maximum Sampling Rate**: 125 MSPS
- **📊 ADC Resolution**: 12-bit (4096 레벨)

## 🤝 Contributing

---
