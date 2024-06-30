const availableAGVs = [
  {
    "id": "AGV1",
    "name": "Transporter Alpha",
    "current_location": {"lat": 34.052235, "long": -118.243683},
    "mission_assigned": "None"
  },
  {
    "id": "AGV2",
    "name": "Loader Beta",
    "current_location": {"lat": 34.052335, "long": -118.243583},
    "mission_assigned": "Load"
  },
  {
    "id": "AGV3",
    "name": "Mover Gamma",
    "current_location": {"lat": 34.052435, "long": -118.243483},
    "mission_assigned": "Move"
  },
  {
    "id": "AGV4",
    "name": "Carrier Delta",
    "current_location": {"lat": 34.052535, "long": -118.243383},
    "mission_assigned": "None"
  }
];

const activeProjects = [
  {
    "id": "Project1",
    "name": "Warehouse Management",
    "agvs": [
      {
        "id": "AGV1",
        "name": "Transporter Alpha",
        "current_location": {"lat": 34.052235, "long": -118.243683},
        "mission_assigned": "Transport"
      },
      {
        "id": "AGV2",
        "name": "Loader Beta",
        "current_location": {"lat": 34.052335, "long": -118.243583},
        "mission_assigned": "Load"
      },
      {
        "id": "AGV3",
        "name": "Mover Gamma",
        "current_location": {"lat": 34.052435, "long": -118.243483},
        "mission_assigned": "Move"
      }
    ]
  },
  {
    "id": "Project2",
    "name": "Automated Sorting",
    "agvs": [
      {
        "id": "AGV2",
        "name": "Loader Beta",
        "current_location": {"lat": 34.052335, "long": -118.243583},
        "mission_assigned": "Load"
      },
      {
        "id": "AGV3",
        "name": "Mover Gamma",
        "current_location": {"lat": 34.052435, "long": -118.243483},
        "mission_assigned": "Move"
      },
      {
        "id": "AGV4",
        "name": "Carrier Delta",
        "current_location": {"lat": 34.052535, "long": -118.243383},
        "mission_assigned": "Deliver"
      }
    ]
  }
];
