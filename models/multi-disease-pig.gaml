/**
* Name: MultiDiseasePig
* Author: Lê Đức Toàn
*/


model MultiDiseasePig


import './disease-pig.gaml'


species AbstractDiseasePig parent: DiseasePig {
	aspect base {}
	
	reflex routine {
    	do seir_routine();
    	do seir_refresh_per_day();
    }
}


species MultiDiseasePig parent: DiseasePig {
	list<AbstractDiseasePig> abstracts; // order by severity increase
	list<AbstractDiseasePig> resistances;
	list<AbstractDiseasePig> resiliences;
	
	init {
		resistances <- [];
		resiliences <- [];
	}
	
	/**
	 * Util functions
	 */
	action aggregate_from_abstracts {
		loop abstract over: abstracts {
			if((abstract.expose_count_per_day > 0 or abstract.seir = 2 or abstract.seir = 1) and !contains(resiliences, abstract)) {
				add abstract to: resistances;
			}
			if(
				abstract.expose_count_per_day = 0 and
				abstract.recover_count > 0 and
				(abstract.seir = 0 or abstract.seir = 3) and
				!contains(resiliences, abstract)
			) {
				add abstract to: resiliences;
			}
			expose_count_per_day <- expose_count_per_day + abstract.expose_count_per_day;
		}
		
		seir <- 0;
		loop abstract over: resistances {
			if(abstract.seir > seir) {
				seir <- abstract.seir;
			}
		}
		if(all_match(abstracts, each.seir = 3)) {
			seir <- 3;
		}
	}

	action sync_to_abstracts {
		loop abstract over: abstracts {
			abstract.id <- id;
    
		    abstract.a <- a;
		    abstract.b <- b;
		    abstract.fi <- fi;
		    abstract.init_weight <- init_weight; 
		    abstract.weight <- weight;
		    
		    abstract.target_dfi <- target_dfi;
		    abstract.target_cfi <- target_cfi;
		    abstract.dfi <- dfi;
		    abstract.cfi <- cfi;
		    
		    abstract.current <- current;
		    abstract.duration <- duration;
		    
		    abstract.excrete_count <- excrete_count;
		    abstract.eat_count <- eat_count;
		    
		    abstract.excrete_each_day <- excrete_each_day;
		    
		    abstract.location <- location;
		}
	}
	/*****/
	
	/**
	 * Event loop functions
	 */
	action seir_refresh_per_day {
		invoke seir_refresh_per_day();
		resistances <- [];
	}
	/*****/
	
	reflex routine {
		do sync_to_abstracts();
		do aggregate_from_abstracts();
    	do normal_routine();
    	do refresh_per_day();
    	do seir_refresh_per_day();
    }
}
