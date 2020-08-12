from Mother import *
import math

def not_the_same_vehicle(centers, new_center, dist):
    """
    Fonction permettant de ne pas identifier deux fois le même véhicule
    avec un décalage de quelques pixels pour éviter le dédoublement.
    """
    for c in centers:
        formula = math.sqrt((c[0]-new_center[0])^2 + (c[1]-new_center[1])^2)
        if formula < dist:
            return False
    return True

"""
Classe Fille qui contient les traitements plus spécifiques selon les images.
"""

class ImageToForm(ImageTreatment):

    def __init__(self, state):
        ImageTreatment.__init__(self, state)
        self.centers = []
        self.boxes = []
        self.crop = []

    def lighting_image(self):
        """ Traitement de l'intensité de lumière sur l'image + Seuillage """
        hsv = cv.cvtColor(self.current_state,cv.COLOR_BGR2HSV) # passage en hsv
        cv.imwrite("hsv.jpg", hsv)
        h,s,v= cv.split(hsv)
        ret_h, th_h = cv.threshold(h,75,255,cv.THRESH_BINARY+cv.THRESH_OTSU)
        ret_s, th_s = cv.threshold(s,168,255,cv.THRESH_BINARY+cv.THRESH_OTSU)
        ret_v, th_v = cv.threshold(v,114,255,cv.THRESH_BINARY+cv.THRESH_OTSU)
        # Enregistrement des trois images traitées selon chaque axe HSV
        cv.imwrite("th_h.jpg",th_h)
        cv.imwrite("th_s.jpg",th_s)
        cv.imwrite("th_v.jpg",th_v)
        # Selection de combinaison de filtres qui semble adaptée à l'extraction de l'imformation
        # Dépends fortement du contexte : Lumière et Couleurs de fond
        th = cv.bitwise_or(th_v,th_s)
        cv.imwrite("combo_VS.jpg",th)

    def extraction_vehicles(self):
        """ Extraction de l'information pertinente en s'efforcant de réduire le bruit """
        img = self.original_state
        hsv = cv.cvtColor(self.current_state, cv.COLOR_BGR2HSV)
        self.processed.append([hsv])
        h,s,v= cv.split(hsv)
        ret_v, th_v = cv.threshold(s,168,255,cv.THRESH_BINARY+cv.THRESH_OTSU)
        self.processed.append([th_v])
        bordersize=10
        th_v = cv.bitwise_not(th_v)
        th = cv.copyMakeBorder(th_v, top=bordersize, bottom=bordersize, left=bordersize, right=bordersize, borderType= cv.BORDER_CONSTANT, value=[0,0,0] )
        #Remplissage des contours
        im_floodfill = th.copy()
        h, w = th.shape[:2]
        mask = np.zeros((h+2, w+2), np.uint8)
        cv.floodFill(im_floodfill, mask, (0,0), 255)
        self.processed.append([im_floodfill])
        self.current_state = im_floodfill
        cv.imwrite("im_floodfill.png",im_floodfill)

    def detecting_edges(self):
        """ Detection des vehicules sur l'image """
        #print(cv.findContours(self.current_state, cv.RETR_LIST, cv.CHAIN_APPROX_SIMPLE))
        copie = self.original_state.copy()
        _,contours,h = cv.findContours(self.current_state, cv.RETR_LIST, cv.CHAIN_APPROX_SIMPLE)
        shape = "None"
        error = 20
        print("Nombre de contours :",len(contours))
        for cnt in contours:
            perimetre = cv.arcLength(cnt,True)
            approx = cv.approxPolyDP(cnt,0.1*perimetre,True)
            M = cv.moments(cnt)
            if (M["m00"]!=0):
                cX = int(M["m10"] / M["m00"])
                cY = int(M["m01"] / M["m00"])
                (x, y, w, h) = cv.boundingRect(cnt)  # on fait un rectangle
                cv.rectangle(copie, (x,y), (x+w, y+h), (255,0,0),5)
                if (w < self.vehicules_dims[0] + error and w > self.vehicules_dims[0] - error
                    and h < self.vehicules_dims[1]+ error and h > self.vehicules_dims[1] - error
                    and not_the_same_vehicle(self.centers, [cX,cY], self.vehicules_dims[0]/2 ) ):
                    self.centers.append([cX,cY])
                    self.boxes.append((x, y, w, h))
                    print("Centre de gravité :   ", cX,"---", cY)
                    L = math.floor(w/2)
                    data = self.original_state[cY-L:cY+L,cX-L:cX+L]
                    self.crop.append(data)
        cv.imwrite('copie.jpg',copie)

    def identification(self):
        """ Identification des véhicules selon leurs couleurs """
        img = self.crop[0]
        norm = 1/np.maximum(1,np.sum(img, axis=2))
        norm_img_R = img[:,:,0]*norm # recup de la dimension Rouge
        norm_img_V = img[:,:,1]*norm # recup de la dimension Verte
        norm_img_B = img[:,:,2]*norm # recup de la dimension Bleu
        moy_R = np.mean(norm_img_R) # moyenne dimension Rouge
        moy_V = np.mean(norm_img_V) # moyenne dimension Verte
        moy_B = np.mean(norm_img_B) # moyenne dimension Verte
        print("Moyenne R", moy_R)
        print("Moyenne V", moy_V)
        print("Moyenne B", moy_B)

    def canny(self, min, max):
        gray = cv.cvtColor(self.current_state, cv.COLOR_BGR2GRAY)
        edges = cv.Canny(gray, min, max)
        self.current_state = edges
        cv.imwrite("canny.jpg", edges)
