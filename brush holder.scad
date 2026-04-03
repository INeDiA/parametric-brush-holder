// ==========================================
// --- USER-MODIFIABLE PARAMETERS ---
// ==========================================

/* [Selection] */
// Select which part to render for export or preview
part = "both"; // [both, wall, clips]

/* [Joints Toggle] */
// Enable or disable BOTH lateral puzzle joints (Male & Female)
enable_puzzle_joints = true;

/* [Brush Settings] */
// Diameter of the brush (e.g., 10.0, 12.5)
brush_diameter = 10.0; // [5:0.1:40]      

// Number of holders
num_brushes = 6; // [1:1:20]

/* [Suction Cups] */
// Diameter of the HOLES for suction cups (e.g., 4.0, 4.2)
suction_cups_hole_diameter = 4.0; // [2:0.1:10]

// Distance from side edges for suction cups
edge_distance = 29.0; // [5:0.1:100]

/* [Other Parameters] */
// Overall length of the main body
total_length = 150.0; // [50:0.5:300]
// Thickness of the vertical wall
wall_thickness = 4.0; // [1:0.1:10]
// Thickness of the horizontal base
base_thickness = 4.0; // [1:0.1:10]
// Height of the vertical wall plate
wall_plate_height = 20.0; // [10:0.5:100]
// Space between the wall and the brush clips
wall_clearance = 5.0; // [0:0.1:30]

// ==========================================
// --- DYNAMIC CALCULATIONS ---
// ==========================================

front_opening = brush_diameter * 0.7; 
clip_wall_thickness = max(2.0, brush_diameter * 0.15); 

// JOINT PARAMETERS (Internal)
puz_r_lateral = 3.5;       
puz_r_bottom = 2.0;        
puz_tol = 0.1;             

dist_lat = puz_r_lateral * 0.75; 
dist_bot = puz_r_bottom * 0.75;    

// Body length logic
body_length = total_length - dist_lat; 

clip_spacing = (body_length - (num_brushes * brush_diameter)) / (num_brushes + 1);

$fn = 100; 

// --- RENDERING ---

if (part == "wall" || part == "both") {
    // Piece 1: Wall Plate
    translate([body_length, -10.0, wall_thickness]) 
    rotate([-90.0, 0.0, 180.0]) 
    wall_plate_clean();
}

if (part == "clips" || part == "both") {
    // Piece 2: Clips Support
    translate([0.0, 30.0, 0.0]) 
    clips_part_dynamic();
}

// --- MODULE 1: WALL PLATE ---
module wall_plate_clean() {
    difference() {
        union() {
            cube([body_length, wall_thickness, wall_plate_height]);
            
            // Lateral Male (Right) - Conditioned by single toggle
            if (enable_puzzle_joints) {
                translate([body_length + dist_lat, 0.0, wall_plate_height/2.0])
                rotate([-90.0, 0.0, 0.0])
                linear_extrude(wall_thickness)
                circle(r = puz_r_lateral);
            }

            // 5 Bottom Males (Keep these for internal clip connection)
            for (i = [1 : 5]) {
                pos = (body_length / 6.0) * i;
                translate([pos, 0.0, -dist_bot]) 
                rotate([-90.0, 0.0, 0.0]) 
                linear_extrude(wall_thickness)
                circle(r = puz_r_bottom);
            }
        }

        // Lateral Female (Left) - Conditioned by single toggle
        if (enable_puzzle_joints) {
            translate([dist_lat, -1.0, wall_plate_height/2.0])
            rotate([-90.0, 0.0, 0.0])
            linear_extrude(wall_thickness + 2.0)
            circle(r = puz_r_lateral + puz_tol);
        }

        // Suction Cup Holes
        for (x = [edge_distance, body_length - edge_distance]) {
            translate([x, -1.0, wall_plate_height/2.0])
            rotate([-90.0, 0.0, 0.0]) 
            cylinder(h = wall_thickness + 2.0, d = suction_cups_hole_diameter);
        }
    }
}

// --- MODULE 2: CLIPS PART ---
module clips_part_dynamic() {
    difference() {
        union() {
            cube([body_length, wall_clearance + wall_thickness, base_thickness]);
            
            for (i = [0 : num_brushes - 1]) {
                translate([
                    clip_spacing + brush_diameter/2.0 + i*(brush_diameter + clip_spacing), 
                    wall_thickness + wall_clearance + (brush_diameter/2.0), 
                    base_thickness / 2.0
                ])
                brush_clip();
            }
        }

        // 5 Female Joints for wall connection
        for (i = [1 : 5]) {
            pos = (body_length / 6.0) * i;
            z_center = (base_thickness + 0.5) - puz_r_bottom; 
            y_center = dist_bot;

            translate([pos, -1.0, z_center]) 
            rotate([-90.0, 0.0, 0.0]) 
            linear_extrude(wall_thickness + 1.0 + puz_tol) 
            circle(r = puz_r_bottom + puz_tol);
            
            translate([pos, y_center, z_center]) 
            rotate([-90.0, 0.0, 0.0])
            cylinder(h = wall_thickness + 1.0, r = puz_r_bottom + puz_tol, center=true);
        }
    }
}

// --- HELPERS ---
module brush_clip() {
    difference() {
        cylinder(h = base_thickness, d = brush_diameter + (clip_wall_thickness * 2.0), center = true);
        cylinder(h = base_thickness + 1.0, d = brush_diameter, center = true);
        
        translate([0.0, brush_diameter/2.0, 0.0])
        cube([front_opening, brush_diameter + clip_wall_thickness * 2.0, base_thickness + 1.0], center = true);
    }
    
    for(m = [0, 1]) mirror([m, 0, 0])
    translate([front_opening/2.0, sqrt(pow((brush_diameter + clip_wall_thickness)/2.0, 2) - pow(front_opening/2.0, 2)), 0.0])
    cylinder(h = base_thickness, d = clip_wall_thickness, center = true);
}