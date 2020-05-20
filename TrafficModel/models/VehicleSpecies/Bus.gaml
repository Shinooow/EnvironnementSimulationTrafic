/***
* Name: Bus
* Author: Tutorial 
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Bus

import "../GenericVehicleSpecies/NonGuidableVehicle.gaml"

species Bus parent: NonGuidableVehicle {
	int crash_importance <- 5;
}

