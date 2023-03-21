/**
* Name: Pig
* Author: Lê Đức Toàn
*/


model Pig

import './farm.gaml'
import './factor.gaml'

/**
 * Pig behaviors table 
 *---------------------------------------------------
 * 
 * ID: Behavior ID
 * Name: Current behavior
 * Duration: Remain time before run trigger function
 * Next: Next behavior
 * 
 * --------------------------------------------------
 * ID | Name    | Duration     | Next
 * --------------------------------------------------
 * 0  | relax   | relax_time   | is_go_in: [0, 1]
 * 1  | go-in   | 0            | 2
 * 2  | wait    | 0            | is_eat: [2, 3]
 * 3  | eat     | eat_time     | is_go_out: [4]
 * 4  | go-out  | 0            | 5
 * 5  | relax   | satiety_time | is_drink: [6, 7]
 * 6  | drink   | 1            | 7
 * 7  | relax   | 0            | is_excrete: [8, 0]
 * 8  | excrete | excrete_time | 0
*/

species Pig {
    int id;
    
    float e;
    float a;
    float b;
    float fi;
    float init_weight;
    float weight;
    
    float target_dfi;
    float target_cfi;
    float dfi;
    float cfi;
    
    int excrete;
    
    int current;
    int duration;

    aspect base {
        draw circle(1.6) color: #pink;
        draw string(id) color: #black size: 5;
    }

    init {
        location <- { rnd(60.0, 95.0), rnd(60.0, 95.0) };
        
        e <- 2.72;
     	a <- rnd(312.0, 328.0);
     	b <- rnd(0.0011448, 0.0013152);
     	fi <- 0.0;
        init_weight <- rnd(20.0, 25.0);
        weight <- init_weight;
        
        target_dfi <- target_dfi();
        target_cfi <- target_cfi();
        dfi <- dfi();
        cfi <- cfi();
        
        excrete <- 0;
        
        current <- 0;
        duration <- relax_time();
    }

    reflex update {
    	if(duration = 0) {   		
	        if(current = 0) {
	        	do is_go_in();
	        }
	        else if(current = 1) {
	        	current <- 2;
	        }
	        else if(current = 2) {
	        	do is_eat();
	        }
	        else if(current = 3) {
	        	do is_go_out();
	        }
	        else if(current = 4) {
	        	location <- { rnd(60.0, 95.0), rnd(60.0, 95.0) };
	        	
	        	current <- 5;
	        	duration <- satiety_time();
	        }
	        else if(current = 5) {
	        	do is_drink();
	        }
	        else if(current = 6) {
	        	location <- { rnd(60.0, 95.0), rnd(60.0, 95.0) };
	        	
	        	current <- 7;
	        }
	        else if(current = 7) {
	        	do is_excrete();
	        }
	        else if(current = 8) {
	        	location <- { rnd(60.0, 95.0), rnd(60.0, 95.0) };
	        	
	        	current <- 0;
	        	duration <- relax_time();
	        }
        }
        else {
        	duration <- duration - 1;
        }
        if(mod(cycle, 60 * 24) = 0) {
        	weight <- weight();
        	
        	target_dfi <- target_dfi();
	        target_cfi <- target_cfi();
	        dfi <- dfi();
	        cfi <- cfi();
        }
    }
    
    /**
     * DFI, CFI and Weight calculators
     * *******************************
     */
     float target_dfi {
     	int ts <- 1;
     	int t <- int(cycle / (60 * 24));
     	
     	if(t < ts) {
     		return (2 + t * 0.5 / ts) with_precision 2;	
     	}
     	else {
     		return 2.5;
     	}
     }
     
     float target_cfi {
     	if(length(target_cfi) = 0) {
     		return target_dfi() with_precision 2;
     	}
     	else {
     		return (target_cfi + target_dfi()) with_precision 2;
     	}
     }
     
     float resistance {
     	return 0.0;
     }
     
     float resilience {
     	return 0.0;
     }
     
     float dfi {
     	float mean <- target_dfi() * (1 - resistance() + resilience());
     	return rnd(mean - 0.5, mean + 0.5) with_precision 2;
     }
     
     float cfi {
     	if(length(cfi) = 0) {
     		return dfi() with_precision 2;
     	}
     	else {
     		return (cfi + dfi()) with_precision 2;
     	}
     }
     
     float weight {
     	return (init_weight + (a * (1 - e ^ (-b * (cfi + fi))))) with_precision 2;
     }
    
    /**
     * Behavior calculators
     * ********************
     */
    int relax_time {
    	return 60 - mod(cycle, 60);
    }
    
    int eat_time {
    	return rnd(5, 15);
    }
    
    int satiety_time {
    	return rnd(5, 10);
    }
    
    int excrete_time {
    	return rnd(1, 2);
    }
    
    /**
     * Behavior actions
     * ****************
     */
    action is_go_in {
    	int hour <- int(mod(cycle, 60 * 24) / 60);
    	bool is_hungry <- flip((-0.0007 * hour ^ 4 + 0.0059 * hour ^ 3 + 0.2453 * hour ^ 2 + 0.0173 * hour + 4.0051) / 100);	
    	if(is_hungry) {
        	location <- { rnd(40.0, 48.0), rnd(48.0, 56.0) };
            current <- 1;
            duration <- 0;
        } else {
        	current <- 0;
        	duration <- relax_time();
        }
    }
    
    action is_eat {
    	ask Trough {
            int index <- add_pig(myself.id);
            if(index = -1) {
                myself.current <- 2;
                myself.duration <- 0;
            }
            else {
            	myself.location <- positions[index];
            	
                myself.current <- 3;
                myself.duration <- myself.eat_time();
            }
        }
    }
    
    action is_drink {
    	if(flip(0.5)) {
    		location <- { 2.0, rnd(60.0, 95.0) };
    		current <- 6;
    		duration <- 1;	
    	}
    	else {
    		current <- 7;
    		duration <- 0;
    	}
    }
    
    action is_excrete {
    	int day <- int(cycle / (60 * 24));
    	if(flip(0.5) and excrete < day * 3) {
    		excrete <- excrete + 1;
    		
    		location <- { rnd(10.0, 40.0), rnd(60.0, 95.0) };
    		
    		current <- 8;
    		duration <- excrete_time();
    	}
    	else {
    		current <- 0;
    		duration <- relax_time();
    	}
    }
    
    action is_go_out {
    	ask Trough {
    		do remove_pig(myself.id);
    	}
    	
    	location <- gate_out;
    	
    	current <- 4;
    }
    /* **************** */
}

