/***
* Name: GuidableVehicle
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model GuidableVehicle

import "Vehicle.gaml"

/* Insert your model definition here */
species GuidableVehicle parent: Vehicle skills:[Bluetooth]{
	bool is_connected <- false;
	int idGuidable;
	
	/** OVERRIDE FROM VEHICLE */
	reflex mise_a_jour when: target != nil and not crashed{
		last_location <- location;
		if(must_brake){
			do freinage;
		} else if(can_speed_up){
			do acceleration;
		}
		
		float posx <- getXCarPosition(idGuidable);
		float posy <- getYCarPosition(idGuidable);
		float speedx <- getXCarSpeed(idGuidable);
		float speedy <- getYCarSpeed(idGuidable);
		point new_location <- {posx*mise_a_echelle, posy*mise_a_echelle, 0.0};
		location <- new_location;
		//angle_rotation <- float(list_ligne[3*idGuidable+2]);
		do calcul_eq_route;
		do verification_collision;
	}
	
	/** OVERRIDE FROM VEHICLE */
	action rentre_en_collision{
		
		crashed <- true;
		car_icon <- crashed_car_icon;
		speed <- 0.0;
		nb_crashed_cars <- nb_crashed_cars +1;
		if(is_connected){
			do disconnectCar();
			is_connected <- false;
		}
	}
}
