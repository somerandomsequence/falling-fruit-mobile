controllers.AuthCtrl = ($scope, $rootScope, $http, $timeout, $location, AuthFactory, languageSwitcher, $translate)->
  console.log "Auth Ctrl"

  $scope.authStateData = AuthFactory.data

  $scope.setAuthContext = (context)->
    console.log("Set AuthContext: ", context)
    AuthFactory.setAuthContext(context)

  $scope.togglePasswordVisibility = ()->
    AuthFactory.togglePasswordVisibility()

  $scope.login = ()->
    $http.post(urls.login, user: $scope.login_user).then(
      (response)->
        if response.data isnt null and response.data.hasOwnProperty("auth_token")
          AuthFactory.save($scope.login_user.email, response.data.auth_token)
          $scope.login_user = AuthFactory.get_login_user_model()
          AuthFactory.hideAuth()
          $scope.SignInForm.$setUntouched()
          $rootScope.$broadcast("LOGGED-IN")
        else
          # NOTE: Generic error
          $translate('glossary.generic_error').then((string)->
            alert(string)
          )
          console.log("Login DATA isn't as expected", response.data)
      , (response)->
        $translate('auth.invalid_credentials').then((string)->
          alert(string)
        )
        $scope.login_user.password = null
    )

  $scope.register = ()->
    if $scope.register_user
      user =
        name: $scope.register_user.name
        email: $scope.register_user.email
        password: $scope.register_user.password

    $http.post(urls.register, user: user)
    .success (data)->
      $translate('auth.signed_up_but_unconfirmed').then((string)->
        alert(string)
      )
      AuthFactory.setAuthContext("login")
      initialize_sign_in($scope.register_user.email)
      $scope.register_user = AuthFactory.get_register_user_model()
      $scope.RegisterForm.$setUntouched()
    .error (data) ->
      console.log "Register DATA isn't as expected", data
      if data.errors.email
        $translate('auth.email_taken').then((string)->
          alert(string)
        )
        $scope.register_user.email = null
      if data.errors.password
        # NOTE: Generic error
        $translate('glossary.generic_error').then((string)->
          alert(string)
        )
        $scope.register_user.password = null

  $scope.forgot_password = ()->
    if $scope.forgot_password_user
      user =
        email: $scope.forgot_password_user.email

    $http.post(urls.forgot_password, user: user)
    .success (data)->
      $translate('auth.sent_reset_instructions').then((string)->
        alert(string)
      )
      AuthFactory.setAuthContext("login")
      initialize_sign_in($scope.forgot_password_user.email)
      $scope.forgot_password_user = AuthFactory.get_forgot_password_user_model()
      $scope.ForgotPassword.$setUntouched()
    .error (data)->
      # NOTE: This is more user-friendly, but could be used to scrape emails
      $translate('auth.email_not_found').then((string)->
        alert(string)
      )
      $scope.forgot_password_user.email = null

  $scope.$on "BACKBUTTON", ()->
    console.log "Caught BACKBUTTON event in controller"
    if $scope.authStateData.show_auth == true
      if $scope.authStateData.auth_context == 'login'
        navigator.app.exitApp();
      else
        AuthFactory.setAuthContext('login')
        # Wait until next digest loop, then update view
        $timeout(()->
          $scope.$apply()
        )

  # Initialize sign in form
  initialize_sign_in = (email)->
    $scope.login_user = {}
    if email
      $scope.login_user.email = email
    $scope.SignInForm.$setUntouched()

  # Shows map if already logged in
  if AuthFactory.is_logged_in()
    $rootScope.$broadcast "SHOW-MAP"
  else
    AuthFactory.handleLoggedOut()

  # Language switcher
  $scope.languageSwitcher = languageSwitcher