/**
 * Pig is infected by mycotoxins.
 */
species FoodDiseasePig parent: Pig {
	string is_resilience;
	
	init {
		is_resilience <- 'never';
	}
	
	aspect base {
        draw circle(1.6) color: is_resilience = 'pending' ? #red : #pink;
        draw string(id) color: #black size: 5;
    }
    
    /**
     * Behaviour actions
     */
    action is_eat {
    	ask Trough {
            int index <- add_pig(myself.id);
            if(index = -1) {
                myself.current <- 2;
                myself.duration <- 0;
            }
            else {
            	myself.location <- positions[index];
            	
                myself.current <- 3;
                myself.duration <- myself.eat_time();
            }
        }
        bool is_infect <- false;
        loop factor over: Factor {
        	if (factor.duration > 0) {
        		is_infect <- true;
        		break;
        	}
        }
        if(is_infect and is_resilience = 'never') {
        	is_resilience <- 'pending';
        }
        if(!is_infect and is_resilience = 'pending') {
        	is_resilience <- 'ready';
        }
    }
	
	float resistance {
		float value <- 0.0;
		if (is_resilience = 'pending') {
			value <- 0.3;
		}
		return value;
    }
     
     float resilience {
     	float k <- 3.0;
     	
     	float value <- 0.0;
     	if(is_resilience = 'ready') {
     		value <- (k * (1 - cfi / target_cfi)) with_precision 2;	
     	}
     	return value;
     }
}