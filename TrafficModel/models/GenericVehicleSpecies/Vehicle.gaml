
model Vehicle

import "../Main.gaml"
import "../GenericConstructionSpecies/Road.gaml"

species Vehicle skills: [moving] {
	/* Propriétés sur l'affichage des voitures sur la simulation */
	file car_icon <- file("../../includes/images/red-car.png");
	file crashed_car_icon <- file("../../includes/images/black-car.png");
	file fleche_icon <- file("../../includes/images/test4.jpg");
	float icon_size <- 50.0;
	
	float max_speed <- speed;
	point target;
	bool is_arrived <- true;
	float angle_rotation <- 0.0;
	point last_location <- location;
	point vecteur_direction;
	
	int nb_passagers;
	
	/* Propriete utile pour la regle oneWay (voir Rule) */
	point secondaryTarget <- nil;

	/* Si must_stay_on_road est placé à faux la voiture peut
	 * se déplacer en dehors de la route
	 */
	bool must_stay_on_road <- true;
	
	/* Propriétés sur les variations de vitesse de la voiture
	 * coefficients et booleens sur les conditions d'acceleration
	 * et décélération 
	 */
	bool can_speed_up <- false;
	bool must_brake <- false;
	float coeff_deceleration <- 0.30;
	float coeff_acceleration <- 0.75;

	/* COLLISIONS DES VOITURES */
	/* Equations de la droite de la route sous forme: coeff_directeur * x + val_origine */
	float coeff_directeur;
	float val_origine;
	bool vertical_eq <- false;
	bool crashed <- false;
	/* Coefficient d'importance lors d'une collision:
	 * si les coefficients entre deux vehicules sont egaux, 
	 * les deux rentrent en collision, sinon seulement le vehicule avec
	 * le coefficient le plus faible
	 */
	int crash_importance;
	
	/* --------------------------------------------------------------------------------------------------- */
	/* ------------------------------------------ DEBUT ACTIONS ------------------------------------------ */
	/* --------------------------------------------------------------------------------------------------- */
	

	/** CALCUL_EQ_ROUTE  
	 * Calcul de l'équation de la droite de la route calculée depuis deux points
	 * à l'étape i: la location à l'étape i-1 et à l'étape i
	 * Formules mathématiques utilisée: 
	 * coeff_directeur = (y1-y2)/(x1-x2)
	 * valeur_origine  = y2 - coeff_directeur * x2 (équation depuis le deuxieme point)
	 * Attribue les valeurs aux variables coeff_directeur et val_origine
	 */
	action calcul_eq_route {
		
		float n <- location.x - last_location.x;
		if (n != 0) {
			vertical_eq <- false;
			coeff_directeur <- (location.y - last_location.y) / n;
			val_origine <- last_location.y - coeff_directeur * last_location.x;
			coeff_directeur <- coeff_directeur with_precision 3;
			val_origine <- val_origine with_precision 3;
		} else if(n=0 and last_location.y!=location.y){
			vertical_eq <- true;
		}
	}

	/** FREINAGE
	 * Attribue la nouvelle vitesse à la voiture selon
	 * le coefficient de freinage (vitesse - vitesse*coeff)
	 * Si la nouvelle vitesse calculée est en dessous du seuil 
	 * de vitesse minimale, la voiture s'arrête
	 */
	action freinage {
		
		float nouvelle_vitesse <- speed - speed * coeff_deceleration;
		if (nouvelle_vitesse < seuil_vitesse_min) {
			speed <- 0.0;
		} else {
			speed <- nouvelle_vitesse;
			coeff_deceleration <- coeff_deceleration+0.10;
		}
	}

	/** ACCELERATION
	 * Attribue la nouvelle vitesse à la voiture selon
	 * le coefficient d'acceleration (vitesse + vitesse*coeff)
	 * Si la nouvelle vitesse calculée est au dessus de la 
	 * vitesse maximale de la voiture alors la voiture prend donc
	 * sa vitesse maximale
	 */
	action acceleration {
		
		float nouvelle_vitesse <- speed + speed * coeff_acceleration;
		if (nouvelle_vitesse > max_speed) {
			speed <- max_speed;
			can_speed_up <- false;
		} else {
			speed <- nouvelle_vitesse;
		}
	}

	/** CALCUL_ANGLE_ROTATION
	 * Calcule l'angle de rotation de l'icône représentant la voiture 
	 * pour que la voiture soit orientée dans la direction de sa direction
	 * Détermine l'angle entre deux vecteurs: le vecteur de la direction
	 * du véhicule et le vecteur {0,-1,0}
	 * Si l'attribut x du vecteur directeur est négatif, alors l'angle
	 * est "inversé"
	 */
	action calcul_angle_rotation {
		
		vecteur_direction <- {location.x - last_location.x, location.y - last_location.y, 0};
		float n <- sqrt((vecteur_direction.x * vecteur_direction.x + vecteur_direction.y * vecteur_direction.y));
		if (n != 0) {
			angle_rotation <- (vecteur_base.x * vecteur_direction.x + vecteur_base.y * vecteur_direction.y);
			angle_rotation <- acos(angle_rotation / n);
			if (location.x < last_location.x) {
				angle_rotation <- 360.0 - angle_rotation;
			}
		}
	}
	
	/** DISTANCE_BETWEEN_TWO_VEHICLES
	 * Calcule la distance entre deux vehicules 
	 * retourne cette distance qui est un float
	 * Prend en parametre le deuxieme vehicule 
	 */
	float distance_between_two_vehicles (Vehicle otherVehicle){
		
		point positionVa <- location;
		point positionVb <- otherVehicle.location;
		float result <- (positionVb.x-positionVa.x)*(positionVb.x-positionVa.x) + (positionVb.y-positionVa.y)*(positionVb.y-positionVa.y);
		result <- sqrt(result);
		return result;
	}
	
	/** BRAKE_COLLISION_COMPUTING_X_AXIS
	 * Calcule si le vehicule doit freiner pour eviter une collision
	 * en ligne droite
	 * calculs sur l'axe x depuis l'equation de droite 
	 * param in: second vehicule pour les calculs et comparaisons
	 */
	action brake_collision_computing_x_axe (Vehicle otherVehicle){
		
		bool xDecroissant <- (self.last_location.x>self.location.x);
		bool xDecroissantOtherCar <- (otherVehicle.last_location.x>otherVehicle.location.x);
		float distanceBetweenVehicles <- distance_between_two_vehicles(otherVehicle);
		if(xDecroissant=xDecroissantOtherCar){
			if(distanceBetweenVehicles<=seuilBrakeIfCollision){
				/* determiner la voiture derriere l'autre */
				Vehicle carBehind;
				if(not xDecroissant){
					carBehind <- (self.location.x<otherVehicle.location.x)?self:otherVehicle;
				} else {
					carBehind <- (self.location.x>otherVehicle.location.x)?self:otherVehicle;
				}
				if(carBehind = self and self.speed>otherVehicle.speed){
					do freinage;
				}
			}
		} else if((not xDecroissant) and distanceBetweenVehicles<=seuilBrakeIfCollision){
			/* directions differentes */
			do freinage;
			ask otherVehicle{
				do freinage;
			}
		}
	}
	
	/** BRAKE_COLLISION_COMPUTING_Y_AXIS
	 * Calcule si le vehicule doit freiner pour eviter une collision
	 * en ligne droite
	 * calculs sur l'axe y en raison d'une trajectoire totalement verticale
	 * param in: second vehicule pour les calculs et comparaisons
	 */
	action brake_collision_computing_y_axe(Vehicle otherVehicle){
		
		bool yDecroissant <- (self.last_location.y>self.location.y);
		bool yDecroissantOtherCar <- (otherVehicle.last_location.y>otherVehicle.location.y);
		float distanceBetweenVehicles <- distance_between_two_vehicles(otherVehicle);
		if(yDecroissant=yDecroissantOtherCar){
			if(distanceBetweenVehicles<=seuilBrakeIfCollision){
				/* determiner la voiture derriere l'autre */
				Vehicle carBehind;
				if(not yDecroissant){
					carBehind <- (self.location.y<otherVehicle.location.y)?self:otherVehicle;
				} else {
					carBehind <- (self.location.y>otherVehicle.location.y)?self:otherVehicle;
				}
				if(carBehind = self and self.speed>otherVehicle.speed){
					do freinage;
				}
			}
		}  else if((not yDecroissant) and yDecroissantOtherCar and distanceBetweenVehicles<=seuilBrakeIfCollision){
			/* directions differentes */
			do freinage;
			ask otherVehicle{
				do freinage;
			}
		}						
	}
	
	/** BRAKE_IF_COLLISION_COMING
	 * action qui verifie si une collision est a prevoir entre
	 * self et tous les autres vehicules presents de la simulation
	 * si oui, le vehicule freinera
	 */
	action brake_if_collision_coming {

		loop otherVehicle over: vehicules{
			if(self != otherVehicle){
				if((not vertical_eq) and self.coeff_directeur=otherVehicle.coeff_directeur and self.val_origine=otherVehicle.val_origine){
					do brake_collision_computing_x_axe(otherVehicle);
				} else if(vertical_eq and self.location.x=otherVehicle.location.x){
					do brake_collision_computing_y_axe(otherVehicle);
				}
			}
		}
	}
	
	/** RENTRE_EN_COLLISION
	 * Change les parametres mis en cause lors d'une collision de deux
	 * voiture par exemple le booleen crashed placé à vrai
	 */
	action rentre_en_collision{
		
		crashed <- true;
		car_icon <- crashed_car_icon;
		speed <- 0.0;
		nb_crashed_cars <- nb_crashed_cars +1;
	}
	
	/** WHICH_ONE_CRASHES
	 * Dans une collision, cette action compare les deux coefficients 
	 * crash_importance des vehicules, si un est inferieur a l'autre,
	 * alors le vehicule correspondant est detruit
	 * Si il y a egalite, les deux vehicules sont detruits
	 * Param in: second vehicule de la collision
	 */
	action which_ones_crash (Vehicle otherCar) {
		if(self.crash_importance = otherCar.crash_importance){
			ask otherCar {
				do rentre_en_collision;
			}
			do rentre_en_collision;
		} else {
			Vehicle vehicleToCrash <- (self.crash_importance<otherCar.crash_importance)? self : otherCar;
			ask vehicleToCrash {
				do rentre_en_collision;
			}
		}
	}
	
	/** VERIFICATION_COLLISION
	 * Détermine si la voiture est rentrée en collision avec
	 * une autre voiture pendant l'étape i
	 * Calcule d'abord l'équation de la droite de la route 
	 * utilisée puis regarde si une autre voiture a empreinté le 
	 * même chemin
	 * Si il y a un crash entre deux voitures: les deux s'arrêtent 
	 * et changent de couleur (noir)
	 */
	action verification_collision {
		
		/* Etape 1: calculer l'equation de la droite représentant la route (via la position actuelle et l'ancienne position) */
		//do calcul_eq_route;
		/* Etape 2: on regarde si il y a une collision sur chaque voiture */
		loop other_car over: vehicules {
			if (self != other_car) {
			/* Si présents sur la même route */
			/* Ajout 21/04: reduction de la precision sur l'egalite des valeurs a l origine des equations de droite en raison de 
			 * de la surface de la voiture (il n'y a pas collision que si les deux voitures sont passees exactement par la meme 
			 * droite
			 */
				if ((self.coeff_directeur = other_car.coeff_directeur and self.val_origine >= (other_car.val_origine-40.0) and self.val_origine <= (other_car.val_origine+40.0)) or vertical_eq) {
					/* on regarde si other_car est passé sur la portion de route où self est passé*/
					float tmin <- min(self.last_location.x, self.location.x);
					float tmax <- max(self.last_location.x, self.location.x);
					if ((other_car.location.x >= tmin and other_car.location.x <= tmax) or (other_car.last_location.x >= tmin and other_car.last_location.x <= tmax)) {
						write "car crash";
						do which_ones_crash(other_car);
					}
				} else {
					/* Ajout 21/04: si il y a une collision dans un virage (ce qui rend le calcul via les equations de droite faux) */
					list neighbors <- self neighbors_at 20.0;	
					loop ag over: neighbors {
						if(ag in vehicules){
							write "car crash";
							Vehicle ag_vehicle <- Vehicle(ag);
							do which_ones_crash(ag);
						}
					}
				}
			}
		}
	}

	/** ACTION PERCEPTION
	 * Retourne la liste des regles de la route sur laquelle
	 * le vehicule se trouve
	 * Utilise at_distance pour obtenir la route
	 */
	list<Rule> perception {
		
		list<Rule> detectedRules;
		list<Road> on_road <- Road.population at_distance (0.5);
		loop road over: on_road {
			if(length(road.rules)>0){
				loop rule over: road.rules{
					add rule to: detectedRules;
				}
			}
		}
		return detectedRules;
	}
	
	/** ACTION DECISION
	 * Param in: liste des regles a appliquer
	 * Applique toutes les regles presentes dans la liste 
	 * passee en parametre
	 * Si des nouveaux types de regles sont ajoutees, il faut 
	 * ajouter un match dans le switch dans cette action
	 */
	action decision (list<Rule> detectedRules){
		
		loop rule over: detectedRules{
			switch rule.type {
				match 1 { secondaryTarget <- rule.oneWayTarget.location; break;}
			}
		}
	}
	
	/* --------------------------------------------------------------------------------------------------- */
	/* ------------------------------------------- FIN ACTIONS ------------------------------------------- */
	/* --------------------------------------------------------------------------------------------------- */
	
	/*---------------------------------------------------------------------------------------------------- */
	/* -----------------------------------------  DEBUT REFLEXES ----------------------------------------- */
	/* ----------------------------------------------------------------------------------------------------*/
	
		
	/** REFLEX PERCEPTIONDECISION
	 * A chaque etape de la simulation, chaque vehicule recupere
	 * les regles de la route sur laquelle il se trouve et les
	 * applique
	 */
	reflex perceptionDecision {
		
		list<Rule> detectedRules <- perception();
		do decision(detectedRules);
	}
	
	/** REFLEX SETUP_TARGET
	 * Après que la voiture soit arrivée à une destination
	 * une nouvelle destination est choisie aléatoirement
	 */
	reflex setup_target when: is_arrived {
		
		target <- (one_of(Checkpoint.population)).location;
		is_arrived <- false;
	}

	/** REFLEX CAR_AT_DESTINATION 
	 * Lorsque que la voiture est arrivée à destination, 
	 * le booléen correspondant est placé à vrai
	 */
	reflex car_at_destination when: location = target.location {
		
		/* La voiture est arrivée au checkpoint destination */
		is_arrived <- true;
	}

	/** REFLEX move
	 * Condition: lorsque la cible n'est pas vide (la voiture doit 
	 * aller à une destination
	 * Se déroule en plusieurs étapes: 
	 * - Variations de vitesse
	 * - Déplacement sur la route (ou non)
	 * - Calculs de collisions
	 * - Calculs d'angle de rotation de l'image
	 */
	reflex mise_a_jour when: target != nil and (not crashed){
		// REDEFINI PAR LES ESPECES FILLES
	}
	
	/*---------------------------------------------------------------------------------------------------- */
	/* ------------------------------------------- FIN REFLEXES ------------------------------------------ */
	/* ----------------------------------------------------------------------------------------------------*/
	

	aspect with_icon {
		draw car_icon size: icon_size rotate: angle_rotation;
		draw fleche_icon at: {location.x-25, location.y-25, 0} rotate: angle_rotation size: 30;
		draw string((speed*100.0) with_precision 3) size: 20 color: #black width: 5;
	}

}