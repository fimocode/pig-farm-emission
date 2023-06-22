/**
* Name: Farm
* Author: Lê Đức Toàn
*/


model Farm

import './factor.gaml'

global {	
	file background <- image_file("../includes/images/background.png");
	
	point gate_out <- { 95.0, 48.0 };
	list<point> positions <- [{51.0, 22.0}, {58.5, 22.0}, {68.0, 22.0}, {76.0, 22.0}, {85.0, 22.0}];
}

grid Background width: 64 height: 64 neighbors: 8 {
	rgb color <- rgb(background at { grid_x, grid_y });
}

species Trough {
	list<int> slots;
	
	init {
		slots <- [-1, -1, -1, -1, -1];
	}
	
	int add_pig(int id) {
        loop i from: 0 to: 4 {
            if(slots[i] = -1) {
                slots[i] <- id;
                return i;
            }
        }
        return -1;
    }

    action remove_pig(int id) {
        loop i from: 0 to: 4 {
            if(slots[i] = id) {
                slots[i] <- -1;
                break;
            }
        }
    }
}

species Config {
	string scenario;
	
	init {
		scenario <- 'normal';
	}
	
	float resistance {
		if(scenario = 'dc') {
			return 0.46;
		}
		if (scenario = 'cd') {
			return 0.42;
		}
		if (scenario = 'dd' and int(cycle / (60 * 24)) <= 35) {
			return 0.46;
		}
		if (scenario = 'dd') {
			return 0.31;
		}
		return 0.0;
	}
	
	float resilience {
		if(scenario = 'dc') {
			return 0.81;
		}
		if (scenario = 'cd') {
			return 1.59;
		}
		if (scenario = 'dd' and int(cycle / (60 * 24)) <= 35) {
			return 0.90;
		}
		if (scenario = 'dd') {
			return 2.36;
		}
		return 0.0;
	}
}

species BootVictim {
	init {
		location <- {rnd(60.0, 95.0), rnd(60.0, 95.0)};
	}
}