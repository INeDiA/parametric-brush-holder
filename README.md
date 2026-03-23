# 🖌️ Modular Brush Suction Holder (Parametric)

A fully parametric, 3D-printable modular system designed to organize brushes (makeup, painting, or tools) using suction cups. Optimized for mirrors, tiles, or glass surfaces.

---

## ✨ Features

- **Fully Parametric:** Adjust brush diameters, number of clips, and hole sizes via the OpenSCAD Customizer.
- **Dynamic C-Clips:** The opening and wall thickness of the clips scale automatically based on the brush diameter to ensure a perfect "snap" fit.
- **Modular Puzzle-Joint:** Features a lateral and bottom dovetail system to connect multiple units together.
- **3D Printing Optimized:** Parts are pre-oriented to lie flat on the print bed for maximum structural integrity.

---

## 🛠️ How to Customize

1. Open the `.scad` file in [OpenSCAD](https://openscad.org/).
2. Enable the **Customizer** panel (`View` -> `Customizer`).
3. Adjust the parameters in the following sections:
   - **Selection:** Toggle between rendering the `wall` plate, the `clips` support, or `both`.
   - **Brush Settings:** Set `brush_diameter` and the `num_brushes`.
   - **Suction Cups:** Define the `suction_cups_hole_diameter` and its `edge_distance`.
   - **Other Parameters:** Fine-tune the `total_length`, `wall_thickness`, or `wall_clearance`.
4. Press `F6` to render and `F7` to export the STL file.

---

## 📐 Parameters Overview

| Section | Parameter | Description |
| :--- | :--- | :--- |
| **Selection** | `part` | Dropdown menu to select which part to export. |
| **Brush Settings** | `brush_diameter` | The internal diameter of the clip (scales the clip geometry). |
| **Brush Settings** | `num_brushes` | Number of holders distributed along the length. |
| **Suction Cups** | `suction_cups_hole_diameter`| The exact diameter for the suction cup mounting nib. |
| **Other Parameters** | `total_length` | Total width of the module (default: 150mm). |
| **Other Parameters** | `wall_clearance` | Safety distance between the wall plate and the clips. |

---

## 🖨️ Printing & Assembly

### Orientation
The script automatically lays the **Wall Plate** flat on its side and the **Clips** on their base. 
- **Wall Plate:** Rotated 180° so the male joints are clearly visible and face the user/clips for easy orientation.

### Recommended Settings
- **Material:** PETG (recommended for bathroom/wet environments) or PLA.
- **Infill:** 15-20% (Rectilinear or Gyroid).
- **Supports:** Not required.
- **Tolerance:** The mechanical tolerance is set to **0.1mm** for a tight, secure fit.

---

## 📜 License
This project is open-source. Feel free to modify and adapt it for your needs.
