# Azure Authentication

## Options

There are 2 main options for authentication with Azure Active Directory

1. Using Azure's built in auth, referred to as "EasyAuth", which sits in front
   of the application and passes authenticated users back to the app. Details
   [here](https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad).
2. Using OAuth2 through Devise & OmniAuth with Active Directory as the provider.
   Various websites detail this solution and there is a ruby gem that could
   help.

We first tried using the first option, but we started getting a redirect
mismatch error after we added the custom domains (ihrbenchmark.who.int +
ihrbenchmark-uat.who.int). The solution to this would have been to verify the
custom domains, but the WHO preferred we switch to the second option instead.

## Flow

1. User navigate to the login page `/users/signin`
   ![](docs/images/auth-flow-signin.png)
2. User clicks the login button, which submits a `POST` to the OmniAuth
   endpoint: `/users/auth/azure_activedirectory_v2`
   - Configured by `config.omniauth` in `config/initializers/devise.rb` and
     `:omniauthable` in `app/models/user.rb`
   - See the documentation for [OmniAuth + Devise](https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview) and the
     [omniauth-azure-activedirectory-v2](https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2#usage) gem for details
3. User is redirected to Microsoft AAD
   ![](docs/images/auth-flow-aad.png)
   URL looks like:
   `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/authorize?client_id=...&prompt&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fusers%2Fauth%2Fazure_activedirectory_v2%2Fcallback&response_type=code&scope=openid+profile+email&state=...`
4. User enters appropriate credentials and is redirected to the application at
   `/users/auth/azure_activedirectory_v2/callback`
5. User's JWT is retrieved and used to locate their account in the system
   - Implemented in `OmniauthCallbacksController#azure_activedirectory_v2` and `Azure::UserFetcher#call`
   - If the user has no account yet, one is created. We trust that if they made
     it here, they are suppose to be here otherwise Azure would have denied
     access for non-WHO members.
   - If the user had an unredeemed access request (because they were just
     approved access), we redeem the request and transfer the fields from the
     request to the user record
6. User's session is created through Devise and is redirected to the plans page

## Azure Mock

In the development and test environments we've created a mock authentication
flow that skips the AAD sign in.

With the exception of production, the `config.azure_auth_mocked` application
config is set to true which changes the sign in page to look like this:

![](docs/images/auth-flow-mock.png)

From here the `Azure::MockSessionsController#create` action is used to sign in,
bypassing any actually authentication.

If you wish to disable this mock in development you set the following
environment variables and then reboot your server:

```sh
AZURE_AUTH_MOCKED=false
AZURE_APPLICATION_CLIENT_ID="replace me"
AZURE_APPLICATION_CLIENT_SECRET="replace me"
AZURE_TENANT_ID="replace me"
```

You'll also need a valid Microsoft account that belongs to that tenant's Active
Directory.
