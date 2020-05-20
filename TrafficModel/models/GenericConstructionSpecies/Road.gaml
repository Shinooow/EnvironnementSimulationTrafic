/***
* Name: Road
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Road

import "Construction.gaml"
import "../OtherSpecies/Rule.gaml"

species Road parent: Construction {
	rgb color <- #black;
	int nombreVoies;
	float vitesseMax;
	list<Rule> rules;
		
	/** ACTION ADDRULE
	 * Param in: one rule
	 * Ajoute la regle passee en parametre a la collection 
	 * de regles de la route
	 */
	action addRule(Rule rule){
		add rule to: rules;
	}
	
	aspect base {
		draw shape color: color;
	}
	
}

