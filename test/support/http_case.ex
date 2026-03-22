defmodule Aya.HttpCase do
  @moduledoc """
  Test case for modules that make external HTTP requests.

  Uses Mimic to mock `Req` for deterministic, fast HTTP tests.
  All HTTP interactions are explicitly mocked — no real network calls.

  ## Usage

      use Aya.HttpCase, async: true

      test "fetches data" do
        Req
        |> expect(:get, fn url, _opts ->
          assert url =~ "api.example.com"
          {:ok, %Req.Response{status: 200, body: %{"data" => "value"}}}
        end)

        assert {:ok, result} = MyModule.fetch_data()
      end
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Mimic

      import Aya.HttpCase

      setup :verify_on_exit!
    end
  end

  setup tags do
    Aya.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Builds a successful Req response.
  """
  def req_response(status \\ 200, body \\ %{}, headers \\ []) do
    {:ok, %Req.Response{status: status, body: body, headers: headers}}
  end

  @doc """
  Builds an error Req response.
  """
  def req_error(reason \\ :timeout) do
    {:error, %Req.TransportError{reason: reason}}
  end
end
