defmodule Ueberauth.Strategy.LinkedIn.OAuth do
  @moduledoc """
  OAuth2 for LinkedIn.

  Add `client_id` and `client_secret` to your configuration:

  config :ueberauth, Ueberauth.Strategy.LinkedIn.OAuth,
    client_id: System.get_env("LINKEDIN_CLIENT_ID"),
    client_secret: System.get_env("LINKEDIN_CLIENT_SECRET")
  """
  use OAuth2.Strategy

  @defaults [
     strategy: __MODULE__,
     site: "https://api.linkedin.com",
     authorize_url: "https://www.linkedin.com/uas/oauth2/authorization",
     token_url: "https://www.linkedin.com/uas/oauth2/accessToken"
   ]

  @doc """
  Construct a client for requests to LinkedIn.

  This will be setup automatically for you in `Ueberauth.Strategy.LinkedIn`.

  These options are only useful for usage outside the normal callback phase of
  Ueberauth.
  """
  def client(opts \\ [], otp_app \\ :ueberauth) do
    config = Application.get_env(otp_app, Ueberauth.Strategy.LinkedIn.OAuth)
    IO.inspect otp_app, label: "otp_app"
    IO.inspect config, label: "config"
    IO.inspect opts, label: "opts"

    opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)



    json_library = Ueberauth.json_library()

    OAuth2.Client.new(opts)
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth.
  No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    inspect params, label: "params_1"
    opts
    |> client
    # |> put_param(:state, "idos")
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    inspect params, label: "params_4"
    opts
    |> client
    |> OAuth2.Client.get_token!(params)
  end

  def get(token, url, headers \\ [], opts \\ []) do
    client([token: token])
    |> OAuth2.Client.get(url, headers, opts)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    inspect params, label: "params_2"
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    inspect params, label: "params_3"
    client
    |> put_param("client_secret", client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
