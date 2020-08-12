/**
* Name: TestBluetoothMultipleCar
* Based on the internal test template. 
* Author: Maxence
* Tags: 
*/
model TestBluetoothMultipleCar

import "../GenericVehicleSpecies/GuidableVehicle.gaml"

global {
	setup {
		loop i from: 0 to: 1 {
			create GuidableVehicle {
				self.idGuidable <- i;
				self.is_connected <- false;
			}

		}

	}

	/* Objectif: verifier le bon fonctionnement de l'envoi 
	 * d'ordres a plusieurs vehicles connectes
	 * Etat initial: deux vehicules connectes en bluetooth a Gama
	 * Etat final: deux vehicles deconnectes apres avoir effectue
	 * les actions demandees
	 * Resultat attendu: voir les deux voitures avancer
	 */
	test "TwoCarsMovingForwardTest" {
		GuidableVehicle car1 <- GuidableVehicle.population[0];
		GuidableVehicle car2 <- GuidableVehicle.population[1];
		ask [car1, car2] {
			do connectCar();
		}

		loop times: 25 {
			ask [car1, car2] {
				do moveForward();
			}

		}

		ask [car1, car2] {
			do disconnectCar();
		}

	}

}

experiment TestBluetoothMultipleCar type: test autorun: true {
}
