// T-Slot Extrusion

object_type = "extrusion"; // ["extrusion", "cap"]

profile_type = "40x40"; // ["40x40","40x80"]


// set to true if "40x80" is chosen
double_frame = len(search("8", profile_type)) > 0;
    
// Extrusion Length
length = 1;

// Filling type -  E = Ultralight, L = Light, S = Heavy
fill_type = "E"; // ["E","L","S"]

// Slot Type
slot_type = "I"; // ["B","I"]

// The corner radius in mm
corner_radius = 3;

// Nut Size - The size of screw hole at the ends
nut_size = 7.5;

// Slot Opening 
slot_opening = 8;

// End Threads - Not Implemented
thread = false;

// Flat sides options
flat_sides = "None"; // ["None","A","AB","ABC","ABCD", "AC"] 

// Thickness of the profile face , This will control how 'deep' the slot sits inside the profile
profile_face_thickness = 3;

// Work In Progress - Changing this will most likely output a broken model
profile_size = 40; // [50,40,30,20,15]
profile_x = profile_size;
profile_y = profile_size;

$fn=128;

frame_x = double_frame ? profile_size/2 - corner_radius : profile_size/2 - corner_radius;
start_x = double_frame ?  frame_x + profile_size : frame_x;

frame_y = -profile_size/2 + corner_radius;

module slot() {
    outer_radius = corner_radius;
    r = outer_radius/3;
   
    slot_width = 20;
    slot_depth = 10;

    wing_length = (slot_width - slot_opening) / 2;
    
    difference() {
        translate([-slot_opening/2, -profile_face_thickness]){
            square([slot_opening,profile_face_thickness]);
            hull() {
                translate([-wing_length + r, -r])circle(r);
                translate([slot_opening + wing_length -r, -r])circle(r);
                translate([slot_opening + wing_length -r, -4])circle(r);
                translate([slot_opening - 0.5, -slot_depth+r])circle(r);
                translate([0.5, -slot_depth+r])circle(r);
                translate([-5, -slot_depth+r +5])circle(r);            
            }
       }
       
       if (slot_type == "I") {
           translate([4,-5])square([2.5,2]);
           translate([-6.5,-5])square([2.5,2]);
       }
   }
}

module ultra_light_hole() {
   
    light_hole();
    
    a = 0.7;
    hull() {
        rotate([0,0,45])translate([17,-a])circle(0.5);
        rotate([0,0,45])translate([17,a])circle(0.5);
        rotate([0,0,45])translate([22,-a])circle(0.5);
        rotate([0,0,45])translate([22,a])circle(0.5);
    }
    
    rotate([0,0,45])minkowski() {
        polygon([[15.3,a], [15.3,-a],[10,-0.7], [6.2,-1.0], [6.2,1.0], [10,0.7] ]);
        circle(r=0.3);
    }
         
    // rounded 1/4 arc
    minkowski(){
        difference(){
            difference(){
                circle(r=6);
                circle(r=5.7);
            }
            translate([-8,0])square([9,9]);
            translate([0,-8])square([9,9]);
            translate([-10,-10])square([10,10]);
        }
        circle(r=0.5);
    }
}

module light_hole() {
    outer_radius = corner_radius;
    r = outer_radius;
   
    translate([profile_x/2-profile_face_thickness-1,profile_y/2-profile_face_thickness-1]) {
        hull() {
            polygon(points=[[3,-4],[-4,-4],[-4,3]]);
            translate([3-r,3-r])circle(r);
        }
    }
}

module smooth_face() {
    translate([profile_x/2-profile_face_thickness,-slot_opening/2])square([profile_face_thickness,slot_opening+2]);
}

module frame() {
    r = corner_radius;
    hull() {
        translate([start_x, frame_y])circle(r);
        translate([start_x, -frame_y])circle(r); 
        translate([-frame_x, frame_y])circle(r); 
        translate([-frame_x, -frame_y])circle(r); 
    }
}

module square_profile_cuts() {
    // Add Slots
        for (side_index = [0 : 3] ){
            rotate([0,0,90 * side_index])translate([0,profile_y/2])slot();
        }

