/***
* Name: NonGuidableVehicle
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model NonGuidableVehicle

import "Vehicle.gaml"

/* Insert your model definition here */
species NonGuidableVehicle parent: Vehicle {
	int idNonGuidable;
	
	/** OVERRIDE FROM VEHICLE */
	reflex mise_a_jour when: target != nil and not crashed {
		last_location <- location;
		if(must_brake){
			do freinage;
		} else if(can_speed_up){
			do acceleration;
		}
		point destinationCible <- (secondaryTarget=nil)? target:secondaryTarget;
		if(must_stay_on_road){
			do goto target: destinationCible on: world.roadGraph speed: speed;
		} else {
			do goto target: destinationCible speed: speed;
		}
		
		do calcul_angle_rotation;
		do calcul_eq_route;
		do brake_if_collision_coming;
		do verification_collision;
	}
}
