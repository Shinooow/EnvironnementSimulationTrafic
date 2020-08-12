/***
* Name: Main
* Author: Maxence
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model Main

import "./GenericConstructionSpecies/Road.gaml"
import "./GenericVehicleSpecies/Vehicle.gaml"
import "./VehicleSpecies/BluetoothCar.gaml"
import "./OtherSpecies/Checkpoint.gaml"
import "./VehicleSpecies/Bike.gaml"
import "./ConstructionSpecies/Home.gaml"
import "./VehicleSpecies/Bus.gaml"
import "./ConstructionSpecies/Administration.gaml"
import "./OtherSpecies/Agent.gaml"
import "./OtherSpecies/Signalisation.gaml"
import "./VehicleSpecies/Train.gaml"

global {
	
	/* choix de l'experience
	 * - 0: basicExperience
	 * - 1: experience de test de freinage en cas de collision proche
	 * - 2: experience de test d'insertion
	 * - 3: experience de test de rond point
	 * - 4: experience de test sur le campus Paul Sabatier
	 */
	int expChoice <- 0;
	string pathRoad <- getRoadPathFile();
	string zPathCheck <- getCheckpointPathFile();
	
	/* Graphic parameters - shapesfiles */
	file roads_shapefile <- file(pathRoad);
	file checkpoints_shapefile <- file(zPathCheck);
	file railway_shapefile <- file("../includes/shapefiles/railway.shp");
	geometry shape <- envelope(roads_shapefile);
	graph roadGraph;
	
	/* World paramaters */
	date starting_date <- date("2020-04-10-00-00-00");
	float step <- 3 #mn;
	
	/* duree d'un cycle avant les changements de position des checkpoint (en heures) */
	int cycle_time_checkpoint <- 2;

	/* Lors du freinage, si la vitesse du vehicule se retrouve en dessous
	 * du seuil, alors le vehicule s'arrete
	 */
	float seuil_vitesse_min <- 0.02;
	
	/* Permet le calcul du vecteur direction et de l'angle de l'orientation de l'icone voiture */
	point vecteur_base <- {0,-1,0};
	
	/* Permet l'affichage du graphique sur le nombre de voitures accidentees */
	int nb_crashed_cars <- 0;
	
	/* Nombre d'etape realisees a l'instant t dans la simulation */
	int nb_step <- 0;
	
	/* Coefficient permettant de mettre a l'echelles des donnees recues de l'exterieur */
	float mise_a_echelle <- 7.0;
	
	/* collection de tous les vehicules (aussi bien guidables que non guidables) */
	list<Vehicle> vehicules;
	/* collection de toutes les constructions */
	list<Construction> constructions;
	
	/* Identifiants a la creation pour chaque type d'espece
	 * en cas de besoin, rajouter ici d'autres id
	 */
	int idGuidableVehicleCreated <- 0;
	int idNonGuidableVehicleCreated <- 0;
	int idConstructionCreated <- 0;
	int idAgentCreated <- 0;
	int idRuleCreated <- 0;
	int idSignalisationCreated <- 0;
	
	float seuilBrakeIfCollision <- 300.0;
	
	/* --------------------------------------------------------------------------------------------------- */
	/* ------------------------------------------ DEBUT ACTIONS ------------------------------------------ */
	/* --------------------------------------------------------------------------------------------------- */
	
	/* Retourne le chemin du fichier shapefile des routes en fonction de l'experience choisie
	 * En cas d'ajout d'experience: ajouter ici un nouveau chemin 
	 */
	string getRoadPathFile {
		switch expChoice {
			match 0 { return "../includes/shapefiles/circuitv2.shp"; }
			match 1 { return "../includes/shapefiles/TestBrakeIfCollision.shp"; }
			match 2 { return "../includes/shapefiles/TestInsertion.shp"; }
			match 3 { return "../includes/shapefiles/RondPoint2.shp"; }
			match 4 { return "../includes/shapefiles/roads.shp"; }
			default { return "erreurExpChoice"; }
		} 
	}
	
	/* Retourne le chemin du fichier shapefile des checkpoints en fonction de l'experience choisie
	 * En cas d'ajout d'experience: ajouter ici un nouveau chemin
	 */
	string getCheckpointPathFile {
		switch expChoice {
			match 0 { return "../includes/shapefiles/checkpointsv2.shp"; }
			match 1 { return "../includes/shapefiles/TestBrakeIfCollisionCheckpoints.shp"; }
			match 2 { return "../includes/shapefiles/TestInsertionCheckpoints.shp"; }
			match 3 { return "../includes/shapefiles/RondPoint2Checkpoints.shp"; }
			match 4 { return "../includes/shapefiles/UPSCheckpoints.shp"; }
			default { return "erreurExpChoice"; }
		}
	}
	
	/* --------------------------------------------------------------------------------------------------- */
	/* --------------------------------------- DEBUT CONSTRUCTEURS --------------------------------------- */
	/* --------------------------------------------------------------------------------------------------- */
	
	action consBluetoothCar {
		create BluetoothCar {
			self.idGuidable <- idGuidableVehicleCreated;
			idGuidableVehicleCreated <- idGuidableVehicleCreated+1;
			do connectCar();
			self.is_connected <- true;
			add self to: vehicules;
		}
	}
	
	action consBike (float vitesse){
		create Bike {
			self.idNonGuidable <- idNonGuidableVehicleCreated;
			self.location <- any_location_in(one_of(Road.population));
			self.speed <- vitesse;
			idNonGuidableVehicleCreated <- idNonGuidableVehicleCreated+1;
			add self to: vehicules;
		}
	}
	
	action consRoads (string shapefilePath){
		file roadsShapefile <- file(shapefilePath);
		create Road from: roadsShapefile;
		roadGraph <- as_edge_graph(Road.population);
	}
	
	action consRuleMessage (string content){
		create Rule {
			self.id <- idRuleCreated;
			self.type <- 0;
			self.contenu <- content;
			idRuleCreated <- idRuleCreated+1; 
		}
	}
	
	action consRuleOneway (Checkpoint directionTarget){
		create Rule {
			self.id <- idRuleCreated;
			self.type <- 1;
			self.oneWayTarget <- directionTarget;
		}
	}
	
	action consHome (point position, float dimensionLongueur, float dimensionLargeur){
		create Home {
			self.location <- position;
			self.dimension_longueur <- dimensionLongueur;
			self.dimension_largeur  <- dimensionLargeur;
			self.id <- idConstructionCreated;
			idConstructionCreated <- idConstructionCreated+1; 
			add self to: constructions;
		}
	}
	
	action consAdmin (point position, float dimensionLongueur, float dimensionLargeur){
		create Administration {
			self.location <- position;
			self.dimension_longueur <- dimensionLongueur;
			self.dimension_largeur <- dimensionLargeur;
			self.id <- idConstructionCreated;
			idConstructionCreated <- idConstructionCreated+1;
			add self to: constructions;
		}
	}
	
	action consBus (float vitesse){
		create Bus {
			self.idNonGuidable <- idNonGuidableVehicleCreated;
			self.location <- any_location_in(one_of(Road.population));
			self.speed <- vitesse;
			idNonGuidableVehicleCreated <- idNonGuidableVehicleCreated+1;
			add self to: vehicules;
		}
	}
	
	action consBusWithStartAndTarget (float vitesse, point start, Checkpoint checkpoint){
		create Bus {
			self.idNonGuidable <- idNonGuidableVehicleCreated;
			self.location <- start;
			self.speed <- vitesse;
			self.target <- checkpoint.location;
			self.is_arrived <- false;
			idNonGuidableVehicleCreated <- idNonGuidableVehicleCreated+1;
			add self to: vehicules;
		}
	}
	
	action consCheckpoints (string shapefilePath){
		file checkpointsShapefile <- file(shapefilePath);
		create Checkpoint from: checkpointsShapefile;
	}
	
	action consCheckpoint (point position, Construction construction){
		create Checkpoint {
			self.location <- position;
			self.construction <- construction;
		}
	}
	
	action consAgent (point position, Administration admin, Home home){
		create Agent {
			self.location <- position;
			self.administration <- admin;
			self.home <- home;
			self.id <- idAgentCreated;
			idAgentCreated <- idAgentCreated+1;
		}
	}
	
	action consSignalisation (point position, float diametre){
		create Signalisation {
			self.id <- idSignalisationCreated;
			self.location <- position;
			self.zone <- diametre;
			idSignalisationCreated <- idSignalisationCreated+1;
		}
	}
	
	action consTrain (point position, Railway railway){
		create Train {
			self.idNonGuidable <- idNonGuidableVehicleCreated;
			self.location <- position;
			self.voie <- railway;
			idNonGuidableVehicleCreated <- idNonGuidableVehicleCreated+1;
		}
	}
	
	action consRailway (point position, float dimensionLongueur, float dimensionLargeur) {
		create Railway {
			self.id <- idConstructionCreated;
			self.location <- position;
			self.dimension_longueur <- dimensionLongueur;
			self.dimension_largeur <- dimensionLargeur;
		}
	}
	
	/* --------------------------------------------------------------------------------------------------- */
	/* ---------------------------------------- FIN CONSTRUCTEURS ---------------------------------------- */
	/* --------------------------------------------------------------------------------------------------- */
	
	
	/* Creation des agents pour l'experience "basique" regroupant
	 * plusieurs proprietes telles que les insertions, croisements...
	 */
	action initBasicExp{
		create Railway from: railway_shapefile;
		loop times: 10 {
			do consBus(0.2);
		}
		loop times: 3 {
			do consBike(0.05);
		}
		loop times: 1 {
			do consBluetoothCar;
		}
		if(socketInitialization(1)!=0) {
			write "--Error camera loading";
		}
	}
	
	/* Creation des agents pour l'experience de test du freinage
	 * si une collision approche entre deux vehicules
	 * Agents: 3 groupes de deux vehicules, pour chaque groupe,
	 * si aucune action n'est effectuée, les vehicules rentrent en
	 * collision
	 */
	action initBrakeIfCollisionExp {
		do consBusWithStartAndTarget(0.1, Checkpoint.population[0].location, Checkpoint.population[1]);
		do consBusWithStartAndTarget(0.2, Checkpoint.population[1].location, Checkpoint.population[0]);
		do consBusWithStartAndTarget(0.1, Checkpoint.population[2].location, Checkpoint.population[3]);
		do consBusWithStartAndTarget(0.1, Checkpoint.population[3].location, Checkpoint.population[2]);
		do consBusWithStartAndTarget(0.3, Checkpoint.population[4].location, Checkpoint.population[5]);
		do consBusWithStartAndTarget(0.1, Checkpoint.population[6].location, Checkpoint.population[5]);
	}
	
	/* Creation des agents pour l'experience de test des insertions
	 * Agents: 2 agents qui s'inserent chacun dans une voie, et un
	 * autre qui lui suit la route sur laquelle il se trouve
	 */
	action initInsertionExp {
		do consBusWithStartAndTarget(0.1, Checkpoint.population[3].location, Checkpoint.population[0]);
		do consBusWithStartAndTarget(0.1, Checkpoint.population[4].location, Checkpoint.population[0]);
		do consBusWithStartAndTarget(0.1, Checkpoint.population[2].location, Checkpoint.population[5]);
	}
	
	/* Creation des agents pour l'experience de test des ronds points
	 * Agents: 3 agents qui vont devoir se servir du rond point pour 
	 * atteindre leur checkpoint cible
	 */
	action initRondPointExp {
		do consBusWithStartAndTarget(0.1, Checkpoint.population[4].location, Checkpoint.population[0]);
		do consBusWithStartAndTarget(0.1, Checkpoint.population[5].location, Checkpoint.population[6]);
		/* creation des regles */
		do consRuleOneway(Checkpoint.population[0]);
		do consRuleOneway(Checkpoint.population[1]);
		do consRuleOneway(Checkpoint.population[2]);
		do consRuleOneway(Checkpoint.population[3]);
		do consRuleOneway(Checkpoint.population[7]);
		do consRuleOneway(Checkpoint.population[8]);
		do consRuleOneway(Checkpoint.population[9]);
		/* attribution des regles aux routes */
		ask Road.population[16]{
			//Ajout de la regle 0 a la route 16
			do addRule(Rule.population[0]);
		}
		ask Road.population[4]{
			//Ajout de la regle 4 a la route 4
			do addRule(Rule.population[4]);
		}
		ask Road.population[7]{
			//Ajout de la regle 1 a la route 7
			do addRule(Rule.population[1]);
		}
		ask Road.population[10]{
			//Ajout de la regle 5 a la route 10
			do addRule(Rule.population[5]);
		}
		ask Road.population[13]{
			//Ajout de la regle 2 a la route 13
			do addRule(Rule.population[2]);
		}
		ask Road.population[12]{
			//Ajout de la regle 6 a la route 12
			do addRule(Rule.population[6]);
		}
		ask Road.population[17]{
			//Ajout de la regle 3 a la route 17
			do addRule(Rule.population[3]);
		}
	}
	
	/* Creation des agents pour l'experience sur le campus de l'universite
	 * Paul Sabatier
	 * Cette experience contiendra des bus et des velos
	 */
	action initUPSExp {
		loop times: 20 {
			do consBus(0.2);
		}
		loop times: 20 {
			do consBike(0.1);
		}
		loop times: 3 {
			do consBluetoothCar;
		}
	}
	
	/* Algorithme d'initialisation:
	 * - creer les routes et checkpoints en fonction de l'experience
	 *   choisie
	 * - initialiser le graphe des routes
	 * - creer les agents correspondant a l'experience choisie
	 */
	init {
		create Road from: roads_shapefile;
		create Checkpoint from: checkpoints_shapefile;
		roadGraph <- as_edge_graph(Road.population);
		
		switch expChoice{
			match 0 { do initBasicExp; break; }
			match 1 { do initBrakeIfCollisionExp; break;}
			match 2 { do initInsertionExp; break; }
			match 3 { do initRondPointExp; break; }
			match 4 { do initUPSExp; break; }
			default { write "erreur expChoice"; break; }
		}
	}
	
	/*------------------------------------------------------------------------------------------------ */
	/* ---------------------------------------  DEBUT REFLEXES --------------------------------------- */
	/* ----------------------------------------------------------------------------------------------- */
	
	/** REFLEX ONE_STEP
	 * Incremente la propriete nb_step permettant de savoir à un moment t a quelle etape
	 * nous nous trouvons
	 */
	reflex one_step {
		
		nb_step <- nb_step +1;
	}
	
	/** REFLEX STOP_SIMULATION
	 * Condition: quand plus de donnees sont presentes sur la position des voitures depuis la camera
	 * Deconnecte toute les voitures connectees en Bluetooth puis met en pause l'experimentation
	 */
	reflex stop_simulation when: nb_step = 100 {
		
		loop car over: vehicules{
			if(car is GuidableVehicle){
				GuidableVehicle guidableCar <- GuidableVehicle(car);
				ask guidableCar{
					if(is_connected){
						do disconnectCar();
					}
				}
			}
		}
		do pause;
	}
	
	/* ---------------------------------------------------------------------------------------------- */
	/* ---------------------------------------- FIN REFLEXES ---------------------------------------- */
	/* ---------------------------------------------------------------------------------------------- */
		
}