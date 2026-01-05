# ShiftTracker

A work clock-in tracking app with shift reminders and classification

## Screenshots

<details>
  <summary>Clock In</summary>
  <br>
  <img src=".github-assets/clock_in_page.png" width="200"/>
</details>

<details>
  <summary>History</summary>
  <br>
  <img src=".github-assets/history_page.png" width="200"/>
</details>

<details>
  <summary>Settings</summary>
  <br>
  <img src=".github-assets/settings_page.png" width="200"/>
</details>

## Features

- **Clock-In Tracking**: Records timestamped clock-ins with server time synchronization
- **Smart Classification**: Automatically categorizes clock-ins (Shift Start, Lunch Start/End, Shift End, Additional)
- **Shift Reminders**: Configurable notifications before scheduled clock-ins
- **History Management**: View and clear clock-in history with auto-clear options
- **Offline Support**: Detects network connectivity and prevents clock-ins when offline

## Libraries Used

- **cupertino_icons**: iOS-style icon assets for Cupertino widgets
- **http**: HTTP client for making API requests
- **intl**: Internationalization and date/time formatting utilities
- **connectivity_plus**: Network connectivity status monitoring (WiFi, Mobile, None)
- **shared_preferences**: Platform-specific persistent storage for simple data
- **flutter_local_notifications**: Local notification scheduling and management
- **timezone**: Timezone database for accurate notification scheduling

## Permissions

### Android
- `INTERNET`: Network access for time synchronization
- `POST_NOTIFICATIONS`: Display notifications (Android 13+)
- `SCHEDULE_EXACT_ALARM`: Schedule exact-time notifications
- `USE_EXACT_ALARM`: Precise notification timing
- `RECEIVE_BOOT_COMPLETED`: Reschedule notifications after device restart

### iOS
- Notification permissions requested at runtime (Alert, Badge, Sound)

