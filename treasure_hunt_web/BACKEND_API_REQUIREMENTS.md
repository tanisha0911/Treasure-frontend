# Treasure Hunt Backend API Requirements

## Complete List of Required Endpoints

### Base Configuration

- **Base URL**: `https://your-api-domain.com/api/v1`
- **Authentication**: JWT Bearer tokens (Admin/Coordinator), Participant tokens
- **Content-Type**: `application/json`

---

## 1. Authentication Endpoints

| Method | Endpoint                     | Description                    | Auth Required |
| ------ | ---------------------------- | ------------------------------ | ------------- |
| `POST` | `/auth/login`                | Admin/Coordinator login        | No            |
| `POST` | `/auth/register`             | Admin/Coordinator registration | No            |
| `POST` | `/auth/participant/validate` | Validate participant token     | No            |
| `POST` | `/auth/participant/generate` | Generate new participant token | Admin JWT     |

---

## 2. Event Management Endpoints

| Method   | Endpoint                   | Description       | Auth Required |
| -------- | -------------------------- | ----------------- | ------------- |
| `GET`    | `/events`                  | Get all events    | JWT           |
| `POST`   | `/events`                  | Create new event  | Admin JWT     |
| `GET`    | `/events/{event_id}`       | Get event details | JWT           |
| `PUT`    | `/events/{event_id}`       | Update event      | Admin JWT     |
| `DELETE` | `/events/{event_id}`       | Delete event      | Admin JWT     |
| `POST`   | `/events/{event_id}/start` | Start event       | Admin JWT     |
| `POST`   | `/events/{event_id}/end`   | End event         | Admin JWT     |

---

## 3. Team Management Endpoints

| Method   | Endpoint                                | Description                  | Auth Required |
| -------- | --------------------------------------- | ---------------------------- | ------------- |
| `GET`    | `/events/{event_id}/teams`              | Get teams for event          | JWT           |
| `POST`   | `/events/{event_id}/teams`              | Create team                  | Admin JWT     |
| `GET`    | `/teams/{team_id}`                      | Get team details             | JWT           |
| `PUT`    | `/teams/{team_id}`                      | Update team                  | Admin JWT     |
| `POST`   | `/teams/{team_id}/participants`         | Add participant to team      | Admin JWT     |
| `DELETE` | `/teams/{team_id}/participants/{token}` | Remove participant from team | Admin JWT     |

---

## 4. Participant Endpoints

| Method | Endpoint                                       | Description                    | Auth Required |
| ------ | ---------------------------------------------- | ------------------------------ | ------------- |
| `GET`  | `/participants/{token}/dashboard`              | Get participant dashboard data | No            |
| `POST` | `/participants/{token}/events/{event_id}/join` | Join event                     | No            |
| `POST` | `/participants/{token}/scan`                   | Process QR code scan           | No            |

---

## 5. Location Management Endpoints

| Method   | Endpoint                   | Description          | Auth Required |
| -------- | -------------------------- | -------------------- | ------------- |
| `GET`    | `/locations`               | Get all locations    | JWT           |
| `POST`   | `/locations`               | Create location      | Admin JWT     |
| `GET`    | `/locations/{location_id}` | Get location details | JWT           |
| `PUT`    | `/locations/{location_id}` | Update location      | Admin JWT     |
| `DELETE` | `/locations/{location_id}` | Delete location      | Admin JWT     |

---

## 6. Coordinator Endpoints

| Method | Endpoint                                                  | Description                    | Auth Required   |
| ------ | --------------------------------------------------------- | ------------------------------ | --------------- |
| `GET`  | `/coordinators/{coordinator_id}/location`                 | Get assigned location          | Coordinator JWT |
| `POST` | `/events/{event_id}/coordinators/{coordinator_id}/assign` | Assign coordinator to location | Admin JWT       |
| `GET`  | `/coordinators/{coordinator_id}/scan-logs`                | Get scan logs for location     | Coordinator JWT |

---

## 7. Analytics & Reporting Endpoints

