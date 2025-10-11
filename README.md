# 🔧 RV32I RISC-V Processor

## 🔍 Project Overview

> 이 프로젝트는 **SystemVerilog HDL기반 RV32I RISC-V 프로세서** 설계 프로젝트입니다. 32비트 RISC-V ISA의 기본 명령어들을 지원하며, 파이프라인 없이 single cycle 구현으로 설계되었습니다.

## 🎛️ 핵심 설계 : RV32I CPU Core Architecture
> **SystemVerilog HDL을 사용하여 설계한 RV32I RISC-V 프로세서**의 전체 구현

- **Complete CPU Core**: datapath, control unit을 포함한 완전한 CPU Core 구현
- **Harvard Architecture**: 명령어 메모리와 데이터 메모리 분리
- **Modular Design**: 재사용 가능한 모듈식 설계 구조
- **ISA Support**: RV32I 기본 명령어 세트 완전 구현

| **Type** | **Instruction** | **Description** | **Operation** |
|----------|-----------------|-----------------|---------------|
| **R-Type** | ADD | Add | rd = rs1 + rs2 |
| | SUB | Subtract | rd = rs1 - rs2 |
| | SLL | Shift Left Logical | rd = rs1 << rs2[4:0] |
| | SLT | Set Less Than | rd = (rs1 < rs2) ? 1 : 0 |
| | SLTU | Set Less Than Unsigned | rd = (rs1 < rs2) ? 1 : 0 (unsigned) |
| | XOR | Exclusive OR | rd = rs1 ^ rs2 |
| | SRL | Shift Right Logical | rd = rs1 >> rs2[4:0] |
| | SRA | Shift Right Arithmetic | rd = rs1 >>> rs2[4:0] |
| | OR | Bitwise OR | rd = rs1 \| rs2 |
| | AND | Bitwise AND | rd = rs1 & rs2 |
| **I-Type** | ADDI | Add Immediate | rd = rs1 + imm |
| | SLTI | Set Less Than Immediate | rd = (rs1 < imm) ? 1 : 0 |
| | SLTIU | Set Less Than Immediate Unsigned | rd = (rs1 < imm) ? 1 : 0 (unsigned) |
| | XORI | XOR Immediate | rd = rs1 ^ imm |
| | ORI | OR Immediate | rd = rs1 \| imm |
| | ANDI | AND Immediate | rd = rs1 & imm |
| | SLLI | Shift Left Logical Immediate | rd = rs1 << imm[4:0] |
| | SRLI | Shift Right Logical Immediate | rd = rs1 >> imm[4:0] |
| | SRAI | Shift Right Arithmetic Immediate | rd = rs1 >>> imm[4:0] |
| | JALR | Jump and Link Register | rd = PC + 4, PC = (rs1 + imm) & ~1 |
| **I-Type Load** | LW | Load Word | rd = mem[rs1 + imm][31:0] |
| | LH | Load Halfword | rd = sign_ext(mem[rs1 + imm][15:0]) |
| | LB | Load Byte | rd = sign_ext(mem[rs1 + imm][7:0]) |
| | LHU | Load Halfword Unsigned | rd = zero_ext(mem[rs1 + imm][15:0]) |
| | LBU | Load Byte Unsigned | rd = zero_ext(mem[rs1 + imm][7:0]) |
| **S-Type** | SW | Store Word | mem[rs1 + imm][31:0] = rs2 |
| | SH | Store Halfword | mem[rs1 + imm][15:0] = rs2[15:0] |
| | SB | Store Byte | mem[rs1 + imm][7:0] = rs2[7:0] |
| **B-Type** | BEQ | Branch if Equal | if (rs1 == rs2) PC = PC + imm |
| | BNE | Branch if Not Equal | if (rs1 != rs2) PC = PC + imm |
| | BLT | Branch if Less Than | if (rs1 < rs2) PC = PC + imm |
| | BGE | Branch if Greater or Equal | if (rs1 >= rs2) PC = PC + imm |
| | BLTU | Branch if Less Than Unsigned | if (rs1 < rs2) PC = PC + imm (unsigned) |
| | BGEU | Branch if Greater or Equal Unsigned | if (rs1 >= rs2) PC = PC + imm (unsigned) |
| **U-Type** | LUI | Load Upper Immediate | rd = imm << 12 |
| | AUIPC | Add Upper Immediate to PC | rd = PC + (imm << 12) |
| **J-Type** | JAL | Jump and Link | rd = PC + 4, PC = PC + imm |




