// --- PARAMETRI FISSI (in mm) ---
total_length = 150;
wall_thickness = 4;      
base_thickness = 4;      
wall_plate_height = 20;  // RIDOTTO DA 30 A 20

// --- PARAMETRI ACCESSORI ---
suction_cup_diameter = 4;
edge_distance = 40;      // IMPOSTATO A 40
brush_diameter = 20; 
num_brushes = 4; 
clip_wall_thickness = 2.5;   
front_opening = 14;      
wall_clearance = 5;      

// --- PARAMETRI INCASTRO (Diametro 4mm -> Raggio 2mm) ---
puz_r_bottom = 2.0;       
puz_r_lateral = 3.5;
puz_tol = 0.15;           

// --- LA REGOLA DEI 3/4 (Spostamento centro = raggio * 0.75) ---
dist_lat = puz_r_lateral * 0.75; 
dist_bot = puz_r_bottom * 0.75;    // 1.5 mm 

// Calcolo lunghezza corpo
body_length = total_length - dist_lat; 
clip_spacing = (body_length - (num_brushes * brush_diameter)) / (num_brushes + 1);

$fn = 100; 

// --- RENDERING ---
wall_plate_final();

translate([0, 60, 0]) 
brush_base_final_corrected();

// --- MODULE 1: WALL PLATE ---
module wall_plate_final() {
    difference() {
        union() {
            cube([body_length, wall_thickness, wall_plate_height]);
            
            // 5 Maschi Inferiori
            for (i = [1 : 5]) {
                pos = (body_length / 6) * i;
                translate([pos, 0, -dist_bot]) 
                rotate([-90, 0, 0]) 
                linear_extrude(wall_thickness)
                circle(r = puz_r_bottom);
            }
            
            // Maschio Laterale
            translate([body_length + dist_lat, 0, wall_plate_height/2])
            rotate([-90, 0, 0])
            linear_extrude(wall_thickness)
            circle(r = puz_r_lateral);
        }
        
        // Femmina Laterale
        translate([dist_lat, 0, wall_plate_height/2])
        rotate([-90, 0, 0])
        linear_extrude(wall_thickness + 2, center=true)
        circle(r = puz_r_lateral + puz_tol);

        // Fori Ventose (Centrati sulla nuova altezza di 20mm)
        for (x = [edge_distance, body_length - edge_distance]) {
            translate([x, -1, wall_plate_height/2])
            rotate([-90, 0, 0]) 
            cylinder(h = wall_thickness + 2, d = suction_cup_diameter);
        }
    }
}

// --- MODULE 2: BRUSH BASE ---
module brush_base_final_corrected() {
    difference() {
        union() {
            cube([body_length, wall_clearance + wall_thickness, base_thickness]);

            for (i = [0 : num_brushes - 1]) {
                translate([
                    clip_spacing + brush_diameter/2 + i*(brush_diameter + clip_spacing), 
                    wall_thickness + wall_clearance + (brush_diameter/2) - 1, 
                    base_thickness / 2
                ])
                brush_clip();
            }
        }

        // --- 5 FEMMINE (Regola 3/4 fuori dal bordo, 1/4 morde il TOP) ---
        for (i = [1 : 5]) {
            pos = (body_length / 6) * i;
            
            // Centro Z = 2.5 mm (per mordere 0.5mm di top su 4mm di spessore)
            z_center = (base_thickness + 0.5) - puz_r_bottom; 
            y_center = dist_bot;

            // Sottrazione cilindrica bordo
            translate([pos, -1, z_center]) 
            rotate([-90, 0, 0]) 
            cylinder(h = y_center + 1 + puz_tol, r = puz_r_bottom + puz_tol);
            
            // Sottrazione cilindrica asola top
            translate([pos, y_center, z_center]) 
            rotate([-90, 0, 0])
            cylinder(h = wall_thickness, r = puz_r_bottom + puz_tol, center=true);
        }
    }
}

// --- HELPERS ---
module brush_clip() {
    difference() {
        cylinder(h = base_thickness, d = brush_diameter + (clip_wall_thickness * 2), center = true);
        cylinder(h = base_thickness + 1, d = brush_diameter, center = true);
        translate([0, brush_diameter/2, 0])
        cube([front_opening, brush_diameter, base_thickness + 1], center = true);
    }
    for(m = [0, 1]) mirror([m, 0, 0])
    translate([front_opening/2, brush_diameter/2, 0])
    cylinder(h = base_thickness, d = clip_wall_thickness, center = true);
}