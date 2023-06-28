/**
* Name: WaterDiseaseConfig
* Author: Lê Đức Toàn
*/


model WaterDiseaseConfig


import './water-disease-factor.gaml'


species WaterDiseaseConfig {
	int day;
	
	init {
		day <- 0;
	}
	
	reflex spread when: cycle mod (24 * 60) = 0 and int(cycle / (60 * 24)) = day {
		create WaterDiseaseFactor number: 5;
		loop i from: 0 to: 4 {
			WaterDiseaseFactor[i].duration <- 7 * 24 * 60;
			WaterDiseaseFactor[i].size <- 2.0;
			WaterDiseaseFactor[i].location <- trough_locs[i];
		}
	}
}