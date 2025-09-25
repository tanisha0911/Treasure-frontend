# Treasure Hunt API Endpoints - Quick Reference

## 🔐 Authentication (4 endpoints)

```
POST /auth/login                      - Admin/Coordinator login
POST /auth/register                   - Admin/Coordinator registration
POST /auth/participant/validate       - Validate participant token
POST /auth/participant/generate       - Generate new participant token (Admin only)
```

## 🎯 Events (7 endpoints)

```
GET    /events                        - Get all events
POST   /events                        - Create new event (Admin only)
GET    /events/{event_id}             - Get event details
PUT    /events/{event_id}             - Update event (Admin only)
DELETE /events/{event_id}             - Delete event (Admin only)
POST   /events/{event_id}/start       - Start event (Admin only)
POST   /events/{event_id}/end         - End event (Admin only)
```

## 👥 Teams (6 endpoints)

```
GET    /events/{event_id}/teams                      - Get teams for event
POST   /events/{event_id}/teams                      - Create team (Admin only)
GET    /teams/{team_id}                              - Get team details
PUT    /teams/{team_id}                              - Update team (Admin only)
POST   /teams/{team_id}/participants                 - Add participant to team (Admin only)
DELETE /teams/{team_id}/participants/{token}         - Remove participant from team (Admin only)
```

## 🏃 Participants (3 endpoints)

```
GET  /participants/{token}/dashboard                 - Get participant dashboard data
POST /participants/{token}/events/{event_id}/join   - Join event
POST /participants/{token}/scan                      - Process QR code scan
```

## 📍 Locations (5 endpoints)

```
GET    /locations                     - Get all locations
POST   /locations                     - Create location (Admin only)
GET    /locations/{location_id}       - Get location details
PUT    /locations/{location_id}       - Update location (Admin only)
DELETE /locations/{location_id}       - Delete location (Admin only)
```

## 👨‍💼 Coordinators (3 endpoints)

```
GET  /coordinators/{coordinator_id}/location                         - Get assigned location
POST /events/{event_id}/coordinators/{coordinator_id}/assign        - Assign coordinator to location (Admin only)
GET  /coordinators/{coordinator_id}/scan-logs                       - Get scan logs for location
```

## 📊 Analytics (3 endpoints)

```
GET /events/{event_id}/analytics      - Get event analytics (Admin only)
GET /events/{event_id}/leaderboard    - Get leaderboard
GET /events/{event_id}/scan-logs      - Get scan logs with filters (Admin only)
```

## 🔄 Real-time (1 endpoint - Optional)

```
WS /ws?token={jwt_token}&event_id={event_id}         - WebSocket for real-time updates
```

---

## 📋 Total: 32 HTTP Endpoints + 1 WebSocket

### By Authentication Level:

- **No Auth Required**: 6 endpoints (participant-focused)
- **JWT Required**: 8 endpoints (general access)
- **Admin JWT Required**: 17 endpoints (admin operations)
- **Coordinator JWT Required**: 2 endpoints (coordinator operations)

### By Priority:

1. **Core Functionality**: Auth, Events, Participants, QR Scanning
2. **Management**: Teams, Locations, Coordinators
3. **Analytics**: Reporting, Leaderboards, Logs
4. **Optional**: WebSocket real-time updates

### Key Business Logic:

- **Scoring**: +10 correct scan, -1/-2/-3 escalating penalty for wrong scans
- **Routes**: Randomized per team, same start/end points
- **Participants**: Token-based (5-digit), no account required
- **QR Validation**: Must match team's current expected location

This gives you everything needed to build the backend for the treasure hunt application!
