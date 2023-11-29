defmodule WyectionaryWeb.LobbyLive do
  use WyectionaryWeb, :live_view

  alias WyectionaryWeb.GamesGs

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       new_game_form: to_form(%{}, as: :new_game),
       lobby_form: to_form(%{}, as: :lobby),
       game_count: GamesGs.games_count()
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center">
      <img src="/images/wyectionary-logo.webp" alt="Wyectionary" class="hidden sm:flex -ml-[130px]" />
      <div class="flex flex-col sm:w-1/2" id="save_user" phx-hook="SaveUser">
        <div class="flex items-center gap-2">
          <h1 class="text-lg font-bold uppercase">Join game</h1>
          <span class="text-xs"><%= @game_count %> game/s in progress</span>
        </div>
        <.form for={@lobby_form} phx-submit="join_game">
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
          <.button type="submit" class="w-24">Join</.button>
        </.form>

        <hr class="my-10" />

        <h1 class="text-lg font-bold uppercase">Create game</h1>

        <.form for={@new_game_form} phx-submit="create_game">
          <.input
            type="text"
            name="user_name"
            value=""
            label="User name"
            placeholder="Insert your name"
          />
          <.button type="submit" class="w-24">Create</.button>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event("create_game", %{"user_name" => name}, socket) do
    {:ok, game_code} = GamesGs.create_game(name)

    {:noreply,
     push_event(socket, "save_user", %{user_name: name, redirect_url: ~p"/game/#{game_code}"})}
  end

  def handle_event("join_game", %{"lobby" => %{"game_code" => code, "user_name" => name}}, socket) do
    case GamesGs.join_game(code, name) do
      {:ok, _} ->
        {:noreply,
         push_event(socket, "save_user", %{user_name: name, redirect_url: ~p"/game/#{code}"})}

      {:error, _} ->
        {:noreply, push_event(socket, "show_error", %{error_message: "Game not found"})}
    end
  end
end
