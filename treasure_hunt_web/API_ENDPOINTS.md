# Treasure Hunt Application - API Endpoints Documentation

## Base Configuration

- **Base URL**: `https://your-api-domain.com/api/v1`
- **Authentication**: JWT Bearer tokens for Admin/Coordinator, Participant tokens for participants
- **Content-Type**: `application/json`

---

## 1. Authentication Endpoints

### 1.1 Admin/Coordinator Login

```http
POST /auth/login
```

**Request Body:**

```json
{
  "email": "admin@example.com",
  "password": "password123",
  "role": "admin" // or "coordinator"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "email": "admin@example.com",
      "name": "John Admin",
      "role": "admin"
    },
    "token": "jwt_token_here",
    "expiresAt": "2024-12-31T23:59:59Z"
  }
}
```

### 1.2 Admin/Coordinator Registration

```http
POST /auth/register
```

**Request Body:**

```json
{
  "email": "newadmin@example.com",
  "password": "password123",
  "name": "New Admin",
  "role": "admin" // or "coordinator"
}
```

### 1.3 Participant Token Validation

```http
POST /auth/participant/validate
```

**Request Body:**

```json
{
  "token": "12345"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "participant": {
      "id": "participant_123",
      "token": "12345",
      "name": "John Doe",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  }
}
```

### 1.4 Generate Participant Token

```http
POST /auth/participant/generate
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`
**Response:**

```json
{
  "success": true,
  "data": {
    "token": "67890",
    "qrCode": "data:image/png;base64,..."
  }
}
```

---

## 2. Event Management Endpoints

### 2.1 Get All Events

```http
GET /events
```

**Headers:** `Authorization: Bearer {jwt_token}`
**Response:**

