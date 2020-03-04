defmodule BinaryWsWeb.UserLive.Row do
  use Phoenix.LiveComponent

  defmodule Email do
    use Phoenix.LiveComponent

    def mount(socket) do
      {:ok, assign(socket, count: 0)}
    end

    def render(assigns) do
      ~L"""
      <span id="<%= @id %>" phx-click="click" phx-target="#<%= @id %>">
        Email: <%= @email %> <%= @count %>
      </span>
      """
    end

    def handle_event("click", _, socket) do
      {:noreply, update(socket, :count, &(&1 + 1))}
    end
  end

  def mount(socket) do
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~L"""
    <tr class="user-row" id="<%= @id %>">
      <td phx-hook="LazyArtwork">
        <img
          class="user-artwork"
          src=<%= BinaryWsWeb.Router.Helpers.static_url(BinaryWsWeb.Endpoint, "/images/1x1.gif") %>
          data-src=<%= Map.get(@user.artwork, "url") %>
          alt=<%= @user.username %>
          height=<%= Map.get(@user.artwork, "height") %>
          width=<%= Map.get(@user.artwork, "width") %>
          style="background-color: lightgray"
          role="presentation"
          phx-update="ignore"
          data-lazy-artwork
        />
      </td>
      <td><%= @user.username %> <%= @count %></td>
      <td>
        <%= live_component @socket, Email, id: "email-#{@id}", email: @user.email %>
      </td>
    </tr>
    """
  end
end

defmodule BinaryWsWeb.UserLive.Index do
  use Phoenix.LiveView

  alias BinaryWsWeb.UserLive.Row

  def render(assigns) do
    ~L"""
    <table>
      <tbody id="users" phx-update="append">
        <%= for user <- @users do %>
          <%= live_component @socket, Row, id: "user-#{user.lid}", user: user %>
        <% end %>
      </tbody>
    </table>

    <div phx-hook="ObserverInfiniteScroll" data-page="<%= @page %>"></div>
    """
  end

  def mount(_session, socket) do
    {:ok,
     socket
     |> assign(page: 1, per_page: 20)
     |> fetch(), temporary_assigns: [users: []]}
  end

  defp fetch(%{assigns: %{page: page, per_page: per}} = socket) do
    users =
      Enum.reduce(1..1000, [], fn i, acc ->
        artworks = [
          "https://s3.amazonaws.com/uifaces/faces/twitter/jarjan/128.jpg",
          "https://s3.amazonaws.com/uifaces/faces/twitter/aio___/128.jpg",
          "https://s3.amazonaws.com/uifaces/faces/twitter/kolage/128.jpg",
          "https://s3.amazonaws.com/uifaces/faces/twitter/sauro/128.jpg",
          "https://s3.amazonaws.com/uifaces/faces/twitter/jina/128.jpg"
        ]

        user = %{
          username: "user#{i}",
          name: "User #{i}",
          artwork: %{
            url: Enum.take_random(artworks, 1) |> Enum.at(0),
            height: 65,
            width: 65
          },
          email: "user#{i}@test",
          lid: "#{:rand.uniform(1000000)}-#{i}",
          age: :rand.uniform(1000000),
          organization: "organization#{i}",
          twitter_handle: "@twitter#{i}",
          city: "city#{i}",
          state: "state#{i}",
          country: "country#{i}",
          phone_number: "555-555-5555",
        }

        [user | acc]
      end)
    assign(socket, users: users)
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end
end

