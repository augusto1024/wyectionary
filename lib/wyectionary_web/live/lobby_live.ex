defmodule WyectionaryWeb.LobbyLive do
  use WyectionaryWeb, :live_view

  alias WyectionaryWeb.GamesGs

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="save_user" phx-hook="SaveUser">
      <h1>Join game</h1>

      <.form for={:lobby} phx-submit="join_game">
        <.input
          type="text"
          name="lobby[game_code]"
          value=""
          label="Invitation code"
          placeholder="Insert your code here"
        />
        <.input
          type="text"
          name="lobby[user_name]"
          value=""
          label="User name"
          placeholder="Insert your name"
        />
        <button type="submit">Join</button>
      </.form>

      <h1>Create game</h1>

      <.form for={:new_game} phx-submit="create_game">
        <.input
          type="text"
          name="user_name"
          value=""
          label="User name"
          placeholder="Insert your name"
        />
        <button type="submit">Create</button>
      </.form>
    </div>
    """
  end

  def handle_event("create_game", %{"user_name" => name}, socket) do
    {:ok, code_game} = GamesGs.create_game(name)

    {:noreply,
     push_event(socket, "save_user", %{user_name: name, redirect_url: ~p"/game/#{code_game}"})}
  end
end
