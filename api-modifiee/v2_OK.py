import os
import sys
import time
from copy import deepcopy
#from tkinter import *
#import tkinter.ttk as ttk 
from BluetoothClass import * 

# Initialise n emplacements pour des sockets Bluetooth

macro_rec = []
#Initialise les noms des appreils connectés
app_1 = ""
app_2 = ""
app_3 = ""
apps=[app_1, app_2, app_3]

# Une socket Bluetooth
def connectNewDevice(macaddr, selectedCar) :
    new_socket = Bluetooth()
    print("selectedCar = ", selectedCar)
    if appareils_connectes[selectedCar] == None :
        #print("appareils_connectes[selectedCar] = ", appareils_connectes[selectedCar])
        try :
            new_socket.connect(macaddr)
            appareils_connectes[selectedCar] = new_socket  # enregistre la socket dans notre liste d'appareils connectés
        except OSError:
            # Gère une erreur de connexion, si on désactive le bluetooth après le scan
            text_state_car.set("Connection ERROR ! Device is not ON/available")
    else :
        print("Vous êtes déjà connecté à cet appareil !")

# Déconnexion d'une socket
def disconnectDevice(selectedCar):
    appareils_connectes[selectedCar].close(selectedCar)
    appareils_connectes[selectedCar] = None
    # TODO : IF closed -> Refresh affichage graphique : "Connection successful" -> "Enter a device name"

###########################################################################
# Bluetooth scanning
"""
appareilsDispo = []      # Liste des appareils proches
def f_scan():
    text_state_car.set('Start scanning')
    appareilsDetectes = [] #discover_devices(lookup_names=True, duration=2)
    print("appareilsDetectes =", appareilsDetectes)
     
    if appareilsDispo == [] :
        #La liste des appareils PROCHES
        for _mac, _name in appareilsDetectes:
            # Filtre seulement les appareils "beewi"
            if "beewi" in _name.lower():
                print(_mac, " ", _name)
                appareilsDispo.append((_mac, _name))
        print("appareilsDispo =", appareilsDispo)
        for newMac, newName in appareilsDispo:
            # On a une nouvelle voiture Beewi
            if ("beewi" in newName.lower()):
                # Ajoute un nouveau véhicule à la fin de la liste de choix
                choix_voitures['values'] = (*choix_voitures['values'], newName)
    else :
        macDispo = [x[0] for x in appareilsDispo]
        # print("maaac",macDispo)
        # Met à jour la liste des véhicules disponibles
        for newMac, newName in appareilsDetectes:
            print(newMac,newName)
            # On a une nouvelle voiture Beewi
            if (newMac not in macDispo) and ("beewi" in newName.lower()):
                # Ajoute un nouveau véhicule à la fin de la liste de choix
                choix_voitures['values'] = (*choix_voitures['values'], newName)

    # Maintenant on peut selectionner une voiture :
    choix_voitures['state'] = "enabled"
    btn_connect['state'] = NORMAL
"""
# Bluetooth connection
"""
def f_connect():
    car = []
    selectedCar = choix_voitures.current()
    # choix_voitures['state'] = "disabled"
    # Assure qu'on ait choisi une voiture parmi les choix disponibles
    if selectedCar != -1 : 
        try :
            car = appareilsDispo[selectedCar]
            # Connexion à la voiture
            macaddr = car[0]
        except IndexError:  # outofbounds
            text_state_car.set('Please enable Bluetooth on your laptop !')

        if (car != []):
             # Enregistre la socket associée à la voiture connectée
            new_sock = Bluetooth()
            try :
                new_sock.connect(macaddr)
                appareils_connectes[selectedCar] = new_sock  # passe le numéro de la voiture (indice de la liste de choix)
            except OSError:
                # Gère une erreur de connexion, si on désactive le bluetooth après le scan
                print("Connection ERROR ! Device is not ON/available")
    print("Les appareils connectes :",appareils_connectes)
"""
#Affichage appareils connectés
def devices_connected(car):
    for i in range (len(apps)):
        if(apps[i] == ""):
            apps[i] = car
    app_connect_1.pack_forget()
    app_connect_2.pack_forget()
    app_connect_3.pack_forget()
    app_connect_1.pack(anchor="n")
    app_connect_2.pack(anchor="n")
    app_connect_3.pack(anchor="n")

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
def m1(event):
    forward_to_left(event)
    time.sleep(1)
    backward_to_right(event)
    time.sleep(1)
    forward_to_left(event)

# Macro 2 - Demi-tour droite
def m2(event):
    forward_to_right(event)
    time.sleep(1)
    backward_to_left(event)
    time.sleep(1)
    forward_to_right(event)

# Macro 3 - Cercle dans le sens des aiguilles d'une montre
def m3(event):
    forward_to_right(event)
    time.sleep(0.5)
    forward_to_right(event)
    time.sleep(0.5)
    forward_to_right(event)
    time.sleep(0.5)
    forward_to_right(event)
    time.sleep(0.5)
    forward_to_right(event)

# Macro 4 - Cercle dans le sens inverse des aiguilles d'une montre
def m4(event):
    forward_to_left(event)
    time.sleep(0.5)
    forward_to_left(event)
    time.sleep(0.5)
    forward_to_left(event)
    time.sleep(0.5)
    forward_to_left(event)
    time.sleep(0.5)
    forward_to_left(event)

# Macro 5 - Rangement en creneau
def m5(event):
    move_forward(event)
    time.sleep(0.5)
    backward_to_right(event)
    time.sleep(1)
    backward_to_right(event)
    time.sleep(1)
    backward_to_left(event)
    time.sleep(0.1)

# Macro 6 - Rangement en épis avant
def m6(event):
    forward_to_left(event)
    time.sleep(1)
    move_backward(event)

# Macro 7 - Rangement en épis arriere
def m7(event):
    backward_to_left(event)
    time.sleep(1)
    move_forward(event)

# Macro 8 - Slalom
def m8(event):
    forward_to_right(event)
    time.sleep(0.7)
    forward_to_left(event)
    time.sleep(0.7)
    forward_to_right(event)
    time.sleep(0.7)
    forward_to_left(event)
    time.sleep(0.7)
    forward_to_right(event)

###########################################################################
# Fonction d'enregistrement

def write_rec():
    global macro_rec
    print("oui")
    if (varRec.get()):
        print("BEGIN : REC")
    else:
        print("END : REC")
        print(macro_rec)
        macro_rec = []

def read_rec(event,macro):
    for c in macro:
        if (c==1):  
            move_forward(event)
        elif (c==2):
            move_backward(event)
        elif (c==3):
            forward_to_left(event)
        elif (c==4):
            forward_to_right(event)
        elif (c==5):
            backward_to_left(event)
        elif (c==6):  
            backward_to_right(event)
        time.sleep(1)        




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
        disconnectDevice(i)

#
if len(sys.argv) == 2:
    nombre_voiture = int(sys.argv[1])
    appareils_connectes = [None] * nombre_voiture 
    #TESTS
    #connect_all_cars(nombre_voiture)
    #move_backward(1)
    #forward_to_right(1)
    #forward_to_left(1)
    #backward_to_right(1)
    #backward_to_left(0)
    #disconnect_all_cars(appareils_connectes)
else: 
    print("Usage: <nombre de voiture>") 