| Method | Endpoint                         | Description                | Auth Required |
| ------ | -------------------------------- | -------------------------- | ------------- |
| `GET`  | `/events/{event_id}/analytics`   | Get event analytics        | Admin JWT     |
| `GET`  | `/events/{event_id}/leaderboard` | Get leaderboard            | JWT           |
| `GET`  | `/events/{event_id}/scan-logs`   | Get scan logs with filters | Admin JWT     |

---

## 8. WebSocket Endpoints (Optional)

| Type | Endpoint                                    | Description       |
| ---- | ------------------------------------------- | ----------------- |
| `WS` | `/ws?token={jwt_token}&event_id={event_id}` | Real-time updates |

---

## Key Request/Response Models

### Participant Dashboard Response

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
        { "token": "12345", "name": "John Doe" },
        { "token": "67890", "name": "Jane Smith" }
      ],
      "currentLocationIndex": 1,
      "score": 85,
      "completedLocations": ["Library Entrance"],
      "currentLocationCode": "LOC002",
      "hint": "Among the roses, find what glows",
      "wrongScanCount": 0
    },
    "availableEvents": []
  }
}
```

### QR Scan Request

```json
{
  "qrData": "LOC002",
  "timestamp": "2024-01-20T14:30:00Z"
}
```

### QR Scan Response

```json
{
  "success": true,
  "data": {
    "result": "correct", // "correct", "wrong", "completed"
    "message": "Correct location! +10 points",
    "scoreChange": 10,
    "newScore": 95,
    "nextLocation": {
      "code": "LOC003",
      "hint": "Where experiments brew and formulas grew"
    },
    "completed": false
  }
}
```

### Team Creation Request

```json
{
  "name": "Team Alpha",
  "participantTokens": ["12345", "67890"],
  "route": ["LOC001", "LOC002", "LOC003", "LOC004"]
}
```

### Event Creation Request

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
      "hint": "Where knowledge sleeps and wisdom wakes",
      "coordinates": {
        "latitude": 40.7128,
        "longitude": -74.006
      }
    }
  ]
}
```

---

## Core Business Logic Requirements

### Scoring System

- **Correct Scan**: +10 points
- **Wrong Scan**: -1 point (first wrong), -2 (second wrong), -3 (third wrong), etc.
- Teams follow different randomized routes with same start/end points

### Route Management

- Each team gets a unique route through the same locations
- Routes must have same start and end points
- Route order is randomized for each team

### QR Code Validation

- Validate scanned QR code against team's current expected location
- Only allow progression to next location with correct scan
- Track wrong scan attempts with escalating penalties

### Event States

- **Draft**: Event created but not started
- **Active**: Event is running, participants can scan
- **Completed**: Event finished, show final results

### Participant Management

- Auto-generate 5-digit unique tokens
- Participants don't need accounts, only tokens
- Auto-assign participants to teams when joining events

### Real-time Features (Optional)

- Live leaderboard updates
- Real-time score changes
- Team progress tracking

---

## Database Schema Suggestions

### Key Tables Needed

1. **users** (admins, coordinators)
2. **participants** (token-based)
3. **events**
4. **locations**
5. **teams**
6. **team_participants** (many-to-many)
7. **scan_logs** (audit trail)
8. **coordinator_locations** (assignments)

### Important Fields

- Events: name, description, status, start/end times
- Teams: name, event_id, route (JSON array), score, current_location_index, wrong_scan_count
- Scan Logs: participant_token, team_id, location_code, result, timestamp, score_change
- Locations: code (LOC001), name, hint, coordinates, qr_code_data

---

## Priority Implementation Order

1. **Authentication** (login, participant validation)
2. **Event Management** (CRUD operations)
3. **Location Management** (create locations with QR codes)
4. **Team Management** (create teams, assign participants)
5. **Participant Dashboard** (show current status)
6. **QR Scanning Logic** (core treasure hunt functionality)
7. **Analytics & Reporting** (leaderboards, statistics)
8. **Real-time Updates** (WebSocket, optional)

This covers all the endpoints and functionality needed to support the treasure hunt frontend application!
