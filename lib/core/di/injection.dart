import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/apple_sign_in.dart';
import '../../features/authentication/domain/usecases/check_auth_status.dart';
import '../../features/authentication/domain/usecases/email_sign_in.dart';
import '../../features/authentication/domain/usecases/facebook_sign_in.dart';
import '../../features/authentication/domain/usecases/google_sign_in.dart';
import '../../features/authentication/domain/usecases/verify_email.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';

import '../../features/signup/data/datasources/signup_local_datasource.dart';
import '../../features/signup/data/repositories/signup_repository_impl.dart';
import '../../features/signup/domain/repositories/signup_repository.dart';
import '../../features/signup/domain/usecases/get_signup_progress.dart';
import '../../features/signup/domain/usecases/save_signup_step.dart';
import '../../features/signup/domain/usecases/submit_signup_data.dart';
import '../../features/signup/presentation/bloc/signup_bloc.dart';

import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Authentication
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      googleSignIn: sl(),
      appleSignIn: sl(),
      facebookSignIn: sl(),
      emailSignIn: sl(),
      verifyEmail: sl(),
      checkAuthStatus: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => AppleSignInUseCase(sl()));
  sl.registerLazySingleton(() => FacebookSignInUseCase(sl()));
  sl.registerLazySingleton(() => EmailSignInUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      client: sl(),
      googleSignIn: GoogleSignIn(scopes: ['email', 'profile']),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Signup
  // Bloc
  sl.registerFactory(
    () => SignupBloc(
      saveSignupStep: sl(),
      getSignupProgress: sl(),
      submitSignupData: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SaveSignupStepUseCase(sl()));
  sl.registerLazySingleton(() => GetSignupProgressUseCase(sl()));
  sl.registerLazySingleton(() => SubmitSignupDataUseCase(sl()));

  // Repository
  sl.registerLazySingleton<SignupRepository>(
    () => SignupRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SignupLocalDataSource>(
    () => SignupLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
}
