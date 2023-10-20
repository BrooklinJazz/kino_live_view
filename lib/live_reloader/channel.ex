defmodule KinoLiveView.LiveReloader.Channel do
  @moduledoc """
  The client listens on the phoenix:live_reload channel for the "assets_change" message.
  So we send "assets_change" js event, the client will reload the page.

  Further explanation here: https://shankardevy.com/code/phoenix-live-reload/
  """
  use Phoenix.Channel

  def join("phoenix:live_reload", _msg, socket) do
    {:ok, _} = Application.ensure_all_started(:phoenix_live_reload)

    Phoenix.PubSub.subscribe(Application.fetch_env!(:kino_live_view, :pubsub_server), "reloader")

    {:ok, socket}
  end

  def handle_info(:trigger, socket) do
    push(socket, "assets_change", %{asset_type: ""})

    {:noreply, socket}
  end
end
