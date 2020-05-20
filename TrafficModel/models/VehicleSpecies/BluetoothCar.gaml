/***
* Name: GuidableCar
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model BluetoothCar

import "../GenericVehicleSpecies/GuidableVehicle.gaml"

/* Insert your model definition here */
species BluetoothCar parent: GuidableVehicle {
	int crash_importance <- 5;
}
