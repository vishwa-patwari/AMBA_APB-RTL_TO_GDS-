# 📘 APB Slave Memory – RTL to GDSII Project

## 📌 Overview

This project implements an **APB (Advanced Peripheral Bus) Slave Memory** in Verilog/SystemVerilog.
The design models a **32 x 32-bit memory** accessible via APB protocol signals, with support for both **read and write transactions**.

The ultimate goal is to take this design **from RTL → GDSII** using open-source ASIC tools.

---


## 🏗️ Features
- Fully functional APB Slave Memory module.
- Complete RTL design in Verilog.
- **Synthesis** using **Yosys** targeting **Nangate 45nm library**.
- **Static Timing Analysis (STA)** using **OpenSTA**.
- **Place & Route (PnR)** using **OpenROAD**.
- **GDSII generation** using **KLayout**.
- Detailed reports for each stage of the flow.

---

## 🗂️ Directory Structure

```

apb\_slave\_memory/
│
├── rtl/
│   ├── apb\_slave.v           # Verilog source file
│
├── Testbench/
│   ├── apb\_slave_tb.v
├── synthesis/
│   ├── scripts
│   └── reports/              # Synthesis reports
│
├── sta/
│   ├── scripts
│   └── reports/              # STA reports
│
├── pnr/
│   ├── scripts/              # PnR scripts
│   ├── results/
│   │   ├── floorplanning/
│   │   ├── global\_placement/
│   │   ├── detailed\_placement/
│   │   ├── cts/
│   │   └── routing/
│   │       └── \*.def         # DEF files for each stage
│   └── reports/
│       ├── pre\_cts/
│       └── post\_cts/         # PnR reports
│
└── README.md                 # Project documentation

```

---

## 🛠️ Tools & Libraries Used
- **RTL Design:** Verilog/SystemVerilog
- **Synthesis:** Yosys  
- **Library:** Nangate 45nm Open Cell Library  
- **STA:** OpenSTA  
- **Place & Route (PnR):** OpenROAD  
- **GDSII Viewing & Verification:** KLayout  
- **Simulation:** Any RTL simulator (ModelSim/iverilog/other)

---

## ⚡ Project Flow
1. **RTL Design:**  
   - Implemented APB Slave Memory in `rtl/apb_slave.v`.  
   - Simulated and verified functional correctness.  

2. **Synthesis:**  
   - Run Yosys scripts to synthesize RTL to gate-level netlist.  
   - Generate schematics and reports in `synthesis/reports/`.

3. **Static Timing Analysis (STA):**  
   - Perform timing checks using OpenSTA.  
   - Reports saved in `sta/reports/`.

4. **Place & Route (PnR):**  
   - Floorplanning, placement, clock tree synthesis (CTS), and routing performed using OpenROAD.  
   - DEF files for each stage saved in `pnr/results/`.  
   - Timing, congestion, and design rule reports saved in `pnr/reports/`.

5. **GDSII Generation:**  
   - Final layout exported to GDSII format using KLayout.  
   - Ready for fabrication or further analysis.

---

## 📄 Reports
- **Synthesis Reports:** Area, timing, and power estimates.  
- **STA Reports:** Setup/hold violations, slack analysis.  
- **PnR Reports:** Floorplan utilization, congestion, DRC, LVS checks.  

---

## 📌 Notes
- This project uses **open-source EDA tools**, making it reproducible on any Linux environment.  
- The project demonstrates a **full ASIC design flow**, which can be used as a reference for other memory designs or APB peripheral modules.

---

## 🔗 References
- [Yosys Open Source Synthesis Tool](http://www.clifford.at/yosys/)  
- [OpenSTA Timing Analysis Tool](https://github.com/The-OpenROAD-Project/OpenSTA)  
- [OpenROAD Place & Route](https://theopenroadproject.org/)  
- [KLayout GDS Viewer](https://www.klayout.de/)  
- [Nangate 45nm Open Cell Library](https://si2.org/open-cell-library/)

---

## 📝 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details


✨ *Author: Vishwa Patwari*
📅 *2025*
🔗 https://github.com/vishwa-patwari/AMBA_APB-RTL_TO_GDS-

