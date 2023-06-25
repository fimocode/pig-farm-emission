/**
* Name: Simulator
* Author: Lê Đức Toàn
*/


model Simulator


import './food-disease-config.gaml'
import './food-disease-pig.gaml'


global {
	file pigs;
	
    init {
    	pigs <- csv_file("../includes/input/food-disease-pigs.csv", true);
    	create FoodDiseasePigDC from: pigs;
        create Trough number: 5;
        loop i from: 0 to: 4 {
        	Trough[i].location <- trough_locs[i];
        }
        create FoodDiseaseConfig number: 1;
        FoodDiseaseConfig[0].day <- 14;
    }
    
    reflex stop when: cycle = 60 * 24 * 55 {
    	do pause;
    }
}

experiment DC {
    output {
        display Simulator {
            grid Background lines: #black;
            species FoodDiseasePigDC aspect: base;
        }
        display CFI refresh: every((60 * 24)#cycles) {
        	chart "CFI" type: series {
        		loop pig over: FoodDiseasePigDC {
        			data string(pig.id) value: pig.cfi;
        		}
        	}
        }
        display Weight refresh: every((60 * 24)#cycles) {
        	chart "Weight" type: histogram {
        		loop pig over: FoodDiseasePigDC {
        			data string(pig.id) value: pig.weight;
        		}
        	}
        }
        display CFIPig0 refresh: every((60 * 24)#cycles) {
        	chart "CFI vs Target CFI" type: series {
        		data 'CFI' value: FoodDiseasePigDC[0].cfi;
        		data 'Target CFI' value: FoodDiseasePigDC[0].target_cfi;
        	}
        }
        display DFIPig0 refresh: every((60 * 24)#cycles) {
        	chart "DFI vs Target DFI" type: series {
        		data 'DFI' value: FoodDiseasePigDC[0].dfi;
        		data 'Target DFI' value: FoodDiseasePigDC[0].target_dfi;
        	}
        }
    }
}