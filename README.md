Got it ✅ Vishwa. Since you’ll be showing this off as a **complete RTL → GDS project**, I’ll extend the **README.md** to include a **Simulation Output Screenshot** section (where you’ll later paste in your GTKWave / console logs), plus placeholders for **OpenROAD** and **OpenSTA** results.

Here’s the polished version for your project:

---

# 📘 APB Slave Memory – RTL to GDSII Project

## 📌 Overview

This project implements an **APB (Advanced Peripheral Bus) Slave Memory** in Verilog/SystemVerilog.
The design models a **32 x 32-bit memory** accessible via APB protocol signals, with support for both **read and write transactions**.

The ultimate goal is to take this design **from RTL → GDSII** using open-source ASIC tools.

---

## 🏗️ Features

* **APB Protocol Compliant** (PCLK, PENABLE, PSELx, PWRITE, PREADY, PSLVERR).
* **32-bit data, 32 addresses**.
* Handles both **read and write transfers**.
* Includes debug signal `temp` to check stored memory contents.
* Fully synthesizable RTL.

---

## 📂 Repository Structure

```
├── rtl/
│   └── apb_slave_memory.sv      # RTL Design
├── tb/
│   └── apb_memory_tb.sv         # Testbench
├── sim/
│   └── dump.vcd                 # Simulation waveform (generated)
├── docs/
│   └── README.md                # Project Documentation
└── flow/
    ├── yosys/                   # Synthesis scripts
    ├── openroad/                # Floorplanning, placement & routing
    ├── opensta/                 # Timing analysis
    └── reports/                 # Timing, area, power reports
```

---

## ⚡ Simulation

1. Compile and run using **Icarus Verilog**:

   ```bash
   iverilog -o simv rtl/apb_slave_memory.sv tb/apb_memory_tb.sv
   vvp simv
   gtkwave dump.vcd
   ```
2. Console output example:

   ```
   Writing data into memory: data = deadbeef, address = 5
   Reading data from memory: data = deadbeef, address = 5
   ```

---

## 📸 Simulation Output Screenshot

<img width="1867" height="437" alt="image" src="https://github.com/user-attachments/assets/1a40b3cf-47cc-4073-bf5e-0e780eb3bb97" />


## 🛠️ Tools Used

* **RTL & Simulation:** Icarus Verilog, GTKWave
* **Linting:** Verilator / Surelog
* **Synthesis:** Yosys
* **PnR (RTL → GDSII):** OpenROAD / OpenLane
* **Timing Analysis:** OpenSTA
* **Signoff:** Magic, KLayout, Netgen

---

## 🚀 Next Steps

✅ Step 1: RTL design + Testbench ✅
✅ Step 2: Functional simulation ✅
🔄 Step 3: Synthesis (Yosys)
🔄 Step 4: Floorplan, placement, routing (OpenROAD)
🔄 Step 5: Timing checks (OpenSTA)
🔄 Step 6: DRC/LVS signoff (Magic, KLayout)
🔄 Step 7: Final **GDSII generation**

---

## 📜 License

This project is released under the [MIT License](LICENSE).

---

✨ *Author: Vishwa Patwari*
📅 *2025*
🔗 https://github.com/vishwa-patwari/AMBA_APB-RTL_TO_GDS-

