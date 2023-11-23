defmodule WyectionaryWeb.GameLive do
  use WyectionaryWeb, :live_view

  def mount(%{"game_code" => game_code} = _params, _session, socket) do
    {:ok,
     assign(socket,
       game_code: game_code,
       state: :waiting,
       current_word: nil,
       players: [],
       user_name: nil
     )}
  end

  def render(assigns) do
    ~H"""
    <div id="restore_user" phx-hook="RestoreUser">
      <h1>Game</h1>
      <h3 :if={@user_name}><%= @user_name %></h3>
      <%= @game_code %>
    </div>
    """
  end

  def handle_event("restore_user", %{"user_name" => name}, socket) do
    {:noreply, assign(socket, user_name: name)}
  end
end
