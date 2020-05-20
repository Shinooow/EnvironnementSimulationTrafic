/***
* Name: TestBluetooth
* Author: Maxence
* Description: A model dedicated to run unit tests
* Tags: Tag1, Tag2, TagN
***/

model TestBluetooth

import "../GenericVehicleSpecies/GuidableVehicle.gaml"

global {
	
	/* Action de detruire l'agent utilise pour que chaque test 
	 * soit independant l'un de l'autre
	 */
	action destruction_agents_tests {
		GuidableVehicle car <- GuidableVehicle.population[0];
		ask car {
			do die;
		}
	}
	
	setup {
		/* Creation de l'agent voiture avant chaque test */
		create GuidableVehicle {
			self.idGuidable <- 0;
			self.is_connected <- false;
		}
	}
	
	/* Objectif: verifier qu'une connexion et deconnexion bluetooth 
	 * se deroule sans probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir subit une connexion
	 * et une deconnexion
	 * Resultat attendu: code de retour de la connexion et deconnexion
	 * definis a 0
	 */
	test "CoDecoTest" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int connect <- -1;
		int disconnect <- -1;
		ask car {
			connect <- connectCar(0);
			disconnect <- disconnectCar(0);
		}
		assert (connect = 0 and disconnect = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action MoveForward se deroule sans 
	 * probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre d'avancer 
	 * tout droit (ainsi que sa deconnexion pour passer a un autre test)
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "MoveForwardTest" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- moveForward(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif verifier que l'action MoveBackward se deroule sans 
	 * probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre de
	 * reculer (ainsi que sa deconnexion pour passer a un autre test)
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "MoveBackwardTest" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- moveBackward(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action ForwardToLeft se deroule sans
	 * probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre d'avancer
	 * vers la gauche (ainsi que sa deconnexion pour passer a un autre test)
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "ForwardToLeft" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- forwardToLeft(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action ForwardToRight se deroule sans
	 * probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre d'avancer
	 * vers la droite (ainsi que sa deconnexion pour passer a un autre test)
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "forwardToRight" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- forwardToRight(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action BackwardToLeft se deroule sans 
	 * probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre de reculer
	 * vers la gauche
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "backwardToLeft" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- backwardToLeft(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action BackwardToRight se deroule sans 
	 * probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre de reculer
	 * vers la droite
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "backwardToRight" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- backwardToRight(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action ResetWheels se deroule sans
	 * probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre de recadrer 
	 * ses roues 
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "resetWheelsTest" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- resetWheels(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action StopBeforeForward se deroule
	 * sans probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre de s'arreter
	 * avant un futur ordre d'avancer
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "stopBeforeForwardTest" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- stopBeforeForward(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action StopBeforeBackward se deroule
	 * sans probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre de s'arreter
	 * avant un futur ordre de reculer
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "stopBeforeBackward" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- stopBeforeBackward(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action LeftHalfTurn se deroule
	 * sans probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre de faire
	 * un demi tour gauche
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "LeftHalfTurnTest" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- leftHalfTurn(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action RightHalfTurn se deroule 
	 * sans probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre de faire 
	 * un demi tour droit 
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "RightHalfTurnTest" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- rightHalfTurn(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action ClockwiseCircle se deroule 
	 * sans probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre de faire
	 * un cercle dans le sens des aiguilles d'une montre 
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "ClockwiseCircleTest" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- clockwiseCircle(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action AntiClockwiseCircle se deroule
	 * sans probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre de faire 
	 * un cercle dans le sens inverse des aiguilles d'une montre
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "AntiClockwiseCircleTest" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- antiClockwiseCircle(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
	/* Objectif: verifier que l'action Slalom se deroule sans
	 * probleme
	 * Etat initial: un agent voiture sans particularite speciale
	 * Etat final: un agent voiture apres avoir recu l'ordre de 
	 * faire un slalom
	 * Resultat attendu: code de retour de l'action = 0
	 */
	test "SlalomTest" {
		GuidableVehicle car <- GuidableVehicle.population[0];
		int resultat_retourne <- -1;
		ask car {
			do connectCar(0);
			resultat_retourne <- slalomMove(0);
			do disconnectCar(0);
		}
		assert (resultat_retourne = 0);
		do destruction_agents_tests;
	}
	
}

experiment TestBluetooth type: test autorun: true {

}
