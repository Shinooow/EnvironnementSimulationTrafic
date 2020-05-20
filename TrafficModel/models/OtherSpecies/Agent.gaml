/***
* Name: Agent
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Agent

import "../ConstructionSpecies/Home.gaml"
import "../ConstructionSpecies/Administration.gaml"

species Agent skills: [moving]{
	int id;
	Home home;
	Administration administration;
	file agent_icon <- file("../../includes/images/agent.jpg");
	
	aspect base {
		draw circle(2.0) color: #red;
	}
	
	aspect with_icon {
		draw agent_icon size: 30;
	}
}

/* Insert your model definition here */

