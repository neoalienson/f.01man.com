part of 'main.dart';

extension Section on _MyHomePageState {
  Widget signinButton(BuildContext context) {
    return FutureBuilder(
      future: Authentication.initializeFirebase(context: context),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error initializing Firebase');
        } else if (snapshot.connectionState == ConnectionState.done) {
          return GoogleSignInButton();
        }
        return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            CustomColors.firebaseOrange,
          ),
        );
      }
    );
  }
}