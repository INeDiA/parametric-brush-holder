// ==========================================
// --- USER-MODIFIABLE PARAMETERS ---
// ==========================================

/* [Selection] */
// Select which part to render for export or preview
part = "both"; // [both, wall, clips]

/* [Brush Settings] */
// Diameter of the brush (e.g., 10, 15, 20)
brush_diameter = 10;       
// Number of holders
num_brushes = 6;           

/* [Suction Cups] */
// Diameter of the HOLES for suction cups
suction_cups_hole_diameter = 4;  
// Distance from side edges for suction cups
edge_distance = 40;        

/* [Other Parameters] */
// Overall length including the lateral joint
total_length = 150;        
// Thickness of the vertical wall
wall_thickness = 4;        
// Thickness of the horizontal base
base_thickness = 4;        
// Height of the vertical wall plate
wall_plate_height = 20;    
// Space between the wall and the brush clips
wall_clearance = 5;

// ==========================================
// --- DYNAMIC CLIP CALCULATIONS ---
// ==========================================

front_opening = brush_diameter * 0.7; 
clip_wall_thickness = max(2, brush_diameter * 0.15); 

// ==========================================
// --- JOINT PARAMETERS (Internal) ---
// ==========================================

puz_r_lateral = 3.5;       
puz_r_bottom = 2.0;        
puz_tol = 0.1;             

dist_lat = puz_r_lateral * 0.75; 
dist_bot = puz_r_bottom * 0.75;    

body_length = total_length - dist_lat; 
clip_spacing = (body_length - (num_brushes * brush_diameter)) / (num_brushes + 1);

$fn = 100; 

// --- RENDERING ---

if (part == "wall" || part == "both") {
    // Piece 1: Wall Plate
    translate([body_length, -10, wall_thickness]) 
    rotate([-90, 0, 180]) 
    wall_plate_clean();
}

if (part == "clips" || part == "both") {
    // Piece 2: Clips Support
    translate([0, 30, 0]) 
    clips_part_dynamic();
}

// --- MODULE 1: WALL PLATE ---
module wall_plate_clean() {
    difference() {
        union() {
            cube([body_length, wall_thickness, wall_plate_height]);
            
            // Lateral Male (Right)
            translate([body_length + dist_lat, 0, wall_plate_height/2])
            rotate([-90, 0, 0])
            linear_extrude(wall_thickness)
            circle(r = puz_r_lateral);

            // 5 Bottom Males
            for (i = [1 : 5]) {
                pos = (body_length / 6) * i;
                translate([pos, 0, -dist_bot]) 
                rotate([-90, 0, 0]) 
                linear_extrude(wall_thickness)
                circle(r = puz_r_bottom);
            }
        }

        // Lateral Female (Left)
        translate([dist_lat, -1, wall_plate_height/2])
        rotate([-90, 0, 0])
        linear_extrude(wall_thickness + 2)
        circle(r = puz_r_lateral + puz_tol);

        // Suction Cup Holes (using the updated variable name)
        for (x = [edge_distance, body_length - edge_distance]) {
            translate([x, -1, wall_plate_height/2])
            rotate([-90, 0, 0]) 
            cylinder(h = wall_thickness + 2, d = suction_cups_hole_diameter);
        }
    }
}

// --- MODULE 2: CLIPS PART ---
module clips_part_dynamic() {
    difference() {
        union() {
            // Main support plate
            cube([body_length, wall_clearance + wall_thickness, base_thickness]);
            
            for (i = [0 : num_brushes - 1]) {
                translate([
                    clip_spacing + brush_diameter/2 + i*(brush_diameter + clip_spacing), 
                    wall_thickness + wall_clearance + (brush_diameter/2), 
                    base_thickness / 2
                ])
                brush_clip();
            }
        }

        // 5 Female Joints (5mm deep on Y axis)
        for (i = [1 : 5]) {
            pos = (body_length / 6) * i;
            z_center = (base_thickness + 0.5) - puz_r_bottom; 
            y_center = dist_bot;

            translate([pos, -1, z_center]) 
            rotate([-90, 0, 0]) 
            linear_extrude(wall_thickness + 1 + puz_tol) 
            circle(r = puz_r_bottom + puz_tol);
            
            translate([pos, y_center, z_center]) 
            rotate([-90, 0, 0])
            cylinder(h = wall_thickness + 1, r = puz_r_bottom + puz_tol, center=true);
        }
    }
}

// --- HELPERS ---
module brush_clip() {
    difference() {
        cylinder(h = base_thickness, d = brush_diameter + (clip_wall_thickness * 2), center = true);
        cylinder(h = base_thickness + 1, d = brush_diameter, center = true);
        
        translate([0, brush_diameter/2, 0])
        cube([front_opening, brush_diameter + clip_wall_thickness * 2, base_thickness + 1], center = true);
    }
    
    for(m = [0, 1]) mirror([m, 0, 0])
    translate([front_opening/2, sqrt(pow((brush_diameter + clip_wall_thickness)/2, 2) - pow(front_opening/2, 2)), 0])
    cylinder(h = base_thickness, d = clip_wall_thickness, center = true);
}