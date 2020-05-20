#from bluetooth import *

# Créé une socket Bluetooth
class Bluetooth :

    def __init__(self):
        #self.socket = BluetoothSocket(RFCOMM)
        print("Init connexion")

    def connect(self, macaddr):
        #self.socket.connect((macaddr, 1))
        print("Voiture connectée")

    def send(self, ordre):
        #self.socket.send(ordre)
        print("Ordre envoyé à la voiture")

    # Arrete la connexion Bluetooth
    def close(self, selectedCar):
        #try :
            # print("Appareils AVANT SUPPR : ", appareils_connectes)
            #self.socket.close() # Ferme la socket de communication
            # TODO : Vérifier qu'on ferme bien la bonne socket !!
            #appareils_connectes[selectedCar].close()
            #appareils_connectes[selectedCar] = None  # Supprime la voiture des appareils connectés
            print("Appareil deconnécté voiture: ", selectedCar)
            # print("Appareils APRES SUPPR : ", appareils_connectes)
        #except OSError :
            #print("Erreur de déconnexion !")