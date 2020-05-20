/***
* Name: Administration
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Administration

import "../GenericConstructionSpecies/Building.gaml"
/* Insert your model definition here */
species Administration parent: Building {
	rgb color <- #darkgreen;
	int nbMaxAgentsLinked <- 20;
}
