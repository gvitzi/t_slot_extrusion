// T-Slot Extrusion

object_type = "Extrusion"; // ["Extrusion", "Cap", "Cube Connector", "Cube Connector Face Cap", "Cube Connector Round Cap"]

profile_type = "40x40"; // ["20x20 M5","20x20 M6","20x40 M5","20x40 M6", "40x40 M8","40x80 M8"]

profile_sizes = [
    // base_size,  slot_width,  slot_depth,   nut size, screw_hole, profile_face_thickness ] 
    [       20,         11,     6.1-1.8,         5,          4.5,        1.8] ,
    [       20,         11,     6.1-1.8,         6,          5.5,        1.8] ,
    [       40,         20,        12-3,         8,          7.5,        3] ,
];

function get_profile_index() = 
    profile_type == "20x20 M5" || profile_type == "20x40 M5" ? 0 :
    profile_type == "20x20 M6" || profile_type == "20x40 M6" ? 1 :
    profile_type == "40x40 M8" || profile_type == "40x80 M8" ? 2 : -1;

function get_profile_size() = profile_sizes[get_profile_index()][0];
function get_slot_width() = profile_sizes[get_profile_index()][1];
function get_slot_depth() = profile_sizes[get_profile_index()][2];
function get_nut_size() = profile_sizes[get_profile_index()][3];
function get_screw_hole() = profile_sizes[get_profile_index()][4];
function get_profile_face_thickness() = profile_sizes[get_profile_index()][5];

profile_size = get_profile_size();

// set to true if "40x80" is chosen
double_frame = profile_type == "20x40 M5" || profile_type == "20x40 M6" || profile_type == "40x80 M8";
echo(["doubel_frame",double_frame]);
// Extrusion Length
length = 1;

// Filling type -  E = Ultralight, L = Light, S = Heavy
fill_type = "S"; // ["E","L","S"]

// Slot Type
slot_type = "B"; // ["B","I"]

// The corner radius in mm
corner_radius = 2;

// Nut Size - The size of screw hole at the ends
nut_size = get_nut_size();

// Slot Opening 
slot_opening = get_nut_size() + 0.2;

// Screw Hole
screw_hole = get_screw_hole();

// End Threads - Not Implemented
thread = false;

// Flat sides options
flat_sides = "None"; // ["None","A","AB","ABC","ABCD", "AC", "BD"] 

// Thickness of the profile face , This will control how 'deep' the slot sits inside the profile
profile_face_thickness = get_profile_face_thickness();

profile_x = profile_size;
profile_y = profile_size;

$fn=128;

frame_x = double_frame ? profile_size/2 - corner_radius : profile_size/2 - corner_radius;
start_x = double_frame ?  frame_x + profile_size : frame_x;

frame_y = -profile_size/2 + corner_radius;

module slot() {
    r = profile_size / 40;
   
    slot_width = get_slot_width();
    slot_depth = get_slot_depth();

