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
		return distance_to(position, location) <= 2.0 and duration > 0;
	}
}

species TransmitDiseaseFactor parent: Factor {
	int incubation;
	agent victim;
	
	init {
		incubation <- rnd(5, 15) * 24 * 60;
		duration <- incubation + rnd(3, 4) * 60 * 24;
		victim <- nil;
	}
	
	bool is_infect(agent pig) {
		return (distance_to(pig.location, location) <= 2.0 and incubation = -1 and duration > 0) or victim = pig;
	}
	
	action infect_to(agent pig) {
		victim <- pig;
	}
	
	bool is_expose(agent pig) {
		return victim = pig;
	}
	
	bool is_sick(agent pig) {
		return victim = pig and incubation = -1 and duration > 0;
	}
	
	action follow {
		ask Background at_distance(2.0) {
			self.color <- rgb(background at { grid_x, grid_y });
		}
		ask victim {
			myself.location <- location;
		}
	}
	
	reflex spread {
		if(incubation >= 0) {
			incubation <- incubation - 1;
		}
	}
	
	reflex infect {
		if(victim != nil) {
			do follow();
		}
	}
	
	reflex update {
		if(duration > 0 and incubation = -1) {
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
	
	reflex remove {
		if(incubation = -1 and duration = 0) {
			ask Background at_distance(2.0) {
				self.color <- rgb(background at { grid_x, grid_y });
			}
			do die;
		}
	}
}