# fpga-tetris-basys3

# 🧠 Tetris on FPGA — Hardware Game Engine (Basys 3)

A complete hardware implementation of the classic **Tetris** game, developed entirely in **SystemVerilog** and deployed on the **Basys 3 (Artix-7) FPGA**. This project showcases digital design skills, pipelined VGA signal generation, hardware-accelerated state machines, and real-time input handling — without any processor or software intervention.

---

## 🚀 Key Highlights

- ✅ **Designed and implemented** all game logic in RTL (no CPU, no software)
- 🧩 **Modular architecture**: clean separation between VGA, control logic, input, and rendering
- 🎮 Real-time control using Basys 3 pushbuttons
- 🎨 Hardware-rendered 2D graphics over **VGA at 640x480 @ 60Hz**
- 🧵 Fully synchronous FSM for game timing, collision, and rendering
- 🧪 Developed simulation testbenches for critical components

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

---

## 📦 Project Structure

tetris-fpga/
├── src/ # SystemVerilog source files
│ ├── top_module.sv
│ ├── vga_controller.sv
│ ├── tetris_logic.sv
│ ├── grid_display.sv
│ ├── debounce.sv
│ └── clock_divider.sv
├── constraints/ # Basys 3 XDC file for pin assignments
│ └── basys3.xdc
├── sim/ # Testbenches and simulation files
│ └── ...
├── docs/ # Design diagrams and architecture references
│ └── block_diagram.png
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

## 🎯 Success Criteria

- [x] Functional VGA display with stable timing
- [x] Working FSM with falling blocks and controls
- [x] Grid memory for storing block states
- [x] Debounced user input controls
- [x] Line clear detection and game over state
- [ ] Add scoring (via 7-segment or VGA overlay)
- [ ] Improve rotation collision edge cases

---

## 📸 Media (To Be Added)

- Tetris running live on Basys 3 board
- Demo video with game footage
- Architecture block diagram

---

## 📚 References

- [Basys 3 Reference Manual](https://digilent.com/reference/programmable-logic/basys-3/start)
- Ben Eater’s VGA videos (YouTube)
- Xilinx Vivado Documentation
- Tetris Wiki for rotation systems

---

## 📜 License

This project is licensed under the MIT License — see `LICENSE` for details.

---

> 🧠 **Note**: This project was created to demonstrate proficiency in digital logic, SoC-level integration, and hardware implementation of real-time systems. Designed to stand out on a technical resume and in FPGA/digital
