# AquaCare App - TODO List

## ✅ Completed Tasks
- [x] MVVM Architecture setup with Riverpod
- [x] Firebase initialization and configuration
- [x] FCM notifications setup
- [x] Main dashboard with aquarium cards
- [x] CRUD operations for aquariums (Create, Read, Update, Delete)
- [x] Aquarium detail page (SAD)
- [x] Temperature sensor page with MVVM
- [x] pH sensor page migration to MVVM
- [x] Turbidity sensor page migration to MVVM
- [x] Auto-feed/camera page with feeding functionality
- [x] Notification settings per aquarium
- [x] Responsive design with ResponsiveHelper
- [x] Wheel picker width fix
- [x] Landing page as first screen
- [x] Up/down arrows for picker
- [x] Improved feeding safety with timestamps

## 🔄 In Progress
- [ ] Auto-light functionality implementation
- [ ] Chat with AI page migration

## 📋 Pending Tasks

### High Priority
- [ ] **Implement Auto-light functionality**
  - [ ] Add auto-light toggle in aquarium detail page
  - [ ] Create auto-light repository methods
  - [ ] Update Firebase when auto-light status changes
  - [ ] Show current auto-light status

- [ ] **Add sensor graphs functionality**
  - [ ] Create graph service for hourly/weekly data
  - [ ] Implement graph selection (aquarium, time period)
  - [ ] Display sensor data in charts

- [ ] **Add Floor database for local caching**
  - [ ] Set up Floor database configuration
  - [ ] Create entities for sensor data, thresholds, notifications
  - [ ] Implement local caching of latest values
  - [ ] Cache hourly logs and averages
  - [ ] Handle offline data persistence

### Medium Priority
- [ ] **Add connectivity check for offline banner**
  - [ ] Create connectivity service
  - [ ] Show offline banner on main dashboard
  - [ ] Handle offline state gracefully

- [ ] **Implement global theme toggle**
  - [ ] Add dark/light/system theme options in settings
  - [ ] Create theme provider with Riverpod
  - [ ] Apply theme throughout the app
  - [ ] Persist theme preference

### Low Priority
- [ ] **Implement sidebar with first 3 aquariums**
  - [ ] Add sidebar navigation
  - [ ] Show first 3 aquariums in sidebar
  - [ ] Add navigation to specific aquariums

- [ ] **Implement camera feed streaming**
  - [ ] Replace camera placeholder with actual feed
  - [ ] Add REST API integration for camera feed
  - [ ] Handle camera connection/disconnection

- [ ] **Add backend endpoints integration**
  - [ ] Implement REST API calls for feeding commands
  - [ ] Add camera control endpoints
  - [ ] Handle API responses and errors

### Future Enhancements
- [ ] **User authentication system**
  - [ ] Add login/logout functionality
  - [ ] Implement user-specific aquarium access
  - [ ] Add user management features

- [ ] **Advanced notifications**
  - [ ] Add notification history
  - [ ] Implement notification scheduling
  - [ ] Add custom notification sounds

- [ ] **Data analytics**
  - [ ] Add aquarium health scoring
  - [ ] Implement trend analysis
  - [ ] Add maintenance reminders

## 🐛 Known Issues
- [ ] `setState() called after dispose()` in AquariumDetailPage (needs migration to Riverpod)
- [ ] Some Firebase listeners not properly disposed
- [ ] Need better error handling for network issues

## 📝 Notes
- All sensor pages now follow the same MVVM pattern with Riverpod
- Landing page shows for 6 seconds before redirecting to main dashboard
- Feeding functionality includes safety features with timestamps and status tracking
- Ensure all Firebase operations have proper error handling
- Test CRUD operations thoroughly with different Firebase data structures
- Verify responsive design works on all screen sizes
- Ensure FCM notifications work in both foreground and background states
