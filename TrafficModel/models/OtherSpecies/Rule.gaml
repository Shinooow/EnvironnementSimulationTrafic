/***
* Name: Rule
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Rule

import "./Checkpoint.gaml"

species Rule {
	int id;
	string contenu <- "Test rule";
	int type;
	Checkpoint oneWayTarget;
}

