defmodule KinoLiveView.LiveReloader do
  def reload do
    Phoenix.PubSub.broadcast(Application.fetch_env!(:kino_live_view, :pubsub_server), "reloader", :trigger)
  end
end
