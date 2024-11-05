model Simulator

import './food-disease-config.gaml'
import './food-disease-pig.gaml'

global {
	file pigs;
	int speed;
	string experiment_id;

	init {
		pigs <- csv_file("../includes/input/food-disease-pigs.csv", true);
		speed <- 45;
		create FoodDiseasePigDD from: pigs;
		create Trough number: 5;
		loop i from: 0 to: 4 {
			Trough[i].location <- trough_locs[i];
		}

		create FoodDiseaseConfig number: 2;
		FoodDiseaseConfig[0].day <- 14;
		FoodDiseaseConfig[1].day <- 35;
	}

	reflex stop when: cycle = 60 * 24 * 55 {
		do pause;
	}

}

experiment DD {
	parameter "Experiment ID" var: experiment_id <- "";
	output {
		display Simulator name: "Simulator" {
			grid Background;
			species FoodDiseasePigDD aspect: base;
			overlay position: {2, 2} size: {10, 5} background: #black transparency: 1 {
				draw "Day " + floor(cycle / (24 * 60)) color: #black at: {0, 0} font: font("Arial", 18, #plain);
				float average_co2_hour <- (FoodDiseasePigDD sum_of (each.daily_co2_emission)) / 24;
				rgb co2_color <- (average_co2_hour > 1) ? #red : #green;
				draw rectangle(10, 10) at: {1, 20} color: co2_color;
				draw "Avg CO2/hour: " + (average_co2_hour with_precision 3) + " kg" at: {15, 25} color: #black font: font("Arial", 16, #plain);
				float average_ch4_hour <- (FoodDiseasePigDD sum_of (each.daily_ch4_emission)) / 24;
				rgb ch4_color <- (average_ch4_hour > 0.036) ? #red : #green;
				draw rectangle(10, 10) at: {1, 35} color: ch4_color;
				draw "Avg CH4/hour: " + average_ch4_hour with_precision 3 + " kg" at: {15, 40} color: #black font: font("Arial", 16, #plain);
			}

		}

		display DFI name: "DFI" refresh: every((60 * 24) #cycles) {
			chart "DFI" type: series {
				loop pig over: FoodDiseasePigDD {
					data string(pig.id) value: pig.dfi;
				}

			}

		}

		display Weight name: "Weight" refresh: every((60 * 24) #cycles) {
			chart "Weight" type: histogram {
				loop pig over: FoodDiseasePigDD {
					data string(pig.id) value: pig.weight;
				}

			}

		}

		display CFIPig0 name: "CFIPig0" refresh: every((60 * 24) #cycles) {
			chart "CFI vs Target CFI" type: series {
				data 'CFI' value: FoodDiseasePigDD[0].cfi;
				data 'Target CFI' value: FoodDiseasePigDD[0].target_cfi;
			}

		}

		display DFIPig0 name: "DFIPig0" refresh: every((60 * 24) #cycles) {
			chart "DFI vs Target DFI" type: series {
				data 'DFI' value: FoodDiseasePigDD[0].dfi;
				data 'Target DFI' value: FoodDiseasePigDD[0].target_dfi;
			}

		}

		display DailyCO2Emission name: "DailyCO2Emission" refresh: every((60 * 24) #cycles) {
			chart "Daily CO2 emission (kg)" type: series {
				loop pig over: FoodDiseasePigDD {
					data string(pig.id) value: pig.daily_co2_emission;
				}

			}

		}

		display DailyCH4Emission name: "DailyCH4Emission" refresh: every((60 * 24) #cycles) {
			chart "Daily CH4 emission (kg)" type: series {
				loop pig over: FoodDiseasePigDD {
					data string(pig.id) value: pig.daily_ch4_emission;
				}

			}

		}

		display TotalCO2Emission name: "TotalCO2Emission" refresh: every((60 * 24) #cycles) {
			chart "Total cumulative CO2 emission (kg)" type: series {
				data "CO2" value: FoodDiseasePigDD sum_of (each.cumulative_co2_emission) color: #blue;
			}

		}

		display TotalCH4Emission name: "TotalCH4Emission" refresh: every((60 * 24) #cycles) {
			chart "Total cumulative CH4 emission (kg)" type: series {
				data "CH4" value: FoodDiseasePigDD sum_of (each.cumulative_ch4_emission) color: #red;
			}

		}

	}

	reflex log when: mod(cycle, 24 * 60) = 0 {
		ask simulations {
			float total_CO2_emission <- FoodDiseasePigDD sum_of (each.cumulative_co2_emission);
			float total_CH4_emission <- FoodDiseasePigDD sum_of (each.cumulative_ch4_emission);
			loop pig over: FoodDiseasePigDD {
				save
				[floor(cycle / (24 * 60)), pig.id, pig.target_dfi, pig.dfi, pig.target_cfi, pig.cfi, pig.weight, pig.eat_count, pig.excrete_each_day, pig.excrete_count, pig.expose_count_per_day, pig.recover_count, pig.daily_co2_emission, pig.daily_ch4_emission, pig.cumulative_co2_emission, pig.cumulative_ch4_emission]
				to: "../includes/output/dd/" + experiment_id + "-" + string(pig.id) + ".csv" rewrite: false format: "csv";
			}

			save [floor(cycle / (24 * 60)), total_CO2_emission, total_CH4_emission] to: "../includes/output/dd/" + experiment_id + "-emission" + ".csv" rewrite: false format: "csv";
		}

	}

	reflex capture when: mod(cycle, speed) = 0 {
		ask simulations {
			save (snapshot(self, "Simulator", {500.0, 500.0})) to: "../includes/output/dd/" + experiment_id + "-simulator-" + string(cycle) + ".png";
			save (snapshot(self, "DFI", {500.0, 500.0})) to: "../includes/output/dd/" + experiment_id + "-dfi-" + string(cycle) + ".png";
			save (snapshot(self, "Weight", {500.0, 500.0})) to: "../includes/output/dd/" + experiment_id + "-weight-" + string(cycle) + ".png";
			//			save (snapshot(self, "CFIPig0", {500.0, 500.0})) to: "../includes/output/dd/" + experiment_id + "-cfipig0-" + string(cycle) + ".png";
			//			save (snapshot(self, "DFIPig0", {500.0, 500.0})) to: "../includes/output/dd/" + experiment_id + "-dfipig0-" + string(cycle) + ".png";
			save (snapshot(self, "DailyCO2Emission", {500.0, 500.0})) to: "../includes/output/dd/" + experiment_id + "-dailyco2emission-" + string(cycle) + ".png";
			save (snapshot(self, "DailyCH4Emission", {500.0, 500.0})) to: "../includes/output/dd/" + experiment_id + "-dailych4emission-" + string(cycle) + ".png";
			save (snapshot(self, "TotalCO2Emission", {500.0, 500.0})) to: "../includes/output/dd/" + experiment_id + "-totalco2emission-" + string(cycle) + ".png";
			save (snapshot(self, "TotalCH4Emission", {500.0, 500.0})) to: "../includes/output/dd/" + experiment_id + "-totalch4emission-" + string(cycle) + ".png";
		}

	}

}