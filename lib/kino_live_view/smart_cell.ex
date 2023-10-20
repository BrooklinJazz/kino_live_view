defmodule KinoLiveView.SmartCell do
  use Kino.JS
  use Kino.JS.Live
  use Kino.SmartCell, name: "KinoLiveView"
  require IEx.Helpers
  require Logger

  @impl true
  def init(attrs, ctx) do
    {:ok,
     ctx
     |> assign(
       path: attrs["path"] || "/",
       action: attrs["action"] || ":index"
     ),
     editor: [
       attribute: "code",
       language: "elixir",
       default_source: ""
     ]}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{path: ctx.assigns.path, action: ctx.assigns.action}, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    %{
      "path" => ctx.assigns.path,
      "action" => ctx.assigns.action
    }
  end

  @impl true
  def to_source(attrs) do
    """
    import Kernel, except: [defmodule: 2]
    import KinoLiveView.SmartCell, only: [defmodule: 2, register: 2]

    #{attrs["code"]}
    |> register("#{attrs["path"]}")

    import KinoLiveView.SmartCell, only: []
    import Kernel
    :ok
    """
  end

  def get_routes() do
    Application.get_env(:kino_live_view_native, :routes, [])
  end

  def put_routes(routes) do
    Application.put_env(:kino_live_view_native, :routes, routes)
  end

  def register({:module, module, _, _}, path) do
    route = %{path: path, action: :example, module: module}

    # add or update the route
    get_routes()
    |> Enum.reject(fn r -> r.path == path end)
    |> Kernel.++([route])
    |> put_routes()

    # recompile the router to use updated routes
    IEx.Helpers.r(Application.fetch_env!(:kino_live_view, :router_module))

    # trigger live reload
    KinoLiveView.LiveReloader.reload()

    module
  end

  @impl true
  def handle_event("update_" <> variable_name, value, ctx) do
    variable = String.to_existing_atom(variable_name)
    ctx = assign(ctx, [{variable, value}])

    broadcast_event(
      ctx,
      "update_" <> variable_name,
      ctx.assigns[variable]
    )

    {:noreply, ctx}
  end

  defmacro defmodule(alias, do_block) do
    module_name =
      alias
      |> Macro.to_string()
      |> then(&("Elixir." <> &1))
      |> String.to_atom()

    if is_registered_live_view?(module_name) do
      Logger.info("Replacing existing LiveView #{module_name}")
      Livebook.Runtime.Evaluator.delete_module(module_name)
    end

    quote do
      Kernel.defmodule(unquote(module_name), unquote(do_block))
    end
  end

  defp is_registered_live_view?(module_name) do
    get_routes()
    |> Enum.any?(&(&1.module == module_name))
  end

  asset "main.js" do
    """
    export function init(ctx, payload) {
      ctx.importCSS("main.css");
      ctx.importCSS("https://fonts.googleapis.com/css2?family=Inter:wght@400;500&display=swap");

      root.innerHTML = `
        <div class="app">
          <label class="label">Route</label>
          <input class="input" type="text" name="path" />

          <label class="label">Action</label>
          <input class="input" type="text" name="action" />
        </div>
      `;

      const sync = (id) => {
          const variableEl = ctx.root.querySelector(`[name="${id}"]`);
          variableEl.value = payload[id];

          variableEl.addEventListener("change", (event) => {
            ctx.pushEvent(`update_${id}`, event.target.value);
          });

          ctx.handleEvent(`update_${id}`, (variable) => {
            variableEl.value = variable;
          });
      }

      sync("path")
      sync("action")

      ctx.handleSync(() => {
          // Synchronously invokes change listeners
          document.activeElement &&
            document.activeElement.dispatchEvent(new Event("change"));
      });
    }
    """
  end

  asset "main.css" do
    """
    .app {
      font-family: "Inter";
      display: flex;
      align-items: center;
      gap: 16px;
      background-color: #ecf0ff;
      padding: 8px 16px;
      border: solid 1px #cad5e0;
      border-radius: 0.5rem 0.5rem 0 0;
    }

    .label {
      font-size: 0.875rem;
      font-weight: 500;
      color: #445668;
      text-transform: uppercase;
    }

    .input {
      padding: 8px 12px;
      background-color: #f8f8afc;
      font-size: 0.875rem;
      border: 1px solid #e1e8f0;
      border-radius: 0.5rem;
      color: #445668;
      min-width: 150px;
    }

    .input:focus {
      border: 1px solid #61758a;
      outline: none;
    }
    """
  end
end
