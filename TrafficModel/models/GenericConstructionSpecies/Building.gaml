/***
* Name: Building
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Building

import "../GenericConstructionSpecies/Construction.gaml"
/* Insert your model definition here */

species Building parent: Construction {
	rgb color;
	int nbMaxAgentsLinked;
	
	aspect base {
		draw rectangle(dimension_longueur, dimension_largeur) color: color;
	}
}
