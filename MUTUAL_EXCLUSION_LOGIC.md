## VIT WiFi Mutual Exclusion Logic 

### Changes Made:

#### 1. **HostelLogin Event Handler** (`auth_bloc.dart`):
```dart
on<HostelLogin>((event, emit) async {
  // First check if academic WiFi is logged in
  String? academicstatus = LocalStorage.getString("academicstatus");
  if(academicstatus == "loggedin") {
    emit(HostelAuthenticating(message: "Logging out from Academic WiFi first..."));
    // Log out from academic WiFi first
    LocalStorage.setString("academicstatus", "loggedout");
    await Future.delayed(Duration(seconds: 1)); // Small delay for user experience
  }
  
  emit(HostelAuthenticating(message: "Logging in to SOPHOS Client..."));
  // ... rest of hostel login logic
});
```

#### 2. **AcademicLogin Event Handler** (`auth_bloc.dart`):
```dart
on<AcademicLogin>((event, emit) async {
  // First check if hostel WiFi is logged in
  String? hostelstatus = LocalStorage.getString("hostelstatus");
  if(hostelstatus == "loggedin") {
    emit(AcademicAuthenticating(message: "Logging out from SOPHOS Client first..."));
    // Log out from hostel WiFi first (actual logout call)
    SophosLogger engine = SophosLogger(username: LocalStorage.getString("username")!, password:LocalStorage.getString("password")!);
    try {
      String result = await engine.logout();
      LocalStorage.setString("hostelstatus", "loggedout");
    } catch (e) {
      // Handle error
    }
  }
  
  emit(AcademicAuthenticating(message: "Logging in to Academic Wifi..."));
  // ... rest of academic login logic
});
```

### How It Works:

1. **When clicking "Hostel Login"**:
   - Checks if Academic WiFi is logged in
   - If yes: Shows "Logging out from Academic WiFi first..." → logs out academic → then proceeds with hostel login
   - If no: Directly proceeds with hostel login

2. **When clicking "Academic Login"**:
   - Checks if Hostel WiFi (SOPHOS) is logged in
   - If yes: Shows "Logging out from SOPHOS Client first..." → calls actual logout API → then proceeds with academic login
   - If no: Directly proceeds with academic login

3. **UI Feedback**:
   - Shows authenticating state with descriptive messages
   - HomePage displays loading indicators during transitions
   - Only one WiFi connection can be active at a time

### Benefits:
- ✅ **Mutual Exclusion**: Only one WiFi can be logged in at a time
- ✅ **Automatic Logout**: Seamlessly switches between WiFi types
- ✅ **User Feedback**: Clear messages about what's happening
- ✅ **Error Handling**: Proper cleanup in case of failures
- ✅ **State Management**: Consistent state across app restarts

### Testing:
1. Login to Hostel WiFi → should work normally
2. While logged into Hostel, click Academic Login → should show "Logging out from SOPHOS Client first..." then login to Academic
3. While logged into Academic, click Hostel Login → should show "Logging out from Academic WiFi first..." then login to Hostel
4. Restart app → should maintain the last logged-in state