## 🏗️ System Architecture
 - **Block Diagram**
   <img width="8560" height="6316" alt="image" src="https://github.com/user-attachments/assets/fdbcecdc-4f8f-416a-a736-155c70e7c715" />



### 1. CPU Core Components
- **Datapath**: 데이터 흐름 및 연산 경로 제어
- **Control Unit**: 명령어 디코딩 및 제어 신호 생성
- **ALU**: 32비트 산술 논리 연산 장치
- **Register File**: 32개의 32비트 범용 레지스터 (x0-x31)
- **Program Counter**: 명령어 주소 관리
- **Immediate Extension**: 즉시값 부호 확장 및 형태 변환

### 2. Memory System Components
- **Instruction Memory**: 64개 명령어 저장 가능한 ROM
- **Data Memory**: 128바이트 데이터 저장 가능한 RAM
- **Address Generation**: 메모리 주소 계산 및 정렬

### 3. Supporting Modules
- **Multiplexers**: 2:1, 4:1, 5:1 데이터 선택기
- **PC Adder**: 프로그램 카운터 증가 및 분기 주소 계산
- **Adder**: 범용 가산기 (점프 주소 계산용)
- **Register**: 범용 32비트 레지스터 구현

## 🚀 Key Features

### 📊 Instruction Set Architecture
- **32-bit RISC-V RV32I**: 기본 정수 명령어 세트 완전 지원
- **6 Instruction Types**: R, I, S, B, U, J 타입 명령어 완전 구현
- **32 General-Purpose Registers**: x0(zero) ~ x31 레지스터
- **Word-Aligned Memory Access**: 4바이트 정렬 메모리 접근

### 🔧 Processor Features
- **Single-Cycle Implementation**: 명령어당 1 클럭 사이클 실행
- **Harvard Architecture**: 명령어/데이터 메모리 분리
- **Jump and Link Support**: JAL/JALR 명령어를 통한 함수 호출 지원
- **Branch Prediction**: 정적 분기 예측 (taken/not-taken)
- **Immediate Support**: 다양한 즉시값 형태 지원

### 💾 Memory System
- **Instruction Memory**: 64 × 32-bit ROM
- **Data Memory**: 128 × 8-bit RAM (바이트 주소 지정)
- **Little Endian**: 리틀 엔디안 바이트 순서
- **Variable Width Access**: 8/16/32비트 메모리 접근 지원

### 🎯 Control & Datapath
- **Unified Control Unit**: 모든 명령어 타입에 대한 통합 제어
- **Advanced Multiplexing**: PC 소스 및 레지스터 쓰기 데이터 선택을 위한 5:1 MUX
- **Sign Extension**: 즉시값 부호 확장 처리
- **Branch Resolution**: ALU 기반 분기 조건 판별
- **Jump Support**: JAL/JALR을 위한 전용 주소 계산 경로

## 📁 Project Structure

