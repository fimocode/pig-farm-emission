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

species FoodDiseaseFactorDC parent: Factor {	
	reflex spread when: cycle mod (60 * 24) = 0 and int(cycle / (60 * 24)) = 14 {
		duration <- 7 * 60 * 24;
	}
	
	bool is_infect(point position) {
		if(distance_to(position, location) <= 2.0 and duration > 0) {
			return true;
		} else {
			return false;
		}
	}
}

species FoodDiseaseFactorCD parent: Factor {	
	reflex spread when: cycle mod (60 * 24) = 0 and int(cycle / (60 * 24)) = 35 {
		duration <- 7 * 60 * 24;
	}
	
	bool is_infect(point position) {
		if(distance_to(position, location) <= 2.0 and duration > 0) {
			return true;
		} else {
			return false;
		}
	}
}