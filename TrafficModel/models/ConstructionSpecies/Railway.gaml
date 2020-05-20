/***
* Name: Railway
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Railway

import "../GenericConstructionSpecies/Construction.gaml"

species Railway parent: Construction {
	
	file image_railway <- file("../../includes/images/Capture.png");
	
	aspect with_image {
		draw shape color: #red;
	}
}

