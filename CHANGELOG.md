# Changelog

## Models

### `lib/models/user.dart`
- `User` — base user with `userId`, `fullname`, `email`, `role`

### `lib/models/student.dart`
- `Student` — extends user context with `studentId`, `fieldOfStudy`, `yearOfStudy`, `user`

### `lib/models/resume.dart`
- `ResumeData` — resume entry with `resumeId`, `studentId`, `verified`, `createdAt`

### `lib/models/notification.dart`
- `NotificationData` — notification entry with `notificationId`, `userId`, `message`, `type`, `relatedId`, `isRead`, `createdAt`

---

## API Endpoints Consumed

### Auth (`lib/api/user.dart`)
| Method | Endpoint | Function | Description |
|--------|----------|----------|-------------|
| POST | `/login` | `login()` | Authenticate user, returns JWT + user data + role |

### Student (`lib/api/student.dart`)
| Method | Endpoint | Function | Description |
|--------|----------|----------|-------------|
| GET | `/student?user_id={id}` | `getStudent()` | Fetch a single student by user ID |
| GET | `/students` | `getMentorStudents()` | Fetch all students assigned to a mentor |

### Resume (`lib/api/resume.dart`)
| Method | Endpoint | Function | Description |
|--------|----------|----------|-------------|
| POST | `/resume/upload` | `uploadResume()` | Upload a PDF resume (multipart form) |
| GET | `/resume/?request_student_id={id}` | `getResume()` | Fetch all resumes for current or specified student |
| GET | `/resume/download/{resumeId}` | `downloadResume()` | Download raw PDF bytes |
| PATCH | `/resume/{resumeId}/approve` | `approveResume()` | Mentor approves a resume |

### Notifications (`lib/api/notification.dart`)
| Method | Endpoint | Function | Description |
|--------|----------|----------|-------------|
| GET | `/notifications/` | `getNotifications()` | Fetch all notifications for the current user |
| GET | `/notifications/unread-count` | `getUnreadCount()` | Get count of unread notifications |
| PATCH | `/notifications/{id}/read` | `markAsRead()` | Mark a single notification as read |

---

## Changes & Fixes

### 1. Resume Upload — use `fromBytes` instead of `fromPath`
- **File:** `lib/api/resume.dart`
- `file_picker` on web returns bytes, not a file path
- Changed from `MultipartFile.fromPath` to `MultipartFile.fromBytes`
- Added explicit `MediaType('application', 'pdf')` content type

### 2. Resume Viewing — browser-native PDF viewer
- **File:** `lib/open_pdf.dart`
- Removed `syncfusion_flutter_pdfviewer` (incompatible with web)
- Generates a blob URL and calls `window.open()` to use the browser's built-in PDF viewer
- Uses `dart:html` (web-only) — protected by `kIsWeb` check
- Shows a SnackBar fallback on mobile platforms

### 3. Student Resume Page — upload history list
- **File:** `lib/dashboard/pages/resume_page.dart`
- Replaced single-resume view (latest + status bar) with full upload history
- Removed `_ResumeStatusCard` widget
- Added `_ResumeListTile` widget showing each resume's ID, status (Approved/Pending), and View button
- Upload card always visible; history section only shows when resumes exist
- Status shown per-card (not a global banner)

### 4. Mentor Resume Page — all resumes visible
- **File:** `lib/dashboard/pages/resume_page.dart`
- Expanded section now iterates over **all** student resumes (not just the latest)
- New `_buildResumeRow` widget with per-resume: icon, ID, status label, View button, Approve button
- Opening state keyed by composite `"$studentId:$resumeId"` so viewing one doesn't block others

### 5. Notification Badge — immediate update
- **New file:** `lib/dashboard/notification_service.dart`
  - Singleton `ChangeNotifier` that holds the unread count
  - Both sidebar and notifications page share this instance
- **File:** `lib/dashboard/sidebar.dart`
  - Removed local `getUnreadCount` call in favor of `NotificationService.instance`
  - Polling timer (30s) still calls `NotificationService.instance.fetchUnread()`
  - Listens to `NotificationService` for instant UI updates
- **File:** `lib/dashboard/pages/notifications_page.dart`
  - Calls `NotificationService.instance.fetchUnread()` after successfully marking a notification as read
  - Sidebar badge updates immediately instead of waiting up to 30 seconds

### 6. Notification Bell — sidebar
- **File:** `lib/dashboard/sidebar.dart`
- Custom `_NotificationNavItem` widget with:
  - Notification icon and label
  - Red badge showing unread count (capped at `99+`)
  - Active route highlighting (white badge on dark bg vs red badge on light bg)
  - Navigates to `/notifications` route

### 7. Notifications Page — UI
- **File:** `lib/dashboard/pages/notifications_page.dart`
- Lists all notifications with: icon (by type), message, timestamp, unread indicator
- Tapping an unread notification marks it as read (calls API + local state + refreshes badge)
- Notification types supported: `resume_upload`, `resume_approved`
- Empty state with icon and "No notifications yet"