```
RV32I_RISC_V/
├── 🔧 sources_1/new/           # SystemVerilog 소스 파일
│   ├── RV32I_TOP.sv           # 최상위 프로세서 모듈
│   ├── cpu_core.sv            # CPU 코어 (제어+데이터패스)
│   ├── datapath.sv            # 데이터패스 구현
│   ├── control_unit.sv        # 제어 유닛
│   ├── ALU.sv                 # 산술 논리 연산 장치
│   ├── register_file.sv       # 32개 레지스터 파일
│   ├── instruction_memory.sv  # 명령어 메모리 (ROM)
│   ├── data_memory.sv         # 데이터 메모리 (RAM)
│   ├── program_counter.sv     # 프로그램 카운터
│   ├── extend.sv              # 즉시값 확장 모듈
│   ├── mux_2x1.sv            # 2:1 멀티플렉서
│   ├── mux_4x1.sv            # 4:1 멀티플렉서
│   ├── mux_5x1.sv            # 5:1 멀티플렉서 (다용도)
│   ├── pc_adder.sv           # PC 가산기
│   ├── adder.sv              # 범용 가산기
│   ├── register.sv           # 기본 레지스터 모듈
│   └── define.sv             # 명령어 정의 상수
└── 🧪 sim_1/new/              # 시뮬레이션 파일
    └── tb.sv                  # 테스트벤치
```

## 🛠️ Installation and Setup

### 📋 Prerequisites
- **Hardware**: FPGA 개발 보드 (선택사항)
- **Software**: 
  - Xilinx Vivado 2018.3 이상
  - ModelSim/QuestaSim (시뮬레이션용)
- **Knowledge**: 
  - SystemVerilog HDL
  - RISC-V ISA 기본 지식
  - 디지털 회로 설계

### 🔧 Project Setup
1. **프로젝트 생성**: Vivado에서 새 프로젝트 생성
2. **소스 추가**: `sources_1/new/` 폴더의 모든 `.sv` 파일 추가
3. **최상위 설정**: `RV32I_TOP.sv`를 최상위 모듈로 설정
4. **시뮬레이션 설정**: `tb.sv`를 시뮬레이션 소스로 추가

## 🖥️ Usage

### 📋 Basic Operation Workflow

#### 1. **⚙️ Simulation Setup**
   - 테스트벤치 파일 `tb.sv` 확인
   - 클럭 및 리셋 신호 설정 (10ns 주기)
   - 시뮬레이션 시간 설정 (30 클럭 사이클)

#### 2. **📝 Test Program Configuration**
   - `instruction_memory.sv`에서 테스트 명령어 수정
   - 현재 구성: J-type 명령어 테스트 (JAL/JALR)
   - 레지스터 초기값 설정 (`register_file.sv`)

#### 3. **🔍 Behavioral Simulation**
   - Vivado에서 시뮬레이션 실행
   - 파형 분석을 통한 동작 확인
   - 레지스터 값 및 메모리 상태 모니터링

#### 4. **🎯 Synthesis & Implementation**
   - RTL 합성을 통한 하드웨어 생성
   - 타이밍 제약 설정
   - FPGA 비트스트림 생성 (선택사항)

### 🎯 Key Parameters
- **Clock Frequency**: 사용자 정의 (기본 100MHz 권장)
- **Register Count**: 32개 (x0-x31)
- **Memory Size**: 
  - 명령어 메모리: 64 words (256 bytes)
  - 데이터 메모리: 128 bytes
- **Data Width**: 32-bit 데이터 경로

## 📊 Instruction Format & Encoding

### 🔤 Supported Instruction Types

#### R-Type (Register)
```
| funct7 |  rs2  |  rs1  |funct3|  rd   | opcode |
|31    25|24   20|19   15|14  12|11    7|6      0|
```
- **Examples**: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND

#### I-Type (Immediate)
```
|    imm[11:0]    |  rs1  |funct3|  rd   | opcode |
|31            20|19   15|14  12|11    7|6      0|
```
- **Examples**: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
- **Load Instructions**: LW, LH, LB, LBU, LHU

#### S-Type (Store)
```
| imm[11:5] |  rs2  |  rs1  |funct3|imm[4:0]| opcode |
|31       25|24   20|19   15|14  12|11     7|6      0|
```
- **Examples**: SW, SH, SB

