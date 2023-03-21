/**
* Name: Factor
* Author: Lê Đức Toàn
*/


model Factor

import './farm.gaml'

/* Insert your model definition here */

species Factor {
	int duration;
	
	init {
		duration <- 0;
	}
	
	reflex update {
		if(duration > 0) {
			ask Background at_distance(2.0) {
				self.color <- #lightyellow;
			}
			duration <- duration - 1;
		}
		else {
			ask Background at_distance(2.0) {
				self.color <- rgb(background at { grid_x, grid_y });
			}
		}
	}
}

species FoodDiseaseFactor {	
	reflex update when: cycle mod (60 * 24) = 0 and int(cycle / (60 * 24)) = 40 {
		create Factor number: 5;
		loop i from: 0 to: 4 {
			Factor[i].location <- positions[i];	
			Factor[i].duration <- 10 * 60 * 24;
		}
	}
}