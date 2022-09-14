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
    }
}

experiment Normal {
    output {
        display Simulator {
            grid Background lines: #black;
            species Pig aspect: base;
        }
    }
}