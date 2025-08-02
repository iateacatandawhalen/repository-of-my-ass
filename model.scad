// Raspberry Pi 5 Laptop Shell
// Draft v0.2 by ChatGPT for Leakproof
// Features: Base, Display lid, LoRa module mount, Antenna passthrough

// === Parameters ===
pi_length = 88;
pi_width = 56;
pi_height = 25;

wall = 3;
base_thickness = 5;
laptop_width = 240;
laptop_depth = 160;
laptop_height = 25;

display_width = 220;
display_height = 130;
display_depth = 6;

lora_w = 18;
lora_h = 16;
lora_hole_d = 2.2;

antenna_d = 7; // SMA connector

$fn = 32; // Smoother circles

// === Modules ===

module pi_mount() {
    translate([wall, wall, base_thickness])
        cube([pi_length, pi_width, pi_height]);
}

module display_frame() {
    difference() {
        cube([laptop_width, laptop_depth, wall * 2]);

        // Screen window
        translate([(laptop_width - display_width)/2,
                   (laptop_depth - display_height)/2,
                   wall])
            cube([display_width, display_height, wall * 2]);
    }
}

module lora_mount() {
    translate([wall + 10, wall + 10, wall]) {
        // Mounting platform
        cube([lora_w, lora_h, 2]);

        // Mounting holes
        translate([2, 2, -1])
            cylinder(h=4, d=lora_hole_d);
        translate([lora_w - 2, 2, -1])
            cylinder(h=4, d=lora_hole_d);
    }
}

module antenna_hole() {
    translate([laptop_width - wall - 8, laptop_depth/2, laptop_height/2])
        rotate([90, 0, 0])
            cylinder(h=wall + 2, d=antenna_d);
}

module laptop_base() {
    difference() {
        // Main body
        cube([laptop_width, laptop_depth, laptop_height]);

        // Raspberry Pi cavity
        translate([(laptop_width - pi_length)/2, wall, wall])
            cube([pi_length, pi_width, pi_height + 2]);

        // Vent holes
        for(i = [0:5]) {
            translate([wall + i * 10, laptop_depth - wall - 5, laptop_height - 3])
                c
