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
        create Pig from: pigs;
        create PerturbationPig from: pigs;
    }
    
    reflex stop {
    	if(cycle = 60 * 24 * 120) {
    		do pause;
    	}
    }
}

experiment Normal {
    output {
        display Simulator {
            grid Background lines: #black;
            species Pig aspect: base;
        }
        display CFI refresh: every((60 * 24)#cycles) {
        	chart "CFI" type: series {
        		loop pig over: Pig {
        			data string(pig.id) value: pig.cfi;
        		}
        	}
        }
        display Weight refresh: every((60 * 24)#cycles) {
        	chart "Weight" type: histogram {
        		loop pig over: Pig {
        			data string(pig.id) value: pig.weight;
        		}
        	}
        }
        display CFIPig0 refresh: every((60 * 24)#cycles) {
        	chart "CFI vs Target CFI" type: series {
        		data 'CFI' value: Pig[0].cfi;
        		data 'Target CFI' value: Pig[0].target_cfi;
        	}
        }
        display DFIPig0 refresh: every((60 * 24)#cycles) {
        	chart "DFI vs Target DFI" type: series {
        		data 'DFI' value: Pig[0].dfi;
        		data 'Target DFI' value: Pig[0].target_dfi;
        	}
        }
    }
}

experiment Perturbation {
    output {
        display Simulator {
            grid Background lines: #black;
            species PerturbationPig aspect: base;
        }
        display CFI refresh: every((60 * 24)#cycles) {
        	chart "CFI" type: series {
        		loop pig over: PerturbationPig {
        			data string(pig.id) value: pig.cfi;
        		}
        	}
        }
        display Weight refresh: every((60 * 24)#cycles) {
        	chart "Weight" type: histogram {
        		loop pig over: PerturbationPig {
        			data string(pig.id) value: pig.weight;
        		}
        	}
        }
        display CFIPig0 refresh: every((60 * 24)#cycles) {
        	chart "CFI vs Target CFI" type: series {
        		data 'CFI' value: PerturbationPig[0].cfi;
        		data 'Target CFI' value: PerturbationPig[0].target_cfi;
        	}
        }
        display DFIPig0 refresh: every((60 * 24)#cycles) {
        	chart "DFI vs Target DFI" type: series {
        		data 'DFI' value: PerturbationPig[0].dfi;
        		data 'Target DFI' value: PerturbationPig[0].target_dfi;
        	}
        }
    }
}