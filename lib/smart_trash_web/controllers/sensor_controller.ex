defmodule SmartTrashWeb.SensorController do
  use SmartTrashWeb, :controller

  def data(conn, params) do
    IO.inspect(params, label: "yyyyyy")
    conn
    |> put_status(:ok)
    |> json(%{
      data: "yellow"
    })
  end

  def index(conn, _params) do
    case Jason.encode("pink") do
      {:ok, encoded_data} ->
        conn
        |> put_status(:ok)
        |> json(%{
          data: encoded_data
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          error: "Failed to encode data",
          details: inspect(reason)
        })
    end
  end
end
