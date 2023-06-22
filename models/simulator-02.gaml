/**
* Name: Simulator
* Author: Lê Đức Toàn
*/


model Simulator

import './farm.gaml'
import './pig.gaml'

global {
    init {
    	file pigs <- csv_file("../includes/input/pigs.csv", true);
    	
        create Trough number: 1;
        
        create TransmitDiseasePig from: pigs;
    }
    
    reflex stop when: cycle = 60 * 24 * 55 {
    	do pause;
    }
}

experiment TransmitDisease {
	init {
		create TransmitDiseaseFactor number: 1;
		create BootVictim number: 1;
		ask TransmitDiseaseFactor {
			do infect_to(BootVictim[0]);
		}
	}
	
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
