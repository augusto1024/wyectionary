defmodule WyectionaryWeb.GamesGs do
  use GenServer

  # Callbacks

  ### client
  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def create_game(user_name) do
    GenServer.call(__MODULE__, {:create_game, user_name})
  end

  def get_game(game_code) do
    GenServer.call(__MODULE__, {:get_game, game_code})
  end

  def games_count() do
    GenServer.call(__MODULE__, {:games_count})
  end

  def join_game(game_code, user_name) do
    GenServer.call(__MODULE__, {:join_game, game_code, user_name})
  end

  ### server
  def init(_games) do
    {:ok, %{}}
  end

  def handle_call({:get_game, game_code}, _from, state) do
    {:reply, {:ok, Map.get(state, game_code)}, state}
  end

  def handle_call({:games_count}, _from, state) do
    {:reply, Map.keys(state) |> length(), state}
  end

  def handle_call({:create_game, user_name}, _from, state) do
    game_code = :crypto.strong_rand_bytes(4) |> Base.url_encode64(padding: false)

    {:reply, {:ok, game_code},
     Map.merge(
       state,
       Enum.into(
         [
           {
             game_code,
             %{
               owner: user_name,
               users: [user_name],
               current_user: user_name,
               current_word: nil
             }
           }
         ],
         %{}
       )
     )}
  end

  def handle_call({:join_game, game_code, user_name}, _from, state) do
    case Map.get(state, game_code) do
      nil ->
        {:reply, {:error, :game_not_found}, state}

      %{users: users} ->
        {:reply, {:ok, game_code},
         Map.put(
           state,
           game_code,
           Map.put(state[game_code], :users, [user_name | users])
         )}
    end
  end
end
