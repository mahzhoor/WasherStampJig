/*
This is WasherStampJig by mahzhoor <mahzhoor@protonmail.com>
See https://github.com/mahzhoor/WasherStampJig for details

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

—

The following code requires text_on_OpenSCAD library (by Brody Kenrick) which is licensed LGPLv2.1.
See https://github.com/brodykenrick/text_on_OpenSCAD for details

*/

use <text_on.scad>

// Edit these parameters to customize the templates

// How many letters should fit on one washer? The more letters, the smaller angle between them.
letters = 15;

// How many stencils should the letters be divided into? Adjust it so that the letter holes do not overlap.
stencils = 3;

// How many copies do you plan to stamp at the same time? Each base holds one washer
bases = 2;

// Small gap between elements. If the stencil wiggle too much in the base - decrease. If it doesn't fit – increase.
epsilon = 0.2;

// Your metal stamp dimensions
stamp_width = 6.25;
stamp_depth = 6.25;
stamp_height = 20;

// Your washers dimensions
washer_inner = 8.5;
washer_outer = 23.85;
washer_thickness = 1.5;

// Additional parameters – you probably don't need to change them

wall_thickness = 2;
holder_height_ratio = 0.45;
font_size = 4;
marker_thickness = 4;

// End of parameters


angle = 360/letters;
r = (washer_inner-epsilon)/2+((washer_outer+epsilon-washer_inner-epsilon)/2-(stamp_depth+epsilon))/2; // inner line r for stamp
$fn=300;

box_size = max(
    (washer_outer+epsilon) + 2 * wall_thickness, // if stencils are small
    (r + (stamp_depth+epsilon) + 2 * wall_thickness) * 2 // if stencils are big
);

displacement = [box_size/2,box_size/2,0];
font_adj = (font_size / (2*3.1416*(box_size/2)) * 360)/4;

//Stencils
for (k = [0:stencils-1]) {
    translate([k*box_size*1.5,0,0]) {
        translate(displacement)
//        rotate([0,180,0]) translate([0,0,-stamp_height]) // flip
        difference() {
            union() {
                cylinder(h=stamp_height,r=box_size/2); // main body
                rounded_inset(0);
            }
            holes(stamp_width, stamp_depth, stamp_height, r, letters, k+1, stencils); // holes
        }
    }

}

//Bases
for (m = [0:bases-1]) {
    translate([m*box_size*1.5+box_size/2,box_size*2,0])
    difference() {
        cylinder(h=stamp_height*holder_height_ratio,r=box_size/2+wall_thickness); // outer body
        translate([0,0,washer_thickness]) cylinder(h=stamp_height,r=box_size/2+epsilon); // inner body
        translate([0,0,-epsilon]) cylinder(h=washer_thickness+2*epsilon,d=washer_outer+epsilon); // washer
        union() { // marker hole
            translate([-marker_thickness/2,0,0]) cube([marker_thickness,box_size,washer_thickness/2+epsilon]);
            translate([0,0,washer_thickness/2+epsilon]) rotate([0,0,180]) rotate([90,0,0]) cylinder(r=marker_thickness/2, h=box_size);
        }
        rounded_inset(epsilon);
        
    } // difference
} // for



module rounded_inset(eps) {
    //eps is additional epsilon for spacing of the hole
    translate([0,3*epsilon,0])
    intersection() {
        difference() {
            cylinder(h=stamp_height*holder_height_ratio+eps,r=box_size/2+wall_thickness+3*epsilon+eps); // outer body
            translate([0,0,washer_thickness]) cylinder(h=stamp_height,r=box_size/2+epsilon/2-eps); // inner body with epsilon
        }
        translate([0,-box_size/2+wall_thickness/2+epsilon/4,stamp_height*holder_height_ratio-eps])
        rotate([90,0,0])
        cylinder(h=2*wall_thickness+eps,r=2*wall_thickness+eps);                
    }
}


module holes(width, depth, height, r, letters_count, stencil_nb, stencils) {
    
    //Top number
    text_on_cube(str(stencil_nb),cube_size=[box_size,box_size,height*2],face="top");


    for (i = [0:1:letters_count]){
        if (
            (i+1-stencil_nb)%stencils == 0 && // divisible per stencil_nb
            i*angle <= stencil_nb*angle+360-stencils*angle // last not in first
        ) {
            //Stamp hole
            rotate(i*-angle){
                translate([
                    -(stamp_width+epsilon)/2, r, -epsilon])
                cube([(stamp_width+epsilon), stamp_depth+epsilon, stamp_height+epsilon*2]);
               
            }
            //Number
            text_on_cylinder(str(i+1),font="LiberationMono:style=Bold",size=font_size,locn_vec=[0,0,height-font_size/2-wall_thickness/2],r=box_size/2,h=height,spacing=0.85,cylinder_center=true,eastwest=(-angle*i)-180+font_adj,extrusion_height=wall_thickness);
            
        }
    }

}