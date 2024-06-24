import socket
import time
from datetime import datetime
import json
import logging
from threading import Thread
from math import sin, cos, sqrt, atan2, radians

# Configure logging to output to stdout
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

clients = []

# Constants for GPS movement
EARTH_RADIUS = 6371000  # meters

# Initialize vehicle positions
vehicles = [
    {"vehicle_id": 1, "mission_id": 101, "latitude": 37.7749, "longitude": -122.4194},
    {"vehicle_id": 2, "mission_id": 102, "latitude": 37.7749, "longitude": -122.4203},  # 100 meters apart
    {"vehicle_id": 3, "mission_id": 103, "latitude": 37.7749, "longitude": -122.4212},  # 200 meters apart
    {"vehicle_id": 4, "mission_id": 104, "latitude": 37.7749, "longitude": -122.4221},  # 300 meters apart
]

def calculate_new_position(lat, lon, distance):
    # Function to calculate new GPS position after moving 'distance' meters to the east
    lat = radians(lat)
    lon = radians(lon)

    new_lat = lat
    new_lon = lon + distance / EARTH_RADIUS / cos(lat)

    return {
        "latitude": new_lat * 180.0 / 3.141592653589793,
        "longitude": new_lon * 180.0 / 3.141592653589793
    }

def create_gps_data():
    # Update vehicle positions
    for vehicle in vehicles:
        new_position = calculate_new_position(vehicle["latitude"], vehicle["longitude"], 5)  # Move 5 meters to the east
        vehicle["latitude"] = new_position["latitude"]
        vehicle["longitude"] = new_position["longitude"]
        vehicle["timestamp"] = str(datetime.now())
    
    return vehicles

def handle_client_registration(sock):
    while True:
        data, addr = sock.recvfrom(1024)
        print(data, addr)
        message = data.decode('utf-8')
        
        if message == "register":
            if addr not in clients:
                clients.append(addr)
                logging.info(f"Registered client: {addr}")

def send_gps_data(sock):
    while True:
        gps_data = create_gps_data()
        for vehicle in gps_data:
            gps_message = json.dumps(vehicle).encode('utf-8')
            for client in clients:
                print(client)
                print(gps_message)
                sock.sendto(gps_message, client)
        
        time.sleep(30)

def start_server():
    udp_ip = "0.0.0.0"  # Listen on all available network interfaces
    udp_port = 5005

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((udp_ip, udp_port))

    logging.info(f"Listening on {udp_ip}:{udp_port}")

    Thread(target=handle_client_registration, args=(sock,)).start()
    Thread(target=send_gps_data, args=(sock,)).start()

if __name__ == "__main__":
    start_server()
