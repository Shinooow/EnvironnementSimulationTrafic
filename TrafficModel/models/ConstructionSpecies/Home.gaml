/***
* Name: Home
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Home

import "../GenericConstructionSpecies/Building.gaml"

/* Insert your model definition here */
species Home parent: Building {
	rgb color <- #blue;
	int nbMaxAgentsLinked <- 5;
}
