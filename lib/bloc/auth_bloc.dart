import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sophos/Sophos%20Logger/Sophos.dart';
import 'package:sophos/Sophos%20Logger/local_storage.dart';
import 'package:sophos/utils/changer.dart' as changer;
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    print('AuthBloc initialized');
    
    on<AppStarted>(_onAppStarted);
    on<CompleteWelcomeEvent>(_onCompleteWelcome);
    on<CompletedInfo>((event, emit) async {
      event.username = changer.usernameWithEmoji(event.username);
      print(event.username);
      await LocalStorage.setString("username", event.username);
      await LocalStorage.setString("password", event.password);
      emit(InfoCompleted());
    });


    on<HostelLogin>((event, emit) async {
      print('HostelLogin event received');
      
      
      
      emit(HostelAuthenticating(message: "Logging in to SOPHOS Client..."));
      SophosLogger engine = SophosLogger(username: LocalStorage.getString("username")!, password:LocalStorage.getString("password")!);
      try {
        String result = await engine.login();
        print('Login result: $result');
        engine.dispose();
        if(result.contains("FAILED") || result.contains("ERROR")){
          if (result.contains("ClientException with SocketException: Failed host lookup:"))
          {
            emit(LoginFailed(message: "❌ Network error: Please connect to VITAP Hostel WIFI and then try logging in here. ${result.trim()}"));
            return;

          }
          emit(LoginFailed(message:result.trim()));
          return;

        }
        else if(result.contains("SUCCESS")){
          LocalStorage.setString("hostelstatus", "loggedin");
          emit(HosteLoggedIn());
          return;
          
        }
          
        
       
       
      } catch (e) {
        engine.dispose();
        
        print('Login failed: $e');
         emit(LoginFailed(message:e.toString()));
          return;
        
      }
      
    });
    on<HostelLogout>((event, emit) async{
      print('HostelLogout event received');
      emit(HostelAuthenticating(message: "Logging out from SOPHOS Client..."));
      SophosLogger engine = SophosLogger(username: LocalStorage.getString("username")!, password:LocalStorage.getString("password")!);
      try {
        String result = await engine.logout();
        print('logout result: $result');
        engine.dispose();
        LocalStorage.setString("hostelstatus", "loggedout");
        emit(HostelLoggedOut());
        return;
       
      } catch (e) {
        print('logout failed: $e');
        // You might want to emit an error state here
        
      }
      
    });
    on<AcademicLogin>((event, emit) async{
      print('AcademicLogin event received');
      
      String? hostelstatus = LocalStorage.getString("hostelstatus");
      if(hostelstatus == "loggedin"){
        emit(AcademicAuthenticating(message: "Logging out from SOPHOS Client first..."));
        // Log out from SOPHOS Client first
        SophosLogger engine = SophosLogger(username: LocalStorage.getString("username")!, password:LocalStorage.getString("password")!);
        try {
          String result = await engine.logout();
          print('logout result: $result');
          engine.dispose();
          LocalStorage.setString("hostelstatus", "loggedout");
          await Future.delayed(Duration(seconds: 1)); // Small delay for user experience
        } catch (e) {
          print('logout failed: $e');
          // You might want to emit an error state here
          
        }
      }
      
      emit(AcademicAuthenticating(message: "Logging in to Academic Wifi..."));
      
      await Future.delayed(Duration(seconds: 2)); // Simulate login process
      LocalStorage.setString("academicstatus", "loggedin");
      emit(AcademicLoggedIn());
    });
    on<AcademicLogout>((event, emit) async {
      print('AcademicLogout event received');
      emit(AcademicAuthenticating(message: "Logging out from Academic Wifi..."));
      // Simulate academic WiFi logout (you can replace this with actual implementation)
      await Future.delayed(Duration(seconds: 1)); // Simulate logout process
      LocalStorage.setString("academicstatus", "loggedout");
      emit(AcademicLoggedOut());
    });


    on<CheckStatus>((event, emit) async {
      print('CheckStatus event received');
      String? hostelstatus = LocalStorage.getString("hostelstatus");
      String? academicstatus = LocalStorage.getString("academicstatus");
      print('Hostel status: $hostelstatus');
      print('Academic status: $academicstatus');
      if(hostelstatus == "loggedin"){
        emit(HosteLoggedIn());
      }else{
        emit(HostelLoggedOut());
      }
      if(academicstatus == "loggedin"){
        emit(AcademicLoggedIn());
      }else{
        emit(AcademicLoggedOut());
      }
      return;
      
    });
    

    
  }
  
}

Future<void> _onCompleteWelcome(CompleteWelcomeEvent event, Emitter<AuthState> emit) async {
    await LocalStorage.setBool('firstTimeUser', false);
    emit(GetInfo());
  }


Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    

    final bool? firstTime = LocalStorage.getBool('firstTimeUser');
    if (firstTime == null || firstTime == true) {
      
      emit(AuthShowWelcomeState());
      return;
    }

    // not first time - check token
    final username = LocalStorage.getString("username");
    final password = LocalStorage.getString("password");
    if (username != null && username.isNotEmpty && password != null && password.isNotEmpty) {
      
      emit(InfoCompleted());
      return;
    }

    emit(GetInfo());
  }