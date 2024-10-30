model Pig

import './config.gaml'
import './trough.gaml'
import './farm.gaml'

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
 * 0  | relax   | relax_time   | go_in: [0, 1]
 * 1  | go-in   | 0            | wait: [2]
 * 2  | wait    | 0            | eat: [2, 3]
 * 3  | eat     | eat_time     | go_out: [4]
 * 4  | go-out  | 0            | relax_after_eat: [5]
 * 5  | relax   | satiety_time | drink: [6, 7]
 * 6  | drink   | 1            | relax_after_drink: [7]
 * 7  | relax   | 0            | excrete: [8, 0]
 * 8  | excrete | excrete_time | relax_after_excrete: [0]
 * 9  | die     |
*/
species Pig {
	int id;
	float a; // params to calculate weight
	float b; // params to calculate weight
	float fi; // weight shift. should leave it equals 0
	float init_weight;
	float weight;
	float target_dfi;
	float target_cfi;
	float dfi;
	float cfi;
	int current;
	int duration;
	int excrete_count;
	int eat_count;
	int excrete_each_day;

	// Feed details
	list<float> feed_starter_composition;
	list<float> feed_grower_composition;
	list<float> feed_finisher_composition;
	list<float> feed_me;
	list<float> feed_ne;
	list<float> feed_resD;

	// Emission attributes
	float daily_co2_emission; // Daily CO2 emission from respiration (kg)
	float daily_ch4_emission; // Daily CH4 emission from fermentation (kg)
	float cumulative_co2_emission; // Total CO2 emission (kg)
	float cumulative_ch4_emission; // Total CH4 mission (kg)
	aspect base {
		draw image("../includes/images/pig.png") size: 5.0;
		draw string(id) color: #black size: 6;
	}

	init {
		location <- get_relax_loc();
		a <- rnd(312.0, 328.0);
		b <- rnd(0.0011448, 0.0013152);
		fi <- 0.0;
		init_weight <- get_init_weight();
		weight <- init_weight;
		target_dfi <- target_dfi();
		target_cfi <- target_cfi();
		dfi <- dfi();
		cfi <- cfi();
		excrete_count <- 0;
		eat_count <- 0;
		excrete_each_day <- get_excrete_per_day();
		current <- 0;
		duration <- relax_time();

		// feed composition calculator
		file feed_composition_file <- csv_file("../includes/input/feed-composition.csv", true);
		file feed_composition_data_file <- csv_file("../includes/input/feed-composition-data.csv", true);
		feed_starter_composition <- (list(feed_composition_file.contents) copy_between (0, 13)) collect float(each);
		feed_grower_composition <- (list(feed_composition_file.contents) copy_between (13, 26)) collect float(each);
		feed_finisher_composition <- (list(feed_composition_file.contents) copy_between (26, 39)) collect float(each);
		feed_me <- (list(feed_composition_data_file.contents) copy_between (1, 14)) collect float(each);
		feed_ne <- (list(feed_composition_data_file.contents) copy_between (15, 28)) collect float(each);
		feed_resD <- (list(feed_composition_data_file.contents) copy_between (29, 42)) collect float(each);
		daily_co2_emission <- daily_co2_emission();
		daily_ch4_emission <- daily_ch4_emission();
		cumulative_co2_emission <- cumulative_co2_emission();
		cumulative_ch4_emission <- cumulative_ch4_emission();
	}

	/**
     * Get location functions
     */
	point get_relax_loc {
		return {rnd(60.0, 95.0), rnd(60.0, 95.0)};
	}

	point get_gate_in_loc {
		return {rnd(40.0, 48.0), rnd(48.0, 56.0)};
	}

	point get_gate_out_loc {
		return {95.0, 48.0};
	}

	point get_drink_loc {
		return water_locs[rnd(length(water_locs) - 1)];
	}

	point get_excrete_loc {
		return {rnd(10.0, 40.0), rnd(60.0, 95.0)};
	}
	/*****/

	/**
     * Util functions
     */
	int get_hour {
		return int(mod(cycle, 60 * 24) / 60);
	}

	int get_day {
		return int(cycle / (60 * 24));
	}

	bool is_hungry {
		int hour <- get_hour();
		return flip((-0.0007 * hour ^ 4 + 0.0059 * hour ^ 3 + 0.2453 * hour ^ 2 + 0.0173 * hour + 4.0051) / 100);
	}

	bool is_start_of_day {
		return mod(cycle, 60 * 24) = 0;
	}

	int get_excrete_per_day {
		return rnd(2, 4);
	}

	float get_init_weight {
		return rnd(20.0, 25.0) with_precision 2;
	}
	/*****/

	/**
     * Get time functions
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
	/*****/

	/**
     * Behaviour actions
     */
	action go_in {
		if (is_hungry()) {
			location <- get_gate_in_loc();
			current <- 1;
			duration <- 0;
		} else {
			current <- 0;
			duration <- relax_time();
		}

	}

	action wait {
		current <- 2;
	}

	action eat {
		ask Trough {
			if (add_pig(myself)) {
				myself.location <- location;
				myself.current <- 3;
				myself.duration <- myself.eat_time();
				myself.eat_count <- myself.eat_count + 1;
				break;
			}

		}

	}

	action go_out {
		ask Trough {
			do remove_pig(myself);
		}

		location <- get_gate_out_loc();
		current <- 4;
	}

	action relax_after_eat {
		location <- get_relax_loc();
		current <- 5;
		duration <- satiety_time();
	}

	action drink {
		if (flip(0.8)) {
			location <- get_drink_loc();
			current <- 6;
			duration <- 1;
		} else {
			current <- 7;
			duration <- 0;
		}

	}

	action relax_after_drink {
		location <- get_relax_loc();
		current <- 7;
	}

	action excrete {
		int day <- get_day();
		if (flip(0.5) and excrete_count < 3) {
			excrete_count <- excrete_count + 1;
			location <- get_excrete_loc();
			current <- 8;
			duration <- excrete_time();
		} else {
			current <- 0;
			duration <- relax_time();
		}

	}

	action relax_after_excrete {
		location <- get_relax_loc();
		current <- 0;
		duration <- relax_time();
	}

	/*****/

	/**
     * DFI, CFI and Weight calculators
     * *******************************
     */
	float target_dfi {
		int ts <- 25;
		int t <- get_day();
		if (t < ts) {
			return (2 + t * 1 / ts) with_precision 2;
		} else {
			return 3.0;
		}

	}

	float target_cfi {
		if (length(target_cfi) = 0) {
			return target_dfi() with_precision 2;
		} else {
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
		if (eat_count = 0 and cycle > 0) {
			return 0.0;
		}

		float mean <- target_dfi() * (1 - resistance() + resilience());
		return max(0, rnd(mean - 0.5, mean + 0.5)) with_precision 3;
	}

	float cfi {
		if (length(cfi) = 0) {
			return dfi with_precision 2;
		}

		return (cfi + dfi) with_precision 2;
	}

	float weight {
		return (init_weight + (a * (1 - e ^ (-b * (cfi + fi))))) with_precision 2;
	}

	/*****/
	/**
     * Feed composition during phases calculators
     * *******************************
     */

// Starter phase
	float me_starter_phase {
		float me_starter_value <- 0.0;
		loop i from: 0 to: length(feed_me) - 1 {
			me_starter_value <- me_starter_value + feed_me[i] * feed_starter_composition[i] * dfi / 100;
		}

		return me_starter_value;
	}

	float ne_starter_phase {
		float ne_starter_value <- 0.0;
		loop i from: 0 to: length(feed_ne) - 1 {
			ne_starter_value <- ne_starter_value + feed_ne[i] * feed_starter_composition[i] * dfi / 100;
		}

		return ne_starter_value;
	}

	float resD_starter_phase {
		float resD_starter_value <- 0.0;
		loop i from: 0 to: length(feed_resD) - 1 {
			resD_starter_value <- resD_starter_value + feed_resD[i] * feed_starter_composition[i] * dfi / 100;
		}

		return resD_starter_value;
	}

	// Grower phase
	float me_grower_phase {
		float me_grower_value <- 0.0;
		loop i from: 0 to: length(feed_me) - 1 {
			me_grower_value <- me_grower_value + feed_me[i] * feed_grower_composition[i] * dfi / 100;
		}

		return me_grower_value;
	}

	float ne_grower_phase {
		float ne_grower_value <- 0.0;
		loop i from: 0 to: length(feed_ne) - 1 {
			ne_grower_value <- ne_grower_value + feed_ne[i] * feed_grower_composition[i] * dfi / 100;
		}

		return ne_grower_value;
	}

	float resD_grower_phase {
		float resD_grower_value <- 0.0;
		loop i from: 0 to: length(feed_resD) - 1 {
			resD_grower_value <- resD_grower_value + feed_resD[i] * feed_grower_composition[i] * dfi / 100;
		}

		return resD_grower_value;
	}

	// Finisher phase
	float me_finisher_phase {
		float me_finisher_value <- 0.0;
		loop i from: 0 to: length(feed_me) - 1 {
			me_finisher_value <- me_finisher_value + feed_me[i] * feed_finisher_composition[i] * dfi / 100;
		}

		return me_finisher_value;
	}

	float ne_finisher_phase {
		float ne_finisher_value <- 0.0;
		loop i from: 0 to: length(feed_ne) - 1 {
			ne_finisher_value <- ne_finisher_value + feed_ne[i] * feed_finisher_composition[i] * dfi / 100;
		}

		return ne_finisher_value;
	}

	float resD_finisher_phase {
		float resD_finisher_value <- 0.0;
		loop i from: 0 to: length(feed_resD) - 1 {
			resD_finisher_value <- resD_finisher_value + feed_resD[i] * feed_finisher_composition[i] * dfi / 100;
		}

		return resD_finisher_value;
	}

	/*****/

	/*****/
	/**
     * CO2 and CH4 calculators
     * *******************************
     */
	float daily_co2_emission {
		if dfi = 0.0 {
			float heat_prod <- 750 * weight ^ 0.6;
			return 24 * 0.163 * heat_prod / 1000 / 86.4 * 44 / 22.4 with_precision 4;
		}

		float me <- 0.0;
		float ne <- 0.0;
		if (weight <= 35) {
			me <- me_starter_phase();
			ne <- ne_starter_phase();
		} else if (weight > 35 and weight <= 55) {
			me <- me_grower_phase();
			ne <- ne_grower_phase();
		} else {
			me <- me_finisher_phase();
			ne <- ne_finisher_phase();
		}

		float heat_prod <- 750 * weight ^ 0.6 + (1 - ne / me) * me * dfi;
		return 24 * 0.163 * heat_prod / 1000 / 86.4 * 44 / 22.4 with_precision 4;
	}

	float daily_ch4_emission {
		if dfi = 0.0 {
			return 0.0;
		}

		float resD <- 0.0;
		if (weight <= 35.0) {
			resD <- resD_starter_phase();
		} else if (weight > 35.0 and weight <= 55.0) {
			resD <- resD_grower_phase();
		} else {
			resD <- resD_finisher_phase();
		}

		return resD * dfi * 670 / 1000 / 56.65 with_precision 4;
	}

	float cumulative_co2_emission {
		if (cumulative_co2_emission = 0.0) {
			return daily_co2_emission with_precision 4;
		}

		return (cumulative_co2_emission + daily_co2_emission) with_precision 4;
	}

	float cumulative_ch4_emission {
		if (cumulative_ch4_emission = 0.0) {
			return daily_ch4_emission with_precision 4;
		}

		return (cumulative_ch4_emission + daily_ch4_emission) with_precision 4;
	}

	/*****/

	/**
     * Event loop functions
     */
	action normal_routine {
		if (duration = 0) {
			if (current = 0) {
				do go_in();
			} else if (current = 1) {
				do wait();
			} else if (current = 2) {
				do eat();
			} else if (current = 3) {
				do go_out();
			} else if (current = 4) {
				do relax_after_eat();
			} else if (current = 5) {
				do drink();
			} else if (current = 6) {
				do relax_after_drink();
			} else if (current = 7) {
				do excrete();
			} else if (current = 8) {
				do relax_after_excrete();
			} } else {
			duration <- duration - 1;
		} }

	action refresh_per_day {
		if (is_start_of_day()) {
			weight <- weight();
			target_dfi <- target_dfi();
			target_cfi <- target_cfi();
			dfi <- dfi();
			cfi <- cfi();
			eat_count <- 0;
			excrete_count <- 0;
			excrete_each_day <- get_excrete_per_day();
			daily_co2_emission <- daily_co2_emission();
			daily_ch4_emission <- daily_ch4_emission();
			cumulative_co2_emission <- cumulative_co2_emission();
			cumulative_ch4_emission <- cumulative_ch4_emission();
		}

	}
	/*****/
	reflex routine {
		do normal_routine();
		do refresh_per_day();
	} }
