/**
* Name: Pig
* Author: Lê Đức Toàn
*/


model Pig

import './farm.gaml'

species Pig {
    int id;
    float init_weight;
    float weight;
    float dfi;
    float cfi;
    string current;
    int duration;
    string next;
    bool excreted;

    aspect base {
            draw circle(1.6) color: #pink;
            draw string(id) color: #black size: 5;
    }

    init {
        location <- { rnd(60.0, 95.0), rnd(60.0, 95.0) };
        init_weight <- rnd(20.0, 30.0);
        weight <- init_weight;
        cfi <- 0.0;
        excreted <- false;
        current <- 'relax';
        duration <- 0;
        next <- 'go-in';
    }

    reflex update {
    	if(duration = 0) {   		
	        if(current = 'relax') {
	        	do relax();
	        }
	        else if(current = 'go-in') {
	        	do go_in();
	        }
	        else if(current = 'wait') {
	        	do wait();
	        }
	        else if(current = 'eat') {
	        	do eat();
	        }
	        else if(current = 'go-out') {
	        	do go_out();
	        }
	        else if(current = 'drink') {
	        	do drink();
	        }
	        else if(current = 'excrete') {
	        	do excrete();
	        }
        }
        else {
        	duration <- duration - 1;
        }
    }
    
    action relax {
    	int hour <- int(mod(cycle, 60 * 24) / 60);
    	
    	if(next = 'go-in') {
	        bool is_hungry <- flip((-0.0007 * hour ^ 4 + 0.0059 * hour ^ 3 + 0.2453 * hour ^ 2 + 0.0173 * hour + 4.0051) / 100);
	        if(is_hungry) {
	        	location <- { rnd(40.0, 48.0), rnd(48.0, 56.0) };
	        	
	            current <- 'go-in';
	            duration <- 0;
	            next <- 'wait';
	        }
	        else {
	        	current <- 'relax';
	        	duration <- 60;
	        	next <- 'go-in';
	        }
        }
        else if(next = 'drink') {
        	location <- { 2.0, rnd(60.0, 95.0) };
        	
        	current <- 'drink';
        	duration <- 0;
        	next <- 'relax';
        }
        else if(next = 'excrete') {
        	excreted <- true;
    		location <- { rnd(10.0, 40.0), rnd(60.0, 95.0) };
    		
    		current <- 'excrete';
        	duration <- 0;
        	next <- 'relax';
        }
        
        if(hour = 0) {
        	excreted <- false;
        }
    }
    
    action go_in {
    	current <- 'wait';
    	duration <- 0;
    	next <- 'eat';
    }
    
    action wait {
    	ask Trough {
            int index <- add_pig(myself.id);
            if(index = -1) {
                myself.current <- 'wait';
                myself.duration <- 0;
                myself.next <- 'eat';
            } else {
            	myself.location <- positions[index];
            	
                myself.current <- 'eat';
                myself.duration <- rnd(5, 30);
                myself.next <- 'go-out';
            }
        }
    }
    
    action eat {
    	ask Trough {
    		do remove_pig(myself.id);
    	}
    	
    	location <- gate_out;
    	
    	current <- 'go-out';
    	duration <- 0;
    	next <- 'relax';
    }
    
    action go_out {
    	location <- { rnd(60.0, 95.0), rnd(60.0, 95.0) };
	        	
    	current <- 'relax';
    	duration <- rnd(8, 12);
    	next <- 'drink';
    }
    
    action drink {
    	location <- { rnd(60.0, 95.0), rnd(60.0, 95.0) };
    	
    	if(!excreted and flip(0.5)) {
    		current <- 'relax';
    		duration <- rnd(0, 30);
    		next <- 'excrete';
    	}
    	else {
    		current <- 'relax';
    		duration <- 60 - mod(cycle, 60);
    		next <- 'go-in';
    	}
    }
    
    action excrete {
    	location <- { rnd(60.0, 95.0), rnd(60.0, 95.0) };
    	
    	current <- 'relax';
    	duration <- 60 - mod(cycle, 60);
    	next <- 'go-in';
    }
}