#### B-Type (Branch)
```
|imm[12|10:5]|  rs2  |  rs1  |funct3|imm[4:1|11]| opcode |
|31        25|24   20|19   15|14  12|11        7|6      0|
```
- **Examples**: BEQ, BNE, BLT, BGE, BLTU, BGEU

#### U-Type (Upper Immediate)
```
|        imm[31:12]           |  rd   | opcode |
|31                        12|11    7|6      0|
```
- **Examples**: LUI, AUIPC

#### J-Type (Jump)
```
|     imm[20|10:1|11|19:12]      |  rd   | opcode |
|31                           12|11    7|6      0|
```
- **JAL**: Jump and Link
- **JALR**: Jump and Link Register (I-type format)

## 🔧 Configuration

### ⚙️ Processor Parameters
- **⏰ Clock Period**: 10ns (기본 설정)
- **📊 Data Width**: 32-bit
- **💾 Address Width**: 32-bit
- **🎯 Reset Type**: 동기식 리셋

### 🔌 Memory Configuration
- **📡 Instruction Memory**: Word-aligned 접근
- **⚡ Data Memory**: Byte-addressable
- **📝 Endianness**: Little Endian
- **🔄 Access Types**: 8/16/32-bit 지원

### 🎛️ Control Unit Configuration
- **⚡ ALU Control**: 4-bit 제어 신호
- **📈 MUX Selection**: 다중 데이터 경로 선택
- **🔄 Write Enable**: 레지스터/메모리 쓰기 제어
- **🎯 Branch Control**: 분기 조건 판별

## 🚨 Design Notes & Limitations

### ⚠️ Current Limitations
- **No Pipeline**: 단일 사이클 구현 (성능 제한)
- **No Cache**: 직접 메모리 접근만 지원
- **No Interrupts**: 인터럽트 처리 미구현
- **Limited Memory**: 작은 메모리 크기 (교육용)

### 🔧 Future Enhancements
- **Pipeline Implementation**: 5단계 파이프라인 추가
- **Cache System**: L1 명령어/데이터 캐시
- **Exception Handling**: 예외 및 인터럽트 처리
- **Floating Point**: RV32F 부동소수점 확장

## 📈 Performance Specifications

- **⚡ Clock Frequency**: 최대 100MHz (FPGA 종속)
- **📊 Instructions/Cycle**: 1 IPC (단일 사이클)
- **🎚️ Instruction Types**: 6가지 형태 완전 지원 (R, I, S, B, U, J)
- **🗺️ Execution Time**: 명령어당 1 클럭 사이클
- **📊 Memory Bandwidth**: 32-bit/cycle (Load/Store)
- **🔗 Jump Performance**: 단일 사이클 점프 실행

## 🧪 Testing & Verification

### 📋 Test Methodology
- **Unit Testing**: 각 모듈별 개별 테스트
- **Integration Testing**: 전체 시스템 통합 테스트
- **ISA Compliance**: RISC-V 명령어 집합 준수 확인

### 🔍 Current Test Cases
- **Jump Operations**: JAL/JALR 명령어 테스트
- **Function Call Simulation**: 점프 및 링크 동작 검증
- **ALU Operations**: 산술/논리 연산 검증
- **Branch Instructions**: 분기 동작 확인
- **Register File**: 레지스터 읽기/쓰기 테스트

## 🤝 Contributing

이 프로젝트는 교육 목적으로 설계되었으며, RISC-V 아키텍처 학습을 위한 참고 구현입니다. 개선사항이나 버그 수정은 언제든 환영합니다.

### 📝 Development Guidelines
- SystemVerilog 코딩 스타일 준수
- 모듈식 설계 원칙 유지
- 충분한 주석 및 문서화
- 시뮬레이션 검증 필수

---

**Note**: 이 구현은 RV32I 기본 명령어 세트만을 지원하며, 교육 및 학습 목적으로 최적화되어 있습니다. 상용 제품에 사용하기 전에 추가적인 검증과 최적화가 필요합니다.
