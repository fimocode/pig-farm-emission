/**
* Name: TransmitDiseasePig
*  
* Author: Lê Đức Toàn
* Tags: 
*/


model TransmitDiseasePig

/* Insert your model definition here */


import './disease-pig.gaml'
import './transmit-disease-factor.gaml'
import './transmit-disease-config.gaml'


species TransmitDiseasePig parent: DiseasePig {
	agent factor;
	
	init {
		factor <- nil;
		
		max_expose_time <- 15 * 24 * 60;
		avg_expose_time <- 10 * 24 * 60;
		max_infect_time <- 5 * 24 * 60;
		avg_infect_time <- 4 * 24 * 60;
		max_shed_time <- 365 * 24 * 60;
		avg_shed_time <- 365 * 24 * 60;
		
		u <- 0.4;
		
		k1 <- 0.46;
		k2 <- 0.81;
	}
	
	action expose {
		ask TransmitDiseaseFactor {
			if(expose(myself)) {
				myself.seir <- 1;
				myself.expose_count <- myself.expose_count + 1;
			}
		}
	}
	
	action infect {
		invoke infect();
		if(seir = 2) {
			ask TransmitDiseaseConfig {
				myself.factor <- create_factor_and_attach_to(myself);
			}	
		}
	}
	
	bool is_hungry {
		if(seir = 1) {
			return flip(0.5) and super.is_hungry();	
		}
		else if(seir = 2) {
			return false;
		}
		else {
			return super.is_hungry();
		}
	}
	
	reflex remove when: seir = 3 or seir = 4 {
		ask factor as TransmitDiseaseFactor {
			do remove();
		}
	}
}