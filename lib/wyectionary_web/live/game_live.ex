defmodule WyectionaryWeb.GameLive do
  use WyectionaryWeb, :live_view

  alias WyectionaryWeb.GamesGs

  def mount(%{"game_code" => game_code} = _params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Wyectionary.PubSub, "game:#{game_code}")

    {:ok, game_params} = GamesGs.get_game(game_code)

    {:ok,
     assign(socket,
       game_code: game_code,
       state: :waiting,
       current_word: nil,
       game_params: game_params,
       user_name: nil
     )}
  end

  def render(assigns) do
    ~H"""
    <div id="restore_user" phx-hook="RestoreUser" class="w-full p-4">
      <div class="flex justify-between">
        <div>
          <h1 class="text-3xl">Wyectionary</h1>
          <h2 class="text-xl">Game code: <%= @game_code %></h2>
        </div>
      </div>
      <div class="mt-6 flex w-full">
        <ul class="w-1/4 bg-gray-200 rounded-lg shadow-lg p-4 h-screen" role="players connected">
          <li
            :for={{user, index} <- Enum.with_index(@game_params.users, 1)}
            class={["uppercase", if(@user_name == user, do: "font-bold")]}
          >
            <%= "#{index}. #{user}" %>
          </li>
        </ul>
        <div class="w-3/4 h-full">
          <div id="container" class="h-full w-full" phx-hook="DrawingCanvas" phx-update="ignore" />
        </div>
      </div>
    </div>
    """
  end

  def handle_event("restore_user", %{"user_name" => name}, socket) do
    Phoenix.PubSub.broadcast_from(
      Wyectionary.PubSub,
      self(),
      "game:#{socket.assigns.game_code}",
      {:new_user, name}
    )

    {:noreply, assign(socket, user_name: name)}
  end

  def handle_event("canvas_updated", %{"stage" => stage}, socket) do
    Phoenix.PubSub.broadcast_from(
      Wyectionary.PubSub,
      self(),
      "game:#{socket.assigns.game_code}",
      {:canvas_updated, stage}
    )

    {:noreply, socket}
  end

  def handle_info({:canvas_updated, stage}, socket) do
    {:noreply, push_event(socket, "canvas_updated", %{stage: stage})}
  end

  def handle_info({:new_user, name}, socket) do
    {:ok, game_params} = GamesGs.get_game(socket.assigns.game_code)

    {:noreply,
     socket
     |> put_flash(:info, "#{name} joined the game")
     |> assign(game_params: game_params)}
  end
end