    wing_length = (slot_width - slot_opening) / 2;
    narrow_width = slot_opening - 1; 
    difference() {
        translate([0, -profile_face_thickness]){
           translate([-slot_opening/2,0,0])square([slot_opening,profile_face_thickness+0.1]);
           hull() {
                translate([-slot_width/2 + r, -r])circle(r);
                translate([slot_width/2 - r, -r])circle(r);
                translate([slot_width/2 - r, -slot_depth/2.5])circle(r);
                translate([narrow_width/2, -slot_depth])circle(r);
                translate([-narrow_width/2, -slot_depth])circle(r);
                translate([-slot_width/2 + r, -slot_depth/2.5])circle(r);            
            }

            
       }
       
       if (slot_type == "I") {
           slot_teeth_size = slot_depth / 6;
           slot_teeth_width = slot_teeth_size + 0.5;
           translate([slot_opening / 2,-profile_face_thickness-slot_teeth_size])square([slot_teeth_width,slot_teeth_size]);
           translate([-slot_opening / 2 -slot_teeth_width ,-profile_face_thickness-slot_teeth_size])square([slot_teeth_width,slot_teeth_size]);
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
        circle(r=screw_hole / 2);

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
    sr = 0.92; // Scale Ratio
    adjust = (profile_size - 20) / 80;
    y = profile_size - profile_face_thickness - get_slot_depth()*2 + adjust;

    translate([0,y,0])scale(sr)difference(){
            slot(); 
            translate([-slot_opening/2,-profile_face_thickness,0])square([slot_opening,profile_face_thickness+0.1]);
        }
}

module cap_slot_legs_and_pin(cap_height) {
    // Center Pin
    cetner_pin_height = 3;
    r = nut_size/2-0.5;

    translate([0,0,-cetner_pin_height])linear_extrude(cetner_pin_height+cap_height){
        circle(r=nut_size/2-0.5);
        // Center Pin wings
        wing_width = r/1.5;
        wing_length = r*2 + 0.5;
        #translate([-wing_length/2,-wing_width/2,0])square([wing_length,wing_width]);
        #translate([-wing_width/2,-wing_length/2,0])square([wing_width,wing_length]);
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
    cap_height = profile_face_thickness;
    r = corner_radius;
    smooth = corner_radius;
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
        translate([0,0,-smooth-0.5])linear_extrude(height=smooth+0.5)hull() {
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

cube_connector_tool_hole_size = profile_size / 4;
cube_connector_wall_thickness = profile_face_thickness;

module cube_connector() {
    smooth = corner_radius;
    h = profile_size;
    x = frame_x;
    y = frame_y;

    screw_hole = get_screw_hole() / 2 + 0.5;
    tool_hole = cube_connector_tool_hole_size;

    wall_thickness = cube_connector_wall_thickness;
    inner_size = h-wall_thickness*2;
    
    difference() {
        //Cube Frame
        hull() {
            // base rounded rect
            translate([0,0,smooth])linear_extrude(height=h-smooth*2-wall_thickness)frame();

            // rounded bottom
            translate([start_x,x,smooth])sphere(smooth);
            translate([start_x,y,smooth])sphere(smooth);
            translate([y,y,smooth])sphere(smooth);
            translate([y,x,smooth])sphere(smooth);
        }

        // Create inside room
        translate([0,0,inner_size/2 + wall_thickness + 5])cube(size=[inner_size,inner_size,inner_size+10],center=true);

        // Holes
        {
            // Tool holes
           translate([0,0,h/2])rotate([0,0,0])cylinder(r=tool_hole,h=h);
           translate([0,h,h/2])rotate([90,0,0])cylinder(r=tool_hole,h=h);
           translate([-h,0,h/2])rotate([0,90,0])cylinder(r=tool_hole,h=h);

            //screw holes
            translate([0,0,-h/2])rotate([0,0,0])cylinder(r=screw_hole,h=h);
            translate([0,0,h/2])rotate([90,0,0])cylinder(r=screw_hole,h=h);
            translate([0,0,h/2])rotate([0,90,0])cylinder(r=screw_hole,h=h);
        }
    }   
}


module cube_connector_face_cap() {
    smooth = corner_radius;
    h = profile_size;
    x = frame_x;
    y = frame_y;
    wall_thickness = cube_connector_wall_thickness;

    // Smaller margin means tighter fit, higher margin means more loose
    margin = 0.3;

    // cap attachment leg
    difference() {
        //Cube Frame
        union(){
            hull() {
                // base rounded rect
                translate([0,0,h - wall_thickness - smooth])linear_extrude(height=wall_thickness)frame();

                // rounded top
                translate([start_x,x,h - smooth])sphere(smooth);
                translate([start_x,y,h - smooth])sphere(smooth);
                translate([y,y,h - smooth])sphere(smooth);
                translate([y,x,h - smooth])sphere(smooth);
            }

            // leg
            translate([0,0,profile_size-wall_thickness*2])cube([profile_size-wall_thickness*2 - margin,profile_size-wall_thickness*2 -margin,wall_thickness+2],center=true);
        }

        difference() {
            translate([-profile_size/2 - 1,-profile_size/2 - 1,profile_size-wall_thickness*3-1])cube([profile_size+2, profile_size+2, wall_thickness+1]);
            translate([0,0,profile_size-wall_thickness*2])cube([profile_size-wall_thickness*2 - margin,profile_size-wall_thickness*2 -margin,wall_thickness+2],center=true);
        }
        
        translate([0,0,profile_size-wall_thickness*2])cube([profile_size-wall_thickness*2-3,profile_size-wall_thickness*2-3,wall_thickness+3],center=true);
    }
}

module cube_connector_round_cap() {
    hole_size = cube_connector_tool_hole_size;
    margin = 0.1;
    cylinder(r1=hole_size,r2=hole_size+2,h=1);
    difference() {
        translate([0,0,1])cylinder(r=hole_size-margin,h=2);
        translate([0,0,1.1])cylinder(r=hole_size-margin-1,h=3);
    }
}

if (object_type == "Extrusion") {
    linear_extrude(height=length)profile();
}

if (object_type == "Cap") {
    rotate([180,0,0])cap();
}

if (object_type == "Cube Connector") {
    wall_thickness = cube_connector_wall_thickness;
    cube_connector();
}

if (object_type == "Cube Connector Face Cap") {
    translate([0,0,40])rotate([180,0,0])cube_connector_face_cap();
}

if (object_type == "Cube Connector Round Cap") {
    cube_connector_round_cap();
}
