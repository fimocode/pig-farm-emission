model GasConcentration

import './pig.gaml'
import './pig-fixed-diet.gaml'
species Barn {
	float co2_daily_avg; // (µg/min)
	float ch4_daily_avg; // (µg/min)
	float v_barn;
	float co2_concentration_in_air; // (µg/m3)
	float ch4_concentration_in_air; // (µg/m3)
	float avg_weight_pig;
	float number_of_pigs;
	float co2_concentration; // (µg/m3)
	float ch4_concentration; // (µg/m3)
	list<float> airflow; // m3/min
	init {
		v_barn <- 100.0; // m3
		co2_concentration_in_air <- 795604.0; // (µg/m3)
		ch4_concentration_in_air <- 1261.0; // (µg/m3)
		airflow <- [4.56, 5.7, 6.84, 7.62]; // m3/min
	}

	action update_emissions (list<Pig> pigList) {
		number_of_pigs <- float(length(pigList));
		avg_weight_pig <- (pigList sum_of (each.weight)) / length(pigList);
		co2_daily_avg <- (pigList sum_of (each.daily_co2_emission)) / 24 * 16666646.666707; // (µg/min)
		ch4_daily_avg <- (pigList sum_of (each.daily_ch4_emission)) / 24 * 16666646.666707; // (µg/min)
	}

	action update_emissions_fixed_emission (list<PigFixedDiet> pigList) {
		number_of_pigs <- float(length(pigList));
		avg_weight_pig <- (pigList sum_of (each.weight)) / length(pigList);
		co2_daily_avg <- (pigList sum_of (each.daily_co2_emission)) / 24 * 16666646.666707; // (µg/min)
		ch4_daily_avg <- (pigList sum_of (each.daily_ch4_emission)) / 24 * 16666646.666707; // (µg/min)
	}

	float airflow {
		if (avg_weight_pig < 40) {
			return rnd(airflow[0], airflow[1]);
		} else if (avg_weight_pig >= 40 and avg_weight_pig < 60) {
			return rnd(airflow[1], airflow[2]);
		} else if (avg_weight_pig >= 60 and avg_weight_pig < 80) {
			return rnd(airflow[2], airflow[3]);
		} else {
			return airflow[3];
		} }

	float co2_concentration {
		return (co2_daily_avg + co2_concentration_in_air * airflow() - v_barn) / airflow() * 0.001 * 24.45 / 44.01; // PPM
	}

	float ch4_concentration {
		return (ch4_daily_avg + ch4_concentration_in_air * airflow() - v_barn) / airflow() * 0.001 * 24.45 / 16.04; // PPM
	}

	bool is_start_of_day {
		return mod(cycle, 60 * 24) = 0;
	}

	action refresh_per_day {
		if (is_start_of_day()) {
			co2_concentration <- co2_concentration();
			ch4_concentration <- ch4_concentration();
		}

	}
	/*****/
	reflex routine {
		do refresh_per_day();
	} }
