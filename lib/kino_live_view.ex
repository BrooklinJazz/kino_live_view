defmodule KinoLiveView do
  @moduledoc """
  Documentation for `KinoLiveView`.
  """
  @doc """
  Get the routes defined by KinoLiveView.SmartCell from within Livebook.

  ## Examples

      You can use `KinoLiveView.get_routes/0` to dynamically inject routes in your Phoenix router.ex file.

      ```elixir
      # router.ex
      if Application.compile_env(:kino_live_view, :enabled) do
        scope "/" do
          pipe_through :browser

          KinoLiveView.get_routes()
          |> Enum.map(fn %{path: path, module: module, action: action} ->
            live(path, module, action)
          end)
        end
      end
      ```
  """
  defdelegate get_routes, to: KinoLiveView.SmartCell
end
