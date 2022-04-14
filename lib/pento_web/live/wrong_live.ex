defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  @highest_number 10

  def initial_state() do
    %{
      time: time,
      number_to_be_guessed: random_number(),
      status: :playing,
      score: 0,
      message: "Guess a number.",
    }
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _session, socket) do
    {:noreply, assign(socket, initial_state())}
  end

  def render(assigns) do
    ~L"""
    <h1>Your score: <%= @score %></h1>
    <h2>
      <%= @message %><br />
      It's <%= @time %>
    </h2>
    <%= if @status != :won do %>
      <h2>
        <%= for n <- 1..10 do %>
          <a href="#" phx-click="guess" phx-value-number="<%= n %>"><%= n %></a>
        <% end %>
      </h2>
    <% else %>
      <h2>
        <%= live_patch("Restart", to: "/guess", replace: true) %>
      <h2>
    <% end %>
    """
  end


  def handle_event("guess", _data, %{assigns: %{status: :won}} = socket), do: {:noreply, socket}

  def handle_event("guess", %{"number" => guess} = data, %{assigns: assigns} = socket) do
    IO.inspect(data)

    socket =
      assigns.number_to_be_guessed
      |> case do
        ^guess ->
          socket
          |> assign(message: "Your guess: #{guess}. Correct. You won!")
          |> assign(score: socket.assigns.score + 1)
          |> assign(status: :won)

        _other ->
          socket
          |> assign(message: "Your guess: #{guess}. Wrong. Guess again.")
          |> assign(score: socket.assigns.score - 1)
      end
      |> assign(time: time())

    {:noreply, socket}
  end

  defp random_number() do
    @highest_number |> :rand.uniform() |> to_string()
  end

  defp time() do
    DateTime.utc_now() |> to_string()
  end

end
