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
		display Simulator name: "Simulator" refresh: every((60 * 24) #cycles) {
			grid Background;
			species Pig aspect: base;
			overlay position: {2, 2} size: {10, 5} background: #black transparency: 1 {
				draw "Day " + floor(cycle / (24 * 60)) color: #black at: {4, 15} font: font("Arial", 22, #plain);
				draw rectangle(30, 30) at: {4, 45} color: #blue;
				draw "CO2: " + (Pig sum_of (each.daily_co2_emission) with_precision 2) + " kg" at: {25, 58} color: #black font: font("Arial", 18, #plain);
				draw rectangle(30, 30) at: {4, 80} color: #red;
				draw "CH4: " + (Pig sum_of (each.daily_ch4_emission) with_precision 2) + " kg" at: {25, 88} color: #black font: font("Arial", 18, #plain);
			}

		}

		display CFI name: "CFI" refresh: every((60 * 24) #cycles) {
			chart "CFI" type: series {
				loop pig over: Pig {
					data string(pig.id) value: pig.cfi;
				}

			}

		}

		display Weight name: "Weight" refresh: every((60 * 24) #cycles) {
			chart "Weight" type: histogram {
				loop pig over: Pig {
					data string(pig.id) value: pig.weight;
				}

			}

		}

		display CFIPig0 name: "CFIPig0" refresh: every((60 * 24) #cycles) {
			chart "CFI vs Target CFI" type: series {
				data 'CFI' value: Pig[0].cfi;
				data 'Target CFI' value: Pig[0].target_cfi;
			}

		}

		display DFIPig0 name: "DFIPig0" refresh: every((60 * 24) #cycles) {
			chart "DFI vs Target DFI" type: series {
				data 'DFI' value: Pig[0].dfi;
				data 'Target DFI' value: Pig[0].target_dfi;
			}

		}

		display DailyCO2Emission name: "DailyCO2Emission" refresh: every((60 * 24) #cycles) {
			chart "Daily CO2 emission (kg)" type: series {
				loop pig over: Pig {
					data string(pig.id) value: pig.daily_co2_emission;
				}

			}

		}

		display DailyCH4Emission name: "DailyCH4Emission" refresh: every((60 * 24) #cycles) {
			chart "Daily CH4 emission (kg)" type: series {
				loop pig over: Pig {
					data string(pig.id) value: pig.daily_ch4_emission;
				}

			}

		}

		display TotalEmission name: "TotalEmission" refresh: every((60 * 24) #cycles) {
			chart "Total cumulative emission (kg)" type: series {
				data "CO2" value: Pig sum_of (each.cumulative_co2_emission) color: #blue;
				data "CH4" value: Pig sum_of (each.cumulative_ch4_emission) color: #red;
			}

		}

	}

	reflex log when: mod(cycle, 24 * 60) = 0 {
		ask simulations {
			float total_CO2_emission <- Pig sum_of (each.cumulative_co2_emission);
			float total_CH4_emission <- Pig sum_of (each.cumulative_ch4_emission);
			loop pig over: Pig {
				save
				[floor(cycle / (24 * 60)), pig.id, pig.target_dfi, pig.dfi, pig.target_cfi, pig.cfi, pig.weight, pig.eat_count, pig.excrete_each_day, pig.excrete_count, pig.daily_co2_emission, pig.daily_ch4_emission, pig.cumulative_co2_emission, pig.cumulative_ch4_emission]
				to: "../includes/output/normal/" + experiment_id + "-" + string(pig.id) + ".csv" rewrite: false format: "csv";
			}

			save [floor(cycle / (24 * 60)), total_CO2_emission, total_CH4_emission] to: "../includes/output/normal/" + experiment_id + "-emission" + ".csv" rewrite: false format: "csv";
		}

	}

	reflex capture when: mod(cycle, speed) = 0 {
		ask simulations {
			save (snapshot(self, "Simulator", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-simulator-" + string(cycle) + ".png";
			save (snapshot(self, "CFI", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-cfi-" + string(cycle) + ".png";
			save (snapshot(self, "Weight", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-weight-" + string(cycle) + ".png";
			save (snapshot(self, "CFIPig0", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-cfipig0-" + string(cycle) + ".png";
			save (snapshot(self, "DFIPig0", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-dfipig0-" + string(cycle) + ".png";
			save (snapshot(self, "DailyCO2Emission", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-dailyco2emission-" + string(cycle) + ".png";
			save (snapshot(self, "DailyCH4Emission", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-dailych4emission-" + string(cycle) + ".png";
			save (snapshot(self, "TotalEmission", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-totalemission-" + string(cycle) + ".png";
		}

	}

}