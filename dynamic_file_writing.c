#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <string.h>
#include <signal.h>

#define SUCCESS 0
#define FAIL 1
#define MAX_FILE_PATH_SIZE 100

float delay;
char file_path[MAX_FILE_PATH_SIZE];
int nb_cars;
int step;
int max_steps;

void verification_parametres(int argc, char ** argv){
	if(argc != 5){
		fprintf(stderr, "Usage: %s <file_path> <delay between 0.0 and 1.0 second> <nb_cars> <max_steps>\n", argv[0]);
		exit(FAIL);
	}
}

void traiterSIGALRM(int signal){
	FILE * file = fopen(file_path, "w");
	for(int i = 0; i < nb_cars; i++){
		int nombre_aleatoire_x = rand()%(200-100)+100;
		int nombre_aleatoire_y = rand()%(200-100)+100;
		int nombre_aleatoire_rotation = rand()%(360);
		printf("Voiture %d - Ecriture: x %d y %d rotation %d\n", i, nombre_aleatoire_x, nombre_aleatoire_y, nombre_aleatoire_rotation);
		fprintf(file, " %d , %d , %d ,", nombre_aleatoire_x, nombre_aleatoire_y, nombre_aleatoire_rotation);
	}
	fprintf(file, "\n");
	fclose(file);
	/* redefinition de l'alarme */
	ualarm(delay*1000000.0, 0);
	step++;
}

int main(int argc, char ** argv){
	srand(time(NULL));
	/* Verification de la validite de l'utilisation du script */
	verification_parametres(argc, argv);
	strcpy(file_path, argv[1]);
	delay = atof(argv[2]);
	step = 0;
	nb_cars = atoi(argv[3]);
	max_steps = atoi(argv[4]);

	/* definition du comportement quand l'alarme sonne */
	struct sigaction action;
	action.sa_flags = 0;
	action.sa_handler = traiterSIGALRM;
	if(sigemptyset(&action.sa_mask) != 0){
		perror("Erreur creation du masque vide sigemptyset");
		exit(2);
	}
	if(sigaction(SIGALRM, &action, NULL) != 0){
		perror("Erreur definition du comportement sigaction");
		exit(3);
	}

	/* Placement de l'alarme et traitement */
	ualarm(delay*1000000.0, 0);
	while(step < max_steps);

	return SUCCESS;
}