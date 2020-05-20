/***
* Name: Signalisation
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Signalisation

import "./Rule.gaml"

species Signalisation {
	int id;
	file signalisation_icon <- file("../../includes/images/attention_sign.png");
	float icon_size;
	float zone;
	list<Rule> rules;
	
	action addRule (Rule rule){
		add rule to: rules;
	}
	
	aspect base {
		draw circle(2.0) color: #red;
	}
	
	aspect with_icon {
		draw signalisation_icon size: icon_size;
	}
}

