# -*- encoding: UTF-8 -*-

import os
import sys
import time
from copy import deepcopy
#from tkinter import *
#import tkinter.ttk as ttk 
from BluetoothClass import * 

# Initialise n emplacements pour des sockets Bluetooth

# Une socket Bluetooth
def connectNewDevice(macaddr, selectedCar) :
    new_socket = Bluetooth()
    if appareils_connectes[selectedCar] == None :
        #print("appareils_connectes[selectedCar] = ", appareils_connectes[selectedCar])
        new_socket.connect(macaddr)
        appareils_connectes[selectedCar] = new_socket  # enregistre la socket dans notre liste d'appareils connectés
    else :
        print("Vous etes deja connecte a cet appareil !")

# Déconnexion d'une socket
def disconnectDevice(selectedCar):
    if appareils_connectes[selectedCar] != None:
        appareils_connectes[selectedCar].close(selectedCar)
        appareils_connectes[selectedCar] = None
    else: 
        print("L appareil ", selectedCar, " est deja deconnecte")
    # TODO : IF closed -> Refresh affichage graphique : "Connection successful" -> "Enter a device name"



###########################################################################
###########################################################################

"""
    - STOP Forward  - \x00
    - Forward       - \x01
    - STOP Backward - \x02
    - Backward      - \x03
    - STOP Left     - \x04
    - Left          - \x05
    - STOP Right    - \x06
    - Right         - \x07
"""

# Repositionne les roues droites
def reset_wheels(selectedCar):
    print("Repositionnement des roues voiture: ", selectedCar)
    try:
        appareils_connectes[selectedCar].send('\x04')  # STOP Left
        appareils_connectes[selectedCar].send('\x06')  # STOP Right
    except (OSError, AttributeError) as e :
        #text_state_car.set("You are not connected !")
        print(e)
        
"""
    Les fonctions "stop_...()" arrêtent d'abord les autres mouvements
    AVANT de faire l'action souhaitée
"""

def stop_before_backward(selectedCar):
    reset_wheels(selectedCar)
    print("Stop before backward voiture: ", selectedCar)
    try:
        appareils_connectes[selectedCar].send('\x00')  # STOP Forward
    except (OSError, AttributeError) as e :
        #text_state_car.set("You are not connected !")
        print(e)

def stop_before_forward(selectedCar):
    reset_wheels(selectedCar)
    print("Stop before forward voiture: ", selectedCar)
    try:
        appareils_connectes[selectedCar].send('\x02')  # STOP Backward
    except (OSError, AttributeError) as e :
        #text_state_car.set("You are not connected !")
        print(e)

def stop_all(selectedCar):
    print("Stop all voiture: ", selectedCar)
    try:
        appareils_connectes[selectedCar].send('\x00')  # STOP Forward
        appareils_connectes[selectedCar].send('\x02')  # STOP Backward
    except (OSError, AttributeError) as e :
        #text_state_car.set("You are not connected !")
        print(e)
    reset_wheels(selectedCar)

"""
Bind des touches :
    A : Reculer et tourner à gauche
    E : Reculer et tourner à droite
    Z : Avancer en ligne droite
    S : Reculer en ligne droite
    Q : Avancer et tourner à gauche
    D : Avancer et tourner à droite
"""

###########################################################################
# Fonctions directement associées aux Listeners sur les touches assignées
def move_forward(num_car):
    selectedCar = appareils_connectes[num_car]
    stop_before_forward(num_car)  # reset current moves
    try :
        #if (varRec.get()):
        #    macro_rec.append(1)
        #else:
        print("Move forward voiture: ", num_car)
        selectedCar.send('\x01')  # Avance en ligne droite
        #sv.set('Forward\n' + sv.get())  
    except (OSError, AttributeError) as e :
        #text_state_car.set("You are not connected !")
        print(e)

def move_backward(num_car):
    selectedCar = appareils_connectes[num_car]
    stop_before_backward(num_car)  # reset current moves
    try:
        #if (varRec.get()):
        #   macro_rec.append(2)
        #else:
        print("Move backward voiture: ", num_car)
        selectedCar.send('\x03')  # Recule en ligne droite
        #sv.set('Backward\n' + sv.get())
    except (OSError, AttributeError) as e :
        #text_state_car.set("You are not connected !")
        print(e)

# Fonctions de déplacements plus avancées
# Avance et tourne à gauche simultanément
def forward_to_left(num_car):
    selectedCar = appareils_connectes[num_car]
    try:
        #if (varRec.get()):
        #    macro_rec.append(3)
        #else:
        print("Forward to left voiture: ", num_car)
        selectedCar.send('\x05')  # Tourne à gauche
        selectedCar.send('\x01')  # Avance
        #sv.set('Forward Left\n' + sv.get())
    except (OSError, AttributeError) as e :
        #text_state_car.set("You are not connected !")
        print(e)

