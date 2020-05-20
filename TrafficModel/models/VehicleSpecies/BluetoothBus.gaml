/***
* Name: BluetoothBus
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model BluetoothBus

import "../GenericVehicleSpecies/GuidableVehicle.gaml"

/* Insert your model definition here */
species BluetoothBus parent: GuidableVehicle {
	int crash_importance <- 5;
}