       // Center Hole
        circle(r=nut_size/2);

        if (fill_type == "L") {
            // add holes to make light "L"
            rotate([0,0,0])light_hole();
            rotate([0,0,90])light_hole();
            rotate([0,0,180])light_hole();
            rotate([0,0,270])light_hole();
        }
        if (fill_type == "E") {
            // add holes to make ultra light "E"
            rotate([0,0,0])ultra_light_hole();
            rotate([0,0,90])ultra_light_hole();
            rotate([0,0,180])ultra_light_hole();
            rotate([0,0,270])ultra_light_hole();
        }
}
module flat_sides() {
     // Flat sides
    if (len(search("A", flat_sides))) {
        rotate([0,0,0])smooth_face();
    }
    if (len(search("B", flat_sides))) {
        rotate([0,0,90])smooth_face();
    }
    if (len(search("C", flat_sides))) {
        rotate([0,0,180])smooth_face();
    }
    if (len(search("D", flat_sides))) {
        rotate([0,0,270])smooth_face();
    }
}
module profile() {
    difference() {
        
        // Basic Square Frame
        frame();
        square_profile_cuts();
        if (double_frame) { 
            translate([profile_size,0,0])square_profile_cuts();
        }
    }
    
    flat_sides();
    if (double_frame) { 
        translate([profile_size,0,0])flat_sides();
    }
}

module cap_slot_leg() {
    sr = 0.90; // Scale Ratio
    translate([0,19.5,0])scale(sr)difference(){
            slot(); 
            translate([-slot_opening/2,-profile_face_thickness,0])square([slot_opening,profile_face_thickness]);
        }
}

module cap_slot_legs_and_pin(cap_height) {
    // Center Pin
    cetner_pin_height = 4;
    translate([0,0,-cetner_pin_height])linear_extrude(cetner_pin_height+cap_height){
        circle(r=nut_size/2-0.5);
        // Center Pin wings
        translate([-3.5,-1,0])square([7,2]);
        translate([-1,-3.5,0])square([2,7]);
    }
        
    // Slot Legs
    slot_legs_height = 2;
    translate([0,0,-slot_legs_height])linear_extrude(slot_legs_height+cap_height)  {
        rotate([0,0,0])cap_slot_leg();
        rotate([0,0,90])cap_slot_leg();
        rotate([0,0,180])cap_slot_leg();
        rotate([0,0,270])cap_slot_leg();
    }
}

module cap() {
    cap_height = 3;
    r = corner_radius;
   
    smooth = r;
    x = frame_x;
    y = frame_y;
    
    // Basic Square Frame
    difference() {
        hull(){
            // base rounded rect
            linear_extrude(height=cap_height-smooth)frame();
            
            // rounded top 
            translate([start_x,x,cap_height-smooth])sphere(smooth);
            translate([start_x,y,cap_height-smooth])sphere(smooth);
            translate([y,y,cap_height-smooth])sphere(smooth);
            translate([y,x,cap_height-smooth])sphere(smooth);
            
        }
        
        // Cut bottom
        translate([0,0,-smooth])linear_extrude(height=smooth)hull() {
            translate([x*4, y*2])circle(r);
            translate([x*4, -y*2])circle(r); 
            translate([-x*4, y*2])circle(r); 
            translate([-x*4, -y*2])circle(r); 
        }
    
    thickness = 1;
    x2 = x - thickness;
    y2 = y + thickness;
    // inset
    translate([0,0,-0.1])linear_extrude(height=cap_height-thickness)hull() {
        translate([start_x - thickness, y2])circle(r);
        translate([start_x - thickness, -y2])circle(r); 
        translate([-x2, y2])circle(r); 
        translate([-x2, -y2])circle(r); 
        }
    }
    
    cap_slot_legs_and_pin(cap_height);
    if (double_frame) { 
        translate([profile_size,0,0])cap_slot_legs_and_pin(cap_height);
    }
    
}

if (object_type == "extrusion") {
    linear_extrude(height=length)profile();
}

if (object_type == "cap") {
    cap();
}
