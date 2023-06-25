/**
* Name: Simulator
* Author: Lê Đức Toàn
*/


model Simulator


import './transmit-disease-config.gaml'
import './transmit-disease-pig.gaml'


global {
	file pigs;
	
    init {
    	pigs <- csv_file("../includes/input/food-disease-pigs.csv", true);
    	create TransmitDiseasePig from: pigs;
        create Trough number: 5;
        loop i from: 0 to: 4 {
        	Trough[i].location <- trough_locs[i];
        }
        create TransmitDiseaseConfig number: 1;
        TransmitDiseaseConfig[0].day <- 1;
    }
    
    reflex stop when: cycle = 60 * 24 * 55 {
    	do pause;
    }
}

experiment Transmit {
    output {
        display Simulator {
            grid Background lines: #black;
            species TransmitDiseasePig aspect: base;
        }
        display CFI refresh: every((60 * 24)#cycles) {
        	chart "CFI" type: series {
        		loop pig over: TransmitDiseasePig {
        			data string(pig.id) value: pig.cfi;
        		}
        	}
        }
        display Weight refresh: every((60 * 24)#cycles) {
        	chart "Weight" type: histogram {
        		loop pig over: TransmitDiseasePig {
        			data string(pig.id) value: pig.weight;
        		}
        	}
        }
        display CFIPig0 refresh: every((60 * 24)#cycles) {
        	chart "CFI vs Target CFI" type: series {
        		data 'CFI' value: TransmitDiseasePig[0].cfi;
        		data 'Target CFI' value: TransmitDiseasePig[0].target_cfi;
        	}
        }
        display DFIPig0 refresh: every((60 * 24)#cycles) {
        	chart "DFI vs Target DFI" type: series {
        		data 'DFI' value: TransmitDiseasePig[0].dfi;
        		data 'Target DFI' value: TransmitDiseasePig[0].target_dfi;
        	}
        }
    }
}