# Avance et tourne à droite simultanément
def forward_to_right(num_car):
    selectedCar = appareils_connectes[num_car]
    try:
        #if (varRec.get()):
        #    macro_rec.append(4)
        #else:
        print("Forward to right voiture: ", num_car)
        selectedCar.send('\x07')  # Tourne à droite
        selectedCar.send('\x01')  # Avance
        #sv.set('Forward Right\n' + sv.get())
    except (OSError, AttributeError) as e :
        #text_state_car.set("You are not connected !")
        print(e)

# Recule et tourne à gauche simultanément
def backward_to_left(num_car):
    selectedCar = appareils_connectes[num_car]
    try:
        #if (varRec.get()):
        #    macro_rec.append(5)
        #else:
        print("Backward to left voiture: ",  num_car)
        selectedCar.send('\x05')  # Tourne à gauche
        selectedCar.send('\x03')  # Recule
        #sv.set('Backward Left\n' + sv.get())
    except (OSError, AttributeError) as e :
        #text_state_car.set("You are not connected !")
        print(e)
        
# Recule et tourne à droite simultanément       
def backward_to_right(num_car):
    selectedCar = appareils_connectes[num_car]
    try:
        #if (varRec.get()):
        #   macro_rec.append(6)
        #else:
        print("Backward to right voiture: ", num_car)
        selectedCar.send('\x07')  # Tourne à droite
        selectedCar.send('\x03')  # Recule
        #sv.set('Backward Right\n' + sv.get())
    except (OSError, AttributeError) as e :
        text_state_car.set("You are not connected !")
        print(e)

###########################################################################
# Fonctions de macro prédéfinies

# Macro 1 - Demi-tour gauche
def m1(selectedCar):
    forward_to_left(selectedCar)
    time.sleep(1)
    backward_to_right(selectedCar)
    time.sleep(1)
    forward_to_left(selectedCar)

# Macro 2 - Demi-tour droite
def m2(selectedCar):
    forward_to_right(selectedCar)
    time.sleep(1)
    backward_to_left(selectedCar)
    time.sleep(1)
    forward_to_right(selectedCar)

# Macro 3 - Cercle dans le sens des aiguilles d'une montre
def m3(selectedCar):
    forward_to_right(selectedCar)
    time.sleep(0.5)
    forward_to_right(selectedCar)
    time.sleep(0.5)
    forward_to_right(selectedCar)
    time.sleep(0.5)
    forward_to_right(selectedCar)
    time.sleep(0.5)
    forward_to_right(selectedCar)

# Macro 4 - Cercle dans le sens inverse des aiguilles d'une montre
def m4(selectedCar):
    forward_to_left(selectedCar)
    time.sleep(0.5)
    forward_to_left(selectedCar)
    time.sleep(0.5)
    forward_to_left(selectedCar)
    time.sleep(0.5)
    forward_to_left(selectedCar)
    time.sleep(0.5)
    forward_to_left(selectedCar)
   
# Macro 5 - Rangement en creneau
def m5(selectedCar):
    move_forward(selectedCar)
    time.sleep(0.5)
    backward_to_right(selectedCar)
    time.sleep(1)
    backward_to_right(selectedCar)
    time.sleep(1)
    backward_to_left(selectedCar)
    time.sleep(0.1)

# Macro 6 - Rangement en épis avant
def m6(selectedCar):
    forward_to_left(selectedCar)
    time.sleep(1)
    move_backward(selectedCar)

# Macro 7 - Rangement en épis arriere
def m7(selectedCar):
    backward_to_left(selectedCar)
    time.sleep(1)
    move_forward(selectedCar)

# Macro 8 - Slalom
def m8(selectedCar):
    forward_to_right(selectedCar)
    time.sleep(0.7)
    forward_to_left(selectedCar)
    time.sleep(0.7)
    forward_to_right(selectedCar)
    time.sleep(0.7)
    forward_to_left(selectedCar)
    time.sleep(0.7)
    forward_to_right(selectedCar)


####### INFORMATIONS
## VERSION MODIFIEE EN RAISON DU CONFINEMENT (TOUTES LES CONNEXIONS BLUETOOTH SONT SUPPRIMEES AINSI QUE LA GUI)
## PARAM DU PROGRAMME: NOMBRE DE VOITURE

#CREATION/CONNEXION DES VOITURES
def connect_all_cars(nombre_voiture):
    for i in range(nombre_voiture):
        connectNewDevice(None, i)

#SUPPRESSION/DECONNEXION DES VOITURES
def disconnect_all_cars(appareils_connectes):
    for i in range(len(appareils_connectes)):
        if appareils_connectes[i] != None:
            disconnectDevice(i)


#Nombre maximal de voiture placé à 30
appareils_connectes = [None] * 30



