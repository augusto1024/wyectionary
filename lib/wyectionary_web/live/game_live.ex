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
       user_name: nil,
       messages: []
     )}
  end

  def render(assigns) do
    ~H"""
    <div id="restore_user" phx-hook="RestoreUser" class="relative w-full sm:p-4 z-30">
      <div class="flex flex-col-reverse sm:justify-center sm:flex-row mt-2 sm:mt-12 w-full gap-2 sm:gap-8 z-10">
        <div class="sm:w-1/4 bg-gray-300 rounded-lg shadow-lg p-4">
          <h2 class="text-lg mb-3">
            <strong>Code:</strong> <span id="game_code"><%= @game_code %></span>
            <button
              id="copy"
              data-to="#game_code"
              phx-hook="CopyToClipboard"
              class="hover:text-gray-500"
            >
              <.icon name="hero-document-duplicate" class="h-6 w-6" />
            </button>
          </h2>
          <ul role="players connected">
            <li
              :for={{user, index} <- Enum.with_index(@game_params.users, 1)}
              class={["uppercase", if(@user_name == user, do: "font-bold")]}
            >
              <%= "#{index}. #{user}" %>
            </li>
          </ul>
        </div>
        <div class="sm:w-[500px] h-full overflow-x-scroll border border-gray-400 rounded-lg bg-white shadow-lg">
          <div id="container" class="h-full w-full" phx-hook="DrawingCanvas" phx-update="ignore" />
        </div>
      </div>
    </div>
    <div class="absolute right-0 top-1/4 w-1/4 bg-white border-l shadow-lg">
      <div class="overflow-y-auto h-96 p-4">
          <ul id="message-list">
              <%= for {user, msg} <- @messages do %>
                  <li class="mb-2 last:mb-0">
                      <strong class="font-semibold"><%= user %>:</strong>
                      <span class="ml-2 text-gray-600"><%= msg %></span>
                  </li>
              <% end %>
          </ul>
      </div>
      <div class="border-t p-4">
          <form phx-submit="send_message">
              <input type="text" name="message" placeholder="Type a message..." class="w-full border-gray-300 rounded-lg shadow-sm p-2">
              <button type="submit" class="hidden">Send</button>
          </form>
      </div>
    </div>
    <div class="absolute flex w-full h-80 bottom-0 left-0 justify-between">
      <img src="/images/bottom-left-footer.png" alt="Wyectionary" class="hidden sm:flex" />
      <img src="/images/bottom-center-footer.png" alt="Wyectionary" class="hidden sm:flex" />
      <img src="/images/bottom-right-footer.png" alt="Wyectionary" class="hidden sm:flex" />
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

  def handle_event("send_message", %{"message" => msg}, socket) do
    # Broadcast message to other users
    Phoenix.PubSub.broadcast_from(
      Wyectionary.PubSub,
      self(),
      "game:#{socket.assigns.game_code}",
      {:new_message, socket.assigns.user_name, msg}
    )

    # Update local state
    messages = [{socket.assigns.user_name, msg} | socket.assigns.messages]
    {:noreply, assign(socket, :messages, messages)}
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

  def handle_info({:new_message, user_name, msg}, socket) do
  # Construct the message tuple
    new_message = {user_name, msg}

    # Append the new message to the existing list of messages
    messages = [new_message | socket.assigns.messages]

    # Update the socket's state with the new list of messages
    {:noreply, assign(socket, :messages, messages)}
  end

end
