defmodule MicrocrawlerWebapp.Router do
  use MicrocrawlerWebapp.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated,
      handler: MicrocrawlerWebapp.SignInController
  end

  pipeline :static_layout do
    plug :put_layout, {MicrocrawlerWebapp.LayoutView, :static}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_jwt_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated,
      handler: MicrocrawlerWebapp.API.V1.AuthController,
      typ: "access"
  end

  pipeline :graphql do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    # plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  scope "/user", MicrocrawlerWebapp do
    pipe_through [:browser, :browser_session, :static_layout]

    get "/", UserController, :index
    post "/", UserController, :renew
  end

  scope "/signin_old", MicrocrawlerWebapp do
    pipe_through [:browser, :static_layout]

    get "/", SignInController, :index
    post "/", SignInController, :sign_in
  end

  scope "/signup_old", MicrocrawlerWebapp do
    pipe_through [:browser, :static_layout]

    get "/", SignUpController, :index
    post "/", SignUpController, :sign_up
  end

  scope "/api/v1", as: :api_v1, alias: MicrocrawlerWebapp.API.V1 do
    pipe_through :api

    post "/auth/signin", AuthController, :sign_in
    post "/auth/signup", AuthController, :sign_up

    get "/crawlers", CrawlersController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", as: :api_v1, alias: MicrocrawlerWebapp.API.V1 do
    pipe_through [:api, :api_jwt_auth]

    # Testing route
    post "/auth/renew_worker_jwt", AuthController, :renew_worker_jwt
    post "/auth/signout", AuthController, :sign_out
    get  "/auth/user", AuthController, :user_details
  end

  scope "/graphql", MicrocrawlerWebapp do
    pipe_through :graphql

    get "/", GraphqlController, :index
  end

  scope "/", MicrocrawlerWebapp do
      pipe_through :browser # Use the default browser stack

      # get "/", PageController, :index
      get "/*path", PageController, :index
    end
end
