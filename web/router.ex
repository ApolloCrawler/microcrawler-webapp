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
    plug Guardian.Plug.EnsureAuthenticated, handler: MicrocrawlerWebapp.SignInController
  end

  pipeline :static_layout do
    plug :put_layout, {MicrocrawlerWebapp.LayoutView, :static}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug :accepts, ["json"]
  end

  scope "/", MicrocrawlerWebapp do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/account", MicrocrawlerWebapp do
    pipe_through [:browser, :browser_session, :static_layout]

    get "/", AccountController, :index
    post "/", AccountController, :renew
  end

  scope "/signin", MicrocrawlerWebapp do
    pipe_through [:browser, :static_layout]

    get "/", SignInController, :index
    post "/", SignInController, :sign_in
  end

  scope "/signup", MicrocrawlerWebapp do
    pipe_through [:browser, :static_layout]

    get "/", SignUpController, :index
    post "/", SignUpController, :sign_up
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", as: :api_v1, alias: MicrocrawlerWebapp.API.V1 do
    pipe_through :api

    get "/test", ApiController, :index
  end

  scope "/graphql", MicrocrawlerWebapp do
    pipe_through :graphql

    get "/", GraphqlController, :index
  end
end
