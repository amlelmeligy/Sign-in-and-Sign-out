import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:signin/cache/cache_helper.dart';
import 'package:signin/core/api/api_consumer.dart';
import 'package:signin/core/api/end_points.dart';
import 'package:signin/core/errors/exception.dart';
import 'package:signin/cubit/user_state.dart';
import 'package:signin/models/sign_in_model.dart';
import 'package:signin/models/sign_up_model.dart';
import 'package:signin/models/user_model.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this.api) : super(UserInitial());
  final ApiConsumer api;
  //Sign in Form key
  GlobalKey<FormState> signInFormKey = GlobalKey();

  //Sign in email
  TextEditingController signInEmail = TextEditingController();

  //Sign in password
  TextEditingController signInPassword = TextEditingController();

  //Sign Up Form key
  GlobalKey<FormState> signUpFormKey = GlobalKey();

  //Profile Pic
  XFile? profilePic;

  //Sign up name
  TextEditingController signUpName = TextEditingController();

  //Sign up phone number
  TextEditingController signUpPhoneNumber = TextEditingController();

  //Sign up email
  TextEditingController signUpEmail = TextEditingController();

  //Sign up password
  TextEditingController signUpPassword = TextEditingController();

  //Sign up confirm password
  TextEditingController confirmPassword = TextEditingController();

  uploadProfilePic(XFile image) {
    profilePic = image;
    emit(UploadProfilePic());
  }

  SignInModel? user; //ناخد نسخه من الموديل ونديها اسم يوزر
  signIn() async {
    try {
      emit(SignInLoading());
      final response = await api.post(
        EndPoint.signIn,
        data: {
          ApiKey.email: signInEmail.text,
          ApiKey.password: signInPassword.text,
        },
      );
      user = SignInModel.fromJson(response);
      final decodedToken = JwtDecoder.decode(user!.token);
      //من خلاله بنفك التشفير وبيبقي معانا كل البيانات بقي

      CacheHelper().saveData(key: ApiKey.token, value: user!.token);
      CacheHelper().saveData(key: ApiKey.id, value: decodedToken[ApiKey.id]);

      emit(SignInSuccess());
    } on ServerException catch (e) {
      emit(
        SignInFailure(errMessage: e.errModel.errorMessage),
      );
    }
  }

  signUp() async {
    try {
      emit(SignUpLoading());
      final response = await api.post(
        EndPoint.signUp,
        data: {
          ApiKey.name: signUpName.text,
          ApiKey.email: signUpEmail.text,
          ApiKey.password: signUpPassword.text,
          ApiKey.phone: signUpPhoneNumber.text,
          ApiKey.confirmPassword: confirmPassword.text,
          ApiKey.location:
              '{"name":"methalfa","address":"meet halfa","coordinates":[30.1572709,31.224779]}',
          ApiKey.profilePic: await uploadImageToAPI(profilePic!),
        },
      );
      final signUPModel = SignUpModel.fromJson(response);

      emit(SignUpSuccess(
        message: signUPModel.message,
      ));
    } on ServerException catch (e) {
      emit(
        SignUpFailure(errMessage: e.errModel.errorMessage),
      );
    }
  }

  getUserProfile() async {
    try {
      emit(GetUserLoading());
      final response = await api.get(
        EndPoint.getUserDataEndPoint(
          CacheHelper().getData(key: ApiKey.id),
        ),
      );
      emit(GetUserSuccess(user: UserModel.fromJson(response)));
    } on ServerException catch (e) {
      emit(
        GetUserFailure(errMessage: e.errModel.errorMessage),
      );
    }
  }
}

//
//
//
//
//

//
//
//
//
Future uploadImageToAPI(XFile image) async {
  return MultipartFile.fromFile(image.path,
      filename: image.path.split('/').last);
}
// حته كدا بتساعدنا ف رفع الصوره
