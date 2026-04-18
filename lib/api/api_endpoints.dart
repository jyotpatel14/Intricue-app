// class ApiEndpoints {
//   final String siteUrl, authUrl, apiUrl ;

//   const ApiEndpoints({
//     required this.siteUrl,
//     required this.authUrl,
//     // this.apiUrl = "http://localhost:55557/api/v1",
//     this.apiUrl = "https://turfbooking.run.place/api",
//   });

//   String getAuthUrl() {
//     return authUrl;
//   }

//   String getSiteUrl() {
//     return siteUrl;
//   }

//   String getBaseApiUrl() {
//     return "https://turfbooking.run.place/api";
//     // return "https://quiz-backend-1-yjm4.onrender.com/api/v1";
//   }



//   //region Authentication Api
//   String apiPostLoginDetails() {
//     return "${getBaseApiUrl()}/login";
//   }

//   String apiRegisterUser() {
//     return "${getBaseApiUrl()}/register";
//   }

//   String apiForgotPassUser() {
//     return "${getBaseApiUrl()}/forgotPass";
//   }
//   String apiVerifyCodeUser() {
//     return "${getBaseApiUrl()}/verify-otp";
//   }
//   String apiResendCodeUser() {
//     return "${getBaseApiUrl()}/resend-otp";
//   }
//   // String apiSignUpUser({
//   //   required String locale,
//   // }) =>
//   //     '${getBaseApiUrl()}MobileLMS/MobileCreateSignUp?Locale=$locale&SiteURL=$siteUrl';

//   //endregion
//   String apiGetUser(String userId) {
//     return "${getBaseApiUrl()}/users/$userId";
//   }

//   String apiUpdateUser(String userId) {
//     return "${getBaseApiUrl()}/users/$userId";
//   }

//   String qpiGetQuizQuestion(String levelId) {
//     return "${getBaseApiUrl()}/question/getQuestion/$levelId";
//   }

//   String addVenue() {
//     return "${getBaseApiUrl()}/venues/add";
//   }

//   String getVenues() {
//     return "${getBaseApiUrl()}/venues/list";
//   }

//   String getVenuesById(String id) {
//     return "${getBaseApiUrl()}/venues/details/$id";
//   }

//   String updateVenue(String id) {
//     return "${getBaseApiUrl()}/venues/update/$id";
//   }

//   String deleteVenue(String id) {
//     return "${getBaseApiUrl()}/venues/delete/$id";
//   }
//   //region GetUser

//   //endregion

//   //region Home Menu Api

//   //Profile
//   String getProfile(String id){
//     return "${getBaseApiUrl()}/profile/detais";
//   }

// }
