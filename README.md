# Treasure Hunt Web Application

A comprehensive treasure hunt event management web application built with Flutter Web.

## Overview

This application provides a complete solution for managing treasure hunt events with different user roles:

- **Admin**: Create and manage events, participants, locations, and teams
- **Coordinator**: Manage assigned locations and validate participant scans
- **Participant**: Join events using unique keys and navigate through treasure hunt routes

## Features

### 🎯 Core Features

- **Multi-role Authentication**: Admin, Coordinator, and Participant roles
- **Event Management**: Create, edit, and manage treasure hunt events
- **Team Formation**: QR-based participant registration and team creation
- **Dynamic Routing**: Random route generation for each team
- **Real-time Scoring**: Position-based scoring system with penalties
- **QR Code System**: White QR codes on dark backgrounds for better visibility
- **Location Management**: Coordinate assignment and hint management

### 🔧 Technical Features

- **Progressive Web App (PWA)**: Works offline and can be installed
- **Dark Mode UI**: Eye-friendly dark theme with green accents
- **Responsive Design**: Works on mobile, tablet, and desktop
- **Real-time Updates**: Automatic data refresh every 7 minutes
- **State Management**: Provider pattern for efficient state handling
- **RESTful API**: Complete backend integration ready

## Architecture

### User Roles & Flow

1. **Admin**

   - Creates events and adds other admins/coordinators
   - Generates participant unique keys (5-digit)
   - Scans participant QR codes to create teams
   - Assigns routes to teams
   - Manages locations and hints
   - Views real-time scores and team progress

2. **Coordinator**

   - Assigned to specific locations
   - Has location-specific QR codes
   - Validates participant scans according to team routes
   - Cannot create events or manage teams

3. **Participant**
   - No registration required
   - Uses unique 5-digit key to join events
   - Follows assigned route through locations
   - Scans location QR codes to progress

### Scoring System

- Teams get higher scores for reaching route positions faster
- Position-based scoring: 1st team gets highest score for that route position
- Wrong location scans result in penalties (-1, -2, -3 progressively)
- Timestamps tracked for all scans

### Data Models

- **User**: Authentication and role management
- **Event**: Event details and configuration
- **Participant**: Unique keys and team associations
- **Team**: Members, scores, and assigned routes
- **Location**: Coordinates, hints, and QR codes
- **ScanLog**: Timestamp tracking for all QR scans

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Chrome browser for web development
- Node.js (for backend API - separate project)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd treasure_hunt_web
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   Edit `lib/config/app_config.dart`:

   ```dart
   static const String baseUrl = 'http://your-api-server.com';
   ```

4. **Run the application**
   ```bash
   flutter run -d chrome --web-port=3000
   ```

### Building for Production

```bash
# Build for web deployment
flutter build web

# The built files will be in build/web/
# Deploy these files to your web server
```

## Project Structure

```
lib/
├── config/           # App configuration and theme
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
├── services/         # API and background services
└── widgets/          # Reusable UI components

web/                  # Web-specific files
├── icons/           # PWA icons
├── index.html       # Main HTML file
└── manifest.json    # PWA manifest
```

## API Integration

The app expects a RESTful API with the following endpoints:

### Authentication

- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/logout` - User logout

### Events

- `GET /api/events` - List events
- `POST /api/events` - Create event
- `GET /api/events/:id` - Get event details
- `PUT /api/events/:id` - Update event

### Participants

- `GET /api/participants` - List participants
- `POST /api/participants` - Create participant
- `GET /api/participants/:key` - Get by unique key

### Teams & Scoring

- `GET /api/teams` - List teams
- `POST /api/teams` - Create team
- `POST /api/scans` - Log QR scan
- `GET /api/scores/:eventId` - Get event scores

## Development

### Key Components

1. **AuthProvider**: Handles authentication state
2. **AppProvider**: Manages app data and API calls
3. **PeriodicUpdateService**: Background data refresh
4. **QRCodeWidget**: QR generation and scanning
5. **DashboardScreen**: Main interface for all roles

### Customization

- **Theme**: Edit `lib/config/theme.dart`
- **API URLs**: Edit `lib/config/app_config.dart`
- **Update intervals**: Edit `lib/services/periodic_update_service.dart`

## Deployment

### Web Hosting

1. Build the project: `flutter build web`
2. Upload `build/web/` contents to your web server
3. Configure your web server to serve the `index.html` for all routes

### Recommended Platforms

- Netlify
- Vercel
- Firebase Hosting
- GitHub Pages
- Any static web hosting service

## Security Considerations

- All API calls should use HTTPS in production
- Implement proper JWT token handling
- Validate all user inputs on the backend
- Use environment variables for sensitive configuration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions or support, please open an issue in the repository or contact the development team.

---

**Built with Flutter Web** 🚀
