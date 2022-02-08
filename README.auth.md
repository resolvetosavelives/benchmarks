# README Authentication

## Options

There are 2 main options for authentication with Azure Active Directory

1. Use Azure's built in auth, which will sit in front of the application and pass authenticated users back to the app.
   Details here: https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad
2. Use OAuth2 through devise with Active Directory as the provider. Various websites detail this solution and there is a ruby gem that could help.

For the time being, I am only considering option 1, built in auth.

## Built is Azure AD auth

This seems most promising but requires permissions to edit the pieces (app registrations, identity providers, etc) in the Azure Portal.

Similar permissions are needed for OAuth2, but maybe more of the design would be within our control.

My impression is that we want a solution that requires less maintenance and is more quickly developed.
It also offloads more of the implementation to a central provider instead of writing it ourselves

This document describes how the app works with Azure AD auth: https://docs.microsoft.com/en-us/azure/app-service/overview-authentication-authorization#identity-providers

It seems to be as simple as redirecting to example.com/.auth/login/aad whenever we want someone to login.

When we receive a request, it will either include a cookie or not.

https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-customize-sign-in-out

> To redirect the user post-sign-in to a custom URL, use the post_login_redirect_uri query string parameter (not to be confused with the Redirect URI in your identity provider configuration).
> For example, to navigate the user to /Home/Index after sign-in, use the following HTML code:
> <a href="/.auth/login/<provider>?post_login_redirect_uri=/Home/Index">Log in</a>

Signout link:

    <a href="/.auth/logout">Sign out</a>

or

    GET /.auth/logout?post_logout_redirect_uri=/index.html

To constrain what domain is used to login with AD, read this https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-customize-sign-in-out#limit-the-domain-of-sign-in-accounts

### Tokens

When Azure has authenticated a user, it will send some or all of these headers with every request.

    X-MS-TOKEN-AAD-ID-TOKEN
    X-MS-TOKEN-AAD-ACCESS-TOKEN
    X-MS-TOKEN-AAD-EXPIRES-ON
    X-MS-TOKEN-AAD-REFRESH-TOKEN

https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-oauth-tokens

These headers can't be set from the outside, so they can be trusted as long as the ENV also asserts that the AUTH is enabled.
Theoretically the benchmarks app could be used in another server where these headers are not filtered, so we should verify that azure auth is enabled before trusting them.

## TODO

### Tests

- `sign_in` helper needs to be able to fake sign in with Azure when azure auth is enabled
- Testing for not-logged-in-redirect needs to be able to succeed for azure redirect when azure auth is enabled

### Paths

The following are the devise paths. Whichever are actually used need to be rewritten to work with Azure

            new_user_session GET    /users/sign_in(.:format)            users/sessions#new
                user_session POST   /users/sign_in(.:format)            users/sessions#create
        destroy_user_session DELETE /users/sign_out(.:format)           users/sessions#destroy
           new_user_password GET    /users/password/new(.:format)       devise/passwords#new
          edit_user_password GET    /users/password/edit(.:format)      devise/passwords#edit
               user_password PATCH  /users/password(.:format)           devise/passwords#update
                             PUT    /users/password(.:format)           devise/passwords#update
                             POST   /users/password(.:format)           devise/passwords#create
    cancel_user_registration GET    /users/cancel(.:format)             users/registrations#cancel
       new_user_registration GET    /users/sign_up(.:format)            users/registrations#new
      edit_user_registration GET    /users/edit(.:format)               users/registrations#edit
           user_registration PATCH  /users(.:format)                    users/registrations#update
                             PUT    /users(.:format)                    users/registrations#update
                             DELETE /users(.:format)                    users/registrations#destroy
                             POST   /users(.:format)                    users/registrations#create
       new_user_confirmation GET    /users/confirmation/new(.:format)   devise/confirmations#new
           user_confirmation GET    /users/confirmation(.:format)       devise/confirmations#show
                             POST   /users/confirmation(.:format)       devise/confirmations#create

### Azure Paths

Azure places paths in front of the app that start with `/.auth/`

In order to use the app locally in azure mode, we could use our own controller for these actions:

    /.auth/login/aad?post_login_redirect_uri=/
    /.auth/logout?post_logout_redirect_uri=/

Depending on if we allow multiple login or only one or the other, we may still need the sign in page.
