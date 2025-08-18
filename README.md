# fpga-tetris-basys3

# Tetris on FPGA – Basys 3 Board

A fully playable version of the classic Tetris game implemented in **Verilog/SystemVerilog** on the **Digilent Basys 3 FPGA board** using **VGA output** and **7-segment display scorekeeping**. This project demonstrates fundamental digital design, hardware control, and real-time display integration.

---

## 🔧 Features

- 🎮 Tetris game engine written in SystemVerilog
- 🖥️ VGA controller for real-time video display at 640x480 resolution
- 🔲 Grid logic and block collision detection
- 🔁 Clock divider for timing control
- 🧠 FSM-based game control logic
- ✅ Score is calculated in real-time as rows are cleared
- 🔢 **Live score is shown on the board’s 4-digit 7-segment display**
- 🎯 Modular and testable design using simulation and behavioral testing

---

## 🧠 Learning Objectives
> ✅ **Goal**: Demonstrate complete digital system design workflow — from architecture to synthesis and deployment — using an FPGA development board.

**Skills Developed:**

- RTL design using **SystemVerilog**
- VGA signal generation and timing
- FSM and datapath co-design
- Clock division and debounce logic
- Pin constraint mapping for physical I/O
- Simulation and waveform debugging (GTKWAVE/ModelSim)
- Git-based project management and documentation

## 🧱 Hardware Requirements

- Digilent **Basys 3** FPGA board (Artix-7)
- VGA monitor + VGA cable
- Micro USB cable for programming the board

---

## 🛠️ Tools Used

- **Vivado** (Xilinx) for synthesis and implementation
- **VSCode** for HDL development
- **GTKWave** for simulation (optional)
- Git + GitHub for version control

---

## 📁 Project Structure

fpga-tetris/
│
├── src/ # Verilog/SystemVerilog source files
│ ├── top_module.sv # Top-level module
│ ├── vga_controller.sv # VGA timing generator
│ ├── clock_divider.sv # Generates slower clocks for logic/VGA
│ ├── tetris_logic.sv # Core gameplay mechanics
│ ├── block_renderer.sv # Drawing blocks and grid
│ ├── score_display.sv # Score tracking logic
│ ├── segment_decoder.sv # Converts digits to 7-segment format
│
├── constraints/
│ └── basys3.xdc # Pin mappings (VGA, buttons, segments, etc.)
│
├── sim/ # Testbenches (planned)
│
├── README.md
└── .gitignore

---

## 🧩 Core Modules

| Module             | Description                                                  |
|--------------------|--------------------------------------------------------------|
| `top_module.sv`    | Top-level wrapper connecting VGA, game logic, inputs         |
| `vga_controller.sv`| Generates VGA sync signals and pixel coordinates             |
| `tetris_logic.sv`  | Main FSM controlling falling blocks, collisions, game state  |
| `grid_display.sv`  | Maps block positions to colored pixels on VGA output         |
| `debounce.sv`      | Debounces pushbutton inputs for stable control               |
| `clock_divider.sv` | Generates slower clocks for game ticks and VGA timing        |

---

## 🛠️ Development Stack

| Tool / Language    | Purpose                                |
|--------------------|----------------------------------------|
| **Vivado**         | Synthesis, implementation, bitstream   |
| **SystemVerilog**  | Hardware design and logic description  |
| **VS Code**        | Code editing with HDL extensions       |
| **GTKWAVE**        | Waveform visualization for simulation  |
| **GitHub**         | Version control and documentation      |

---

## 🕹️ User Controls (via Basys 3 Buttons)

| Button  | Function         |
|---------|------------------|
| `btnL`  | Move block left  |
| `btnR`  | Move block right |
| `btnU`  | Rotate block     |
| `btnD`  | Soft drop        |
| Center  | Reset game       |

---

## 🖥️ Output Display

- **VGA resolution**: 640×480 pixels
- **Color-coded blocks**
- Grid-based rendering with live animation

---

## 🧪 How the Score Display Works

- A **`score_display` module** keeps track of points earned.
- Each cleared line updates the score counter.
- The score is decoded into 4 BCD digits and passed to the **`segment_decoder`**.
- The Basys 3's 7-segment display is **multiplexed** to show the 4-digit score in real-time.

---

## 📈 Goals

- ✔️ Understand digital design and game logic in hardware
- ✔️ Practice FSM design, display interfacing, and I/O timing
- ✔️ Build a standout portfolio project for job/internship applications

---

## Notes (Coming Soon)

- Possible Bugs
- Unmentioned Additions
- How to implement
- How to play

---

## License

MIT License
