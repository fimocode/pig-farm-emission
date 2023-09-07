/**
* Name: Simulator
* Author: Lê Đức Toàn
*/


model Simulator


import './farm.gaml'
import './pig.gaml'


global {
	int speed;
	string experiment_id;
	
    init {
    	file pigs <- csv_file("../includes/input/pigs.csv", true);
    	speed <- 45;
    	
    	create Pig from: pigs;
        create Trough number: 5;
        loop i from: 0 to: 4 {
        	Trough[i].location <- trough_locs[i];
        }
    }
    
    reflex stop when: cycle = 60 * 24 * 120 {
    	do pause;
    }
}

experiment Normal {
	parameter "Experiment ID" var: experiment_id <- "";
    output {
        display Simulator autosave: mod(cycle, speed) = 0 ? experiment_id + "-simulator-normal-" + string(cycle) : nil {
            grid Background border: #black;
            species Pig aspect: base;
        }
        display CFI autosave: mod(cycle, 24 * 60) = 0 ? experiment_id + "-cfi-normal-" + string(mod(cycle, 24 * 60)) : nil refresh: every((60 * 24)#cycles) {
        	chart "CFI" type: series {
        		loop pig over: Pig {
        			data string(pig.id) value: pig.cfi;
        		}
        	}
        }
        display Weight autosave: mod(cycle, 24 * 60) = 0 ? experiment_id + "-weight-normal-" + string(mod(cycle, 24 * 60)) : nil refresh: every((60 * 24)#cycles) {
        	chart "Weight" type: histogram {
        		loop pig over: Pig {
        			data string(pig.id) value: pig.weight;
        		}
        	}
        }
        display CFIPig0 autosave: mod(cycle, 24 * 60) = 0 ? experiment_id + "-cfipig0-normal-" + string(mod(cycle, 24 * 60)) : nil refresh: every((60 * 24)#cycles) {
        	chart "CFI vs Target CFI" type: series {
        		data 'CFI' value: Pig[0].cfi;
        		data 'Target CFI' value: Pig[0].target_cfi;
        	}
        }
        display DFIPig0 autosave: mod(cycle, 24 * 60) = 0 ? experiment_id + "-dfipig0-normal-" + string(mod(cycle, 24 * 60)) : nil refresh: every((60 * 24)#cycles) {
        	chart "DFI vs Target DFI" type: series {
        		data 'DFI' value: Pig[0].dfi;
        		data 'Target DFI' value: Pig[0].target_dfi;
        	}
        }
    }
    
    reflex log when: mod(cycle, 24 * 60) = 0 {
    	ask simulations {
    		loop pig over: Pig {
    			save [
    				floor(cycle / (24 * 60)),
    				pig.id,
    				pig.target_dfi,
    				pig.dfi,
    				pig.target_cfi,
    				pig.cfi,
    				pig.weight,
    				pig.eat_count,
    				pig.excrete_each_day,
    				pig.excrete_count
    			] to: "../includes/output/normal/" + experiment_id + "-"  + string(pig.id) + ".csv" rewrite: false format: "csv";	
    		}
		}		
    }
}