import cv2
import sys
import imutils
import math
import csv
import time
import socket

from Mother import *
from ImageToForm import *

major_ver, minor_ver, subminor_ver = cv2.__version__.split('.') # Version de openCV 4.1.2

#FOR SOCKET CONNECTION
server_host = '127.0.0.1'
server_port = 6000
#---------------------

# Quelques valeurs en durs qui seront à modifiées à l'avenir
height = 97 # hauteur de la caméra en cm
angle = 30 # angle en degré
width_map_cm = 2*height/0.5
width_map_pix = 300
scale_cmpix = width_map_pix/width_map_cm # coeff passage pix à cm

def create_tracker(tracker: str):
	""" Créer un tracker """
	# type de tracker selon la précision que l'on veut obtenir ou les fps
	tracker_types = ['BOOSTING', 'MIL','KCF', 'TLD', 'MEDIANFLOW', 'GOTURN', 'MOSSE', 'CSRT']
	tracker_type = tracker_types[0]

	if tracker not in tracker_types:
		print(f'error: not supported tracker \'{tracker}\', available trackers are {tracker_types}.')
		sys.exit(-1)

	if int(major_ver) == 3 and int(minor_ver) < 3:
		tracker = cv2.Tracker_create(tracker_type)
	else:
		if tracker_type == 'BOOSTING':
			tracker = cv2.TrackerBoosting_create()
		elif tracker_type == 'MIL':
			tracker = cv2.TrackerMIL_create()
		elif tracker_type == 'KCF':
			tracker = cv2.TrackerKCF_create()
		elif tracker_type == 'TLD':
			tracker = cv2.TrackerTLD_create()
		elif tracker_type == 'MEDIANFLOW':
			tracker = cv2.TrackerMedianFlow_create()
		elif tracker_type == 'GOTURN':
			tracker = cv2.TrackerGOTURN_create()
		elif tracker_type == 'MOSSE':
			tracker = cv2.TrackerMOSSE_create()
		elif tracker_type == 'CSRT':
			tracker = cv2.TrackerCSRT_create()

	return tracker

def normalize(box, scale):
	return tuple(int(a * scale) for a in box)

def detection_vehicles(frame):
	""" Detection des véhicules avec traitement de l'image """
	boxes = []
	infos = []

	# TRAITEMENT IMAGE
	initiate = ImageToForm(frame)
	initiate.lighting_image()
	initiate.extraction_vehicles()
	initiate.filtering(1,5)
	initiate.detecting_edges()
	colors = [(255, 255, 0), (255, 0, 255), (0, 255, 255), (255, 255, 255),(0, 0, 255)] # 5 couleurs pour 5 véhicules max
	i = 0 # compteur nombre de voitures
	for cars in initiate.boxes:
		boxes.append(cars)
		infos.append((colors[i], f'Car {i}'))
		i+=1
	return boxes, infos


if __name__ == '__main__':
	# Variables globales
	tracker_type = 'BOOSTING'
	img_width = 300

	# Read the video
	# video = cv2.VideoCapture('/home/Victor/Vidéos/car-v3.mp4') # pour lire une vidéo pré-enregistrée
	video = cv2.VideoCapture(0) # récupérer le flux vidéo de la webcam ( peut changer d'un pc à l'autre )
	if not video.isOpened(): # gestion de l'ouverture de la vidéo
		print('error: could not open the video, are you sure the file exists?')
		sys.exit(-2)

	# Lecture de la première image
	ok, frame = video.read()
	cv2.imwrite('frame.jpg',frame) # on enregistre la première frame sur laquelle on va effectuer les traitements
	scale = len(frame[0]) / img_width

	frame_small = imutils.resize(frame, width=img_width)
	if not ok:
		print('error: cannot read the video file')
		sys.exit(-2)

	# Detection des vehicules et association à un tracker
	boxes, infos = detection_vehicles("frame.jpg")
	print(f'info: {len(boxes)} boxes selected')

	# Création du multitracker qui combinent les trackers de tous les véhicules
	tracker = cv2.MultiTracker_create()
	for bbox, (color, name) in zip(boxes, infos):
		print(f'info: {name}: {bbox}')
		small_bbox = normalize(bbox, 1 / scale)
		tracker.add(create_tracker(tracker_type), frame_small, small_bbox)

	cv2.imshow('[eXpav]', frame)

	# Initialisation des vecteurs Vitesse et Centre
	speed_timer = cv2.getTickCount()
	centers = [((x+w) // 2, (y+h) // 2) for x, y, w, h in (normalize(box, 1 / scale) for box in boxes)]
	speed_vectors = [(0,0) for _ in boxes]

	# Ecriture des noms des colonnes dans le CSV LOGS
	file = open(("camera_data_logs.csv").format(0), "a")
	writer = csv.writer(file)
	writer.writerow(("Center X", "Center Y", "Speed X", "Speed Y"))
	deb = time.time()

	#SOCKET connection to server
	client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	client_socket.connect((server_host, server_port))

	# Tout le long du flux vidéo...
	while video.isOpened():
		# Lecture d'une frame
		ok, frame = video.read()
		if not ok:
			break
		frame_small = imutils.resize(frame, width=img_width)

		# Initialisation timer
		timer = cv2.getTickCount()

		# Mise à jour des trackers ( recentrage )
		ok, boxes = tracker.update(frame_small)

		# Mise à jour des vecteurs Vitesse et Centre
		if cv2.getTickCount() - speed_timer > .2 * cv2.getTickFrequency():
			fin = time.time() # en secondes
			laps = fin-deb # en secondes
			new_centers = [((x+w) / 2, (y+h) / 2) for x, y, w, h in boxes]
			dist_vectors = [((nx - ox)/laps, (ny - oy)/laps) for (ox, oy), (nx, ny) in zip(centers, new_centers)]
			deb = fin # en secondes
			datas = zip(new_centers, dist_vectors)
			centers = new_centers
			count = 0

			# Inscription des nouvelles données dans le CSV de manière sequentielle (fichier de logs)
			# et preparation des donnees a envoyer a Gama
			data_to_send = ''
			for d in datas:
				writer.writerow((d[0][0], d[0][1], d[1][0]*scale_cmpix, d[1][1]*scale_cmpix))
				data_to_send += str(d[0][0]) + '%' + str(d[0][1]) + '%' + str(d[1][0]*scale_cmpix) + '%' + str(d[1][1]*scale_cmpix) + '%'
				count += 1

			if data_to_send != '':
				client_socket.sendall(str.encode(data_to_send+'\n'))
				
			speed_timer = cv2.getTickCount()

		# Affichage des box encadrant les objets qui sont trackés
		for bbox, (color, name), vec in zip(boxes, infos, speed_vectors):
			x, y, w, h = normalize(bbox, scale)
			c = (x+w // 2, y+h // 2)
			mult = 20
			to = (int(c[0] + vec[0] * mult), int(c[1] + vec[1] * mult))
			speed = int(math.sqrt(vec[0] ** 2 + vec[1] ** 2) * 5)

			cv2.rectangle(frame, (x, y), (x+w, y+h), color, 2, 1)

		# Affichage du résultat avec le boxing
		cv2.imshow('[eXpav]', frame)

		# On quitte le flux vidéo avec ECHAP
		k = cv2.waitKey(1) & 0xff
		if k == 27:
			break

	file.close()
	client_socket.sendall(str.encode('quit_request'))
	client_socket.close()
	print('done.')
