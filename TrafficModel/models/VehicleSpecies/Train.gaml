/***
* Name: Train
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Train

import "../GenericVehicleSpecies/NonGuidableVehicle.gaml"
import "../ConstructionSpecies/Railway.gaml"

/* Insert your model definition here */
species Train parent: NonGuidableVehicle {
	int crash_importance <- 5;
	Railway voie;
}
