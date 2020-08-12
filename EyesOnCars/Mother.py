import numpy as np
import cv2 as cv
import math

"""
Classe Mère regroupant tous les traitements primaires des images.
"""

class ImageTreatment():

    def __init__(self, state):
        self.current_state = cv.imread(state) # etat courant de l'image traitée
        self.original_state = self.current_state # etat original sauvegardé
        self.processed = [] # liste vide qui contiendra tous les états de l'image
        self.vehicules_dims = (80,80) # hypothénuse du boxing des véhicules

    def affichage_historique(self, scale):
        """
        Methode pour afficher l'historique des traitements d'image realisés
        sur une seule et même image.
        """
        rows = len(self.processed)
        cols = len(self.processed[0])
        rowsAvailable = isinstance(self.processed[0], list)
        width = self.processed[0][0].shape[1]
        height = self.processed[0][0].shape[0]
        if rowsAvailable:
            for x in range ( 0, rows):
                for y in range(0, cols):
                    if self.processed[x][y].shape[:2] == self.processed[0][0].shape [:2]:
                        self.processed[x][y] = cv.resize(self.processed[x][y], (0, 0), None, scale, scale)
                    else:
                        self.processed[x][y] = cv.resize(self.processed[x][y], (self.processed[0][0].shape[1], self.processed[0][0].shape[0]), None, scale, scale)
                    if len(self.processed[x][y].shape) == 2: self.processed[x][y]= cv.cvtColor(self.processed[x][y], cv.COLOR_GRAY2BGR)
            imageBlank = np.zeros((height, width, 3), np.uint8)
            hor = [imageBlank]*rows
            hor_con = [imageBlank]*rows
            for x in range(0, rows):
                hor[x] = np.hstack(self.processed[x])
            ver = np.vstack(hor)
        else:
            for x in range(0, rows):
                if self.processed[x].shape[:2] == self.processed[0].shape[:2]:
                    self.processed[x] = cv.resize(self.processed[x], (0, 0), None, scale, scale)
                else:
                    self.processed[x] = cv.resize(self.processed[x], (self.processed[0].shape[1], self.processed[0].shape[0]), None,scale, scale)
                if len(self.processed[x].shape) == 2: self.processed[x] = cv.cvtColor(self.processed[x], cv.COLOR_GRAY2BGR)
            hor= np.hstack(self.processed)
            ver = hor
        cv.imshow("PROCESSING...", ver) # permet un affichage complet de la liste d'image donnée en paramètre
        cv.waitKey(0)

    def reset(self):
        """
        Nettoie la mémoire des traitements.
        Le système revient à son état initial.
        """
        self.current_state = self.original_state
        self.processed = []

    def get_state(self, image_name):
        """ Attribut une image ( équivalent de l'etat courant du systeme ) """
        self.current_state = cv.imread(image_name)
        self.original_state = cv.imread(image_name)

    def seuillage(self, th1, th2):
        """ Seuillage entre th1 et th2 de l'etat courant. """
        _, self.current_state = cv.threshold(self.current_state, th1, th2, cv.THRESH_BINARY) # seuillage
        self.processed.append([self.current_state])

    def filtering(self, methode, kern): # A appliquer sur une image bruitée
        """ Filtrage Median ou Moyen ou Gaussien """
        # methode = 0 pour Filtrage moyen
        # methode = 1 pour Filtrage median
        # methode = 2 pour Filtrage gaussien
        if methode == 1:
            new = cv.medianBlur(self.current_state,kern) # Filtre Median
        elif methode == 2:
            new = cv.GaussianBlur(self.current_state, (kern, kern), cv.BORDER_DEFAULT) # Filtre Gaussien
        else:
            new = cv.blur(self.current_state,(kern,kern)) # Filtre Moyen
        new_name = "filtrage.jpg"
        cv.imwrite(new_name, new) # enregistrement
        self.processed.append([new])
