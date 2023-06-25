/**
* Name: Farm
* Author: Lê Đức Toàn
*/


model Farm

import './factor.gaml'

global {
	file background <- image_file("../includes/images/background.png");
	list<point> trough_locs <- [{51.0, 22.0}, {58.5, 22.0}, {68.0, 22.0}, {76.0, 22.0}, {85.0, 22.0}];
}

grid Background width: 64 height: 64 neighbors: 8 {
	rgb color <- rgb(background at { grid_x, grid_y });
}

//species BootVictim {
//	init {
//		location <- {rnd(60.0, 95.0), rnd(60.0, 95.0)};
//	}
//}