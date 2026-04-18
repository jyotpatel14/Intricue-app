
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart';
// import 'package:provider/provider.dart';
// import '../../api/rest_client.dart';
// import '../../backend/navigation/navigation_controller.dart';
// import '../../utils/extensions.dart';
// import '../utils/app_string.dart';
// import '../utils/my_print.dart';
// import '../utils/my_utils.dart';
// import 'api_call_model.dart';
// import 'api_endpoints.dart';
// import 'api_url_configuration_provider.dart';

// class ApiController {
//   ApiController._();

//   static final ApiController _instance = ApiController._();

//   factory ApiController() => _instance;

//   final ApiUrlConfigurationProvider _apiDataProvider =
//       ApiUrlConfigurationProvider();

//   ApiUrlConfigurationProvider get apiDataProvider => _apiDataProvider;

//   ApiEndpoints get apiEndpoints => ApiEndpoints(
//     siteUrl: apiDataProvider.getCurrentSiteUrl(),
//     authUrl: apiDataProvider.getCurrentAuthUrl(),
//     apiUrl: apiDataProvider.getCurrentBaseApiUrl(),
//   );

//   //(1) This is the main method which is responsible for Making the API Call and Handle That
//   Future<DataResponseModel<T>> callApi<T>({
//     required ApiCallModel apiCallModel,
//     bool isLogoutOnAuthorizationExpired = true,
//   }) async {
//     DataResponseModel<T> responseModel;

//     if (apiCallModel.isIsolateCall &&
//         !apiCallModel.isGetDataFromHive &&
//         !apiCallModel.isStoreDataInHive) {
//       responseModel = await compute<ApiCallModel, DataResponseModel<T>>(
//         makeApiCallAndParseData<T>,
//         apiCallModel,
//       );
//       if (responseModel.printLogMessage != null) {
//         MyPrint.appendLogData(logMessage: responseModel.printLogMessage!);
//       }
//     } else {
//       responseModel = await makeApiCallAndParseData<T>(apiCallModel);
//     }
//     MyPrint.printOnConsole("statusCOde: ${responseModel.appErrorModel?.code}");
//     if (responseModel.appErrorModel?.code == 401) {
//       //Logout
//       MyPrint.printOnConsole("statusCOde: helo");
//       // AuthenticationController authenticationController =
//       //     AuthenticationController(
//       //       authenticationProvider: NavigationController
//       //           .mainScreenNavigator
//       //           .currentContext!
//       //           .read<AuthenticationProvider>(),
//       //     );
//       // authenticationController.logout(
//       //   NavigationController.mainScreenNavigator.currentContext!,
//       // );
//       // NavigationController.navigateToLoginScreen(
//       //     navigationOperationParameters: NavigationOperationParameters(
//       //         context: NavigationController.mainScreenNavigator.currentContext!, navigationType: NavigationType.pushNamedAndRemoveUntil));
//       AuthBloc authBloc = AuthBloc(repository: AuthenticationRepository(apiController: _instance));
//       authBloc.add(LogoutEvent());
//     }

//     return responseModel;
//   }

//   //(2) This Method is Responsible for Making a ApiCall and parse the data in the desired format
//   // Future<DataResponseModel<T>> makeApiCallAndParseData<T>(
//   //   ApiCallModel apiCallModel,
//   // ) async {
//   //   Response? response = await RestClient.callApi(apiCallModel: apiCallModel);
//   //
//   //   T? data;
//   //   AppErrorModel? appErrorModel;
//   //
//   //   if (response?.statusCode == 200 || response?.statusCode == 201) {
//   //     MyPrint.printOnConsole(
//   //       "Parsing Data For Type:${apiCallModel.parsingType}",
//   //     );
//   //     data = ModelDataParser.parseDataFromDecodedValue<T>(
//   //       parsingType: apiCallModel.parsingType,
//   //       decodedValue: MyUtils.decodeJson(response!.body),
//   //     );
//   //   } else if (response?.statusCode == 401) {
//   //     appErrorModel = AppErrorModel(
//   //       message: AppStrings.tokenExpired,
//   //       code: 401,
//   //     );
//   //   } else {
//   //     appErrorModel = AppErrorModel(
//   //       message: response?.body ?? AppStrings.errorInApiCall,
//   //       code: response?.statusCode ?? -1,
//   //     );
//   //   }
//   //
//   //   return DataResponseModel<T>(
//   //     data: data,
//   //     message: (Map.from(MyUtils.decodeJson(response?.body ?? ""))) ,
//   //     appErrorModel: appErrorModel,
//   //     statusCode: response?.statusCode ?? -1,
//   //     printLogMessage: apiCallModel.isIsolateCall ? MyPrint.getLog() : null,
//   //   );
//   // }
//   Future<DataResponseModel<T>> makeApiCallAndParseData<T>(
//       ApiCallModel apiCallModel,
//       ) async {
//     Response? response =
//     await RestClient.callApi(apiCallModel: apiCallModel);

//     T? data;
//     AppErrorModel? appErrorModel;

//     Map<String, dynamic>? decodedJson;

//     if (response?.body != null && response!.body.isNotEmpty) {
//       decodedJson = MyUtils.decodeJson(response.body);
//     }

//     if (response?.statusCode == 200 || response?.statusCode == 201) {
//       MyPrint.printOnConsole(
//         "Parsing Data For Type: ${apiCallModel.parsingType} ${decodedJson}",
//       );

//       /// ✅ Parse only `data` object
//       if (decodedJson?['data'] != null) {
//         data = ModelDataParser.parseDataFromDecodedValue<T>(
//           parsingType: apiCallModel.parsingType,
//           decodedValue: decodedJson!,
//         );
//       }
//     } else if (response?.statusCode == 401) {
//       appErrorModel = AppErrorModel(
//         message: AppStrings.tokenExpired,
//         code: 401,
//       );
//     } else {
//       appErrorModel = AppErrorModel(
//         message: decodedJson?['message'] ??
//             response?.body ??
//             AppStrings.errorInApiCall,
//         code: response?.statusCode ?? -1,
//       );
//     }

//     MyPrint.printOnConsole("Make Call: data: $data");
//     return DataResponseModel<T>(
//       data: data,
//       success: decodedJson?['success'] ?? false,
//       statusCode: decodedJson?['code'] ?? response?.statusCode ?? -1,
//       message: decodedJson?['message'],
//       count: decodedJson?['count'],
//       appErrorModel: appErrorModel,
//       printLogMessage:
//       apiCallModel.isIsolateCall ? MyPrint.getLog() : null,
//     );
//   }

//   // }

//   // Future<DataResponseModel<T>> makeMultipartCallAndParseData<T>(ApiCallModel apiCallModel) async {
//   //
//   //   Response? response = await RestClient.multipartRequestCall(apiCallModel: apiCallModel);
//   //
//   //   T? data;
//   //   AppErrorModel? appErrorModel;
//   //
//   //   if (response?.statusCode == 200) {
//   //     MyPrint.printOnConsole("Parsing Data For Type:${apiCallModel.parsingType}");
//   //     data = ModelDataParser.parseDataFromDecodedValue<T>(parsingType: apiCallModel.parsingType, decodedValue: MyUtils.decodeJson(response!.body));
//   //
//   //     // if(apiCallModel.isStoreDataInHive) {
//   //     //   HiveOperationController().makeCall(
//   //     //     hiveCallModel: HiveCallModel(
//   //     //       operationType: HiveOperationType.set,
//   //     //       parsingType: apiCallModel.parsingType,
//   //     //       key: apiCallModel.url,
//   //     //       box: apiCallModel.hiveBox,
//   //     //       value: response.body,
//   //     //     ),
//   //     //   );
//   //     // }
//   //   } else if (response?.statusCode == 401) {
//   //     appErrorModel = AppErrorModel(
//   //       message: AppStrings.tokenExpired,
//   //       code: 401,
//   //     );
//   //   } else {
//   //     appErrorModel = AppErrorModel(
//   //       message: response?.body ?? AppStrings.errorInApiCall,
//   //       code: response?.statusCode ?? -1,
//   //     );
//   //   }
//   //
//   //   return DataResponseModel<T>(
//   //     data: data,
//   //     appErrorModel: appErrorModel,
//   //     statusCode: response?.statusCode ?? -1,
//   //   );
//   // }

//   //To Get Api Request Data with the minimum required values, other parameters it will get from ApiProvider present in the object
//   Future<ApiCallModel> getApiCallModelFromData<RequestBodyType>({
//     required RestCallType restCallType,
//     required ModelDataParsingType parsingType,
//     required String url,
//     Map<String, String>? queryParameters,
//     RequestBodyType? requestBody,
//     // List<InstancyMultipartFileUploadModel>? files,
//     Map<String, String>? fields,
//     String? siteUrl,
//     int? userId,
//     int? siteId,
//     String? locale,
//     String? token,
//     bool isAuthenticatedApiCall = true,
//     bool isGetDataFromHive = false,
//     bool isStoreDataInHive = false,
//     bool isIsolateCall = true,
//   }) async {
//     String currentSiteUrl = "";
//     return ApiCallModel<RequestBodyType>(
//       restCallType: restCallType,
//       parsingType: parsingType,
//       url: url,
//       queryParameters: queryParameters,
//       requestBody: requestBody,
//       fields: fields,
//       siteUrl: currentSiteUrl,
//       locale: locale.checkNotEmpty ? locale! : apiDataProvider.getLocale(),
//       token: token.checkNotEmpty ? token! : apiDataProvider.getAuthToken(),
//       userId: userId ?? apiDataProvider.getCurrentUserId(),
//       siteId: siteId ?? apiDataProvider.getCurrentSiteId(),
//       isAuthenticatedApiCall: isAuthenticatedApiCall,
//       isGetDataFromHive: isGetDataFromHive,
//       isStoreDataInHive: isStoreDataInHive,
//       isIsolateCall: isIsolateCall,
//     );
//   }
// }