```json
{
  "success": true,
  "data": {
    "events": [
      {
        "id": "event_123",
        "name": "Campus Treasure Hunt",
        "description": "Explore the campus and find hidden treasures!",
        "status": "active", // "draft", "active", "completed"
        "startTime": "2024-01-20T09:00:00Z",
        "endTime": "2024-01-20T17:00:00Z",
        "participantsCount": 25,
        "teamsCount": 8,
        "locationsCount": 4,
        "createdBy": "admin_123",
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

### 2.2 Create New Event

```http
POST /events
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`
**Request Body:**

```json
{
  "name": "Campus Treasure Hunt",
  "description": "Explore the campus and find hidden treasures!",
  "startTime": "2024-01-20T09:00:00Z",
  "endTime": "2024-01-20T17:00:00Z",
  "maxParticipants": 50,
  "locations": [
    {
      "name": "Library Entrance",
      "hint": "Where knowledge sleeps and wisdom wakes, seek the entrance where learning takes",
      "coordinates": {
        "latitude": 40.7128,
        "longitude": -74.006
      }
    }
  ]
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "event": {
      "id": "event_123",
      "name": "Campus Treasure Hunt",
      "status": "draft",
      "locationCodes": ["LOC001", "LOC002", "LOC003", "LOC004"]
    }
  }
}
```

### 2.3 Get Event Details

```http
GET /events/{event_id}
```

**Headers:** `Authorization: Bearer {jwt_token}`

### 2.4 Update Event

```http
PUT /events/{event_id}
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`

### 2.5 Delete Event

```http
DELETE /events/{event_id}
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`

### 2.6 Start Event

```http
POST /events/{event_id}/start
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`

### 2.7 End Event

```http
POST /events/{event_id}/end
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`

---

## 3. Team Management Endpoints

### 3.1 Create Team

```http
POST /events/{event_id}/teams
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`
**Request Body:**

```json
{
  "name": "Team Alpha",
  "participantTokens": ["12345", "67890"],
  "route": ["LOC001", "LOC002", "LOC003", "LOC004"]
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "team": {
      "id": "team_123",
      "name": "Team Alpha",
      "eventId": "event_123",
      "participants": [
        {
          "id": "participant_123",
          "token": "12345",
          "name": "John Doe"
        }
      ],
      "route": ["LOC001", "LOC002", "LOC003", "LOC004"],
      "currentLocationIndex": 0,
      "score": 0,
      "completedLocations": [],
      "wrongScanCount": 0,
      "startedAt": null,
      "completedAt": null
    }
  }
}
```

### 3.2 Get Teams for Event

```http
GET /events/{event_id}/teams
```

**Headers:** `Authorization: Bearer {jwt_token}`

### 3.3 Get Team Details

```http
GET /teams/{team_id}
```

**Headers:** `Authorization: Bearer {jwt_token}`

### 3.4 Update Team

```http
PUT /teams/{team_id}
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`

### 3.5 Add Participant to Team

```http
POST /teams/{team_id}/participants
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`
**Request Body:**

```json
{
  "participantToken": "11111"
}
```

### 3.6 Remove Participant from Team

```http
DELETE /teams/{team_id}/participants/{participant_token}
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`

---

## 4. Participant Endpoints

### 4.1 Get Participant Dashboard Data

```http
GET /participants/{participant_token}/dashboard
```

**Response:**

```json
{
  "success": true,
  "data": {
    "participant": {
      "id": "participant_123",
      "token": "12345",
      "name": "John Doe"
    },
    "currentEvent": {
      "id": "event_123",
      "name": "Campus Treasure Hunt",
      "status": "active"
    },
    "team": {
      "id": "team_123",
      "name": "Team Alpha",
      "members": [
        {
          "token": "12345",
          "name": "John Doe"
        },
        {
          "token": "67890",
          "name": "Jane Smith"
        }
      ],
      "currentLocationIndex": 1,
      "score": 85,
      "completedLocations": ["Library Entrance"],
      "currentLocationCode": "LOC002",
      "hint": "Among the roses, find what glows",
      "wrongScanCount": 0
    },
    "availableEvents": [
      {
        "id": "event_456",
        "name": "City Adventure",
        "status": "upcoming",
        "description": "Discover historical landmarks",
        "participantsCount": 12
      }
    ]
  }
}
```

### 4.2 Join Event (Auto-assign to team)

```http
POST /participants/{participant_token}/events/{event_id}/join
```

**Response:**

```json
{
  "success": true,
  "data": {
    "team": {
      "id": "team_123",
      "name": "Team Alpha",
      "assigned": true
    }
  }
}
```

### 4.3 QR Code Scan

```http
POST /participants/{participant_token}/scan
```

**Request Body:**

```json
{
  "qrData": "LOC002",
  "timestamp": "2024-01-20T14:30:00Z"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "result": "correct", // or "wrong" or "completed"
    "message": "Correct location! +10 points",
    "scoreChange": 10,
    "newScore": 95,
    "nextLocation": {
      "code": "LOC003",
      "hint": "Where experiments brew and formulas grew, seek the building painted blue"
    },
    "completed": false
  }
}
```

---

## 5. Location Management Endpoints

### 5.1 Get All Locations

```http
GET /locations
```

**Headers:** `Authorization: Bearer {jwt_token}`

### 5.2 Create Location

```http
POST /locations
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`
**Request Body:**

```json
{
  "name": "Library Entrance",
  "hint": "Where knowledge sleeps and wisdom wakes",
  "coordinates": {
    "latitude": 40.7128,
    "longitude": -74.006
  },
  "description": "Main entrance of the university library"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "location": {
      "id": "location_123",
      "code": "LOC001",
      "name": "Library Entrance",
      "hint": "Where knowledge sleeps and wisdom wakes",
      "qrCode": "data:image/png;base64,..."
    }
  }
}
```

### 5.3 Update Location

```http
PUT /locations/{location_id}
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`

### 5.4 Delete Location

```http
DELETE /locations/{location_id}
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`

---

## 6. Coordinator Endpoints

### 6.1 Get Assigned Location

```http
GET /coordinators/{coordinator_id}/location
```

**Headers:** `Authorization: Bearer {coordinator_jwt_token}`
**Response:**

```json
{
  "success": true,
  "data": {
    "location": {
      "id": "location_123",
      "code": "LOC002",
      "name": "Campus Garden",
      "hint": "Among the roses, find what glows",
      "qrCode": "data:image/png;base64,..."
    },
    "event": {
      "id": "event_123",
      "name": "Campus Treasure Hunt"
    },
    "stats": {
      "teamsVisited": 3,
      "teamsRemaining": 5,
      "lastScanTime": "2024-01-20T14:25:00Z"
    }
  }
}
```

### 6.2 Assign Coordinator to Location

```http
POST /events/{event_id}/coordinators/{coordinator_id}/assign
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`
**Request Body:**

```json
{
  "locationId": "location_123"
}
```

### 6.3 Get Scan Logs for Location

```http
GET /coordinators/{coordinator_id}/scan-logs
```

**Headers:** `Authorization: Bearer {coordinator_jwt_token}`

---

## 7. Analytics & Reporting Endpoints

### 7.1 Get Event Analytics

```http
GET /events/{event_id}/analytics
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`
**Response:**

```json
{
  "success": true,
  "data": {
    "totalParticipants": 25,
    "totalTeams": 8,
    "completedTeams": 3,
    "averageScore": 78,
    "averageCompletionTime": "02:45:00",
    "locationStats": [
      {
        "locationCode": "LOC001",
        "locationName": "Library Entrance",
        "correctScans": 24,
        "wrongScans": 12,
        "averageArrivalTime": "00:15:00"
      }
    ],
    "topTeams": [
      {
        "teamId": "team_123",
        "teamName": "Team Alpha",
        "score": 95,
        "completionTime": "02:30:00"
      }
    ]
  }
}
```

### 7.2 Get Leaderboard

```http
GET /events/{event_id}/leaderboard
```

**Response:**

```json
{
  "success": true,
  "data": {
    "teams": [
      {
        "rank": 1,
        "teamId": "team_123",
        "teamName": "Team Alpha",
        "score": 95,
        "completedLocations": 4,
        "completionTime": "02:30:00",
        "status": "completed"
      }
    ]
  }
}
```

### 7.3 Get Scan Logs

```http
GET /events/{event_id}/scan-logs
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`
**Query Parameters:**

- `team_id` (optional): Filter by team
- `location_code` (optional): Filter by location
- `participant_token` (optional): Filter by participant
- `start_time` (optional): Filter from timestamp
- `end_time` (optional): Filter to timestamp

---

## 8. Real-time Updates (WebSocket)

---

## 7. Analytics & Reporting Endpoints

### 7.1 Get Event Analytics

```http
GET /events/{event_id}/analytics
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`
**Response:**

```json
{
  "success": true,
  "data": {
    "totalParticipants": 25,
    "totalTeams": 8,
    "completedTeams": 3,
    "averageScore": 78,
    "averageCompletionTime": "02:45:00",
    "locationStats": [
      {
        "locationCode": "LOC001",
        "locationName": "Library Entrance",
        "correctScans": 24,
        "wrongScans": 12,
        "averageArrivalTime": "00:15:00"
      }
    ],
    "topTeams": [
      {
        "teamId": "team_123",
        "teamName": "Team Alpha",
        "score": 95,
        "completionTime": "02:30:00"
      }
    ]
  }
}
```

### 7.2 Get Leaderboard

```http
GET /events/{event_id}/leaderboard
```

**Response:**

```json
{
  "success": true,
  "data": {
    "teams": [
      {
        "rank": 1,
        "teamId": "team_123",
        "teamName": "Team Alpha",
        "score": 95,
        "completedLocations": 4,
        "completionTime": "02:30:00",
        "status": "completed"
      }
    ]
  }
}
```

### 7.3 Get Scan Logs

```http
GET /events/{event_id}/scan-logs
```

**Headers:** `Authorization: Bearer {admin_jwt_token}`
**Query Parameters:**

- `team_id` (optional): Filter by team
- `location_code` (optional): Filter by location
- `participant_token` (optional): Filter by participant
- `start_time` (optional): Filter from timestamp
- `end_time` (optional): Filter to timestamp

---

## 8. Real-time Updates (WebSocket)
