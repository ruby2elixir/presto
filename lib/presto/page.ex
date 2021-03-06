defmodule Presto.Page do
  use GenServer, restart: :transient

  @type message :: term()
  @type model :: term()
  @type assigns :: Keyword.t | map

  # Plug.Conn callbacks
  @callback init(Plug.opts()) :: Plug.opts()
  @callback call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()

  # Page addressing
  @callback page_id(assigns) :: term()
  @callback key_spec(Presto.page_key()) :: term()

  # State, update, and render
  @callback index(assigns()) :: Phoenix.HTML.safe()
  @callback initial_model(model()) :: term()
  @callback update(message(), model()) :: model()
  @callback render(model()) :: Phoenix.HTML.safe()

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Presto.Page

      def key_spec(page_key) do
        {__MODULE__, page_key}
      end

      def init([]), do: :index

      def call(conn, :index) do
        assigns = Map.put(conn.assigns, :conn, conn)
        {:safe, body} = index(assigns)

        conn
        |> Plug.Conn.put_resp_header("content-type", "text/html; charset=utf-8")
        |> Plug.Conn.send_resp(200, body)
      end

      def page_id(assigns) do
        assigns.visitor_id
      end

      def index(assigns) do
        {:ok, content} = Presto.dispatch(__MODULE__, page_id(assigns), :current)
        content
      end

      def update(_message, model), do: model

      def render(model), do: {:safe, inspect(model)}

      def initial_model(model), do: model

      defoverridable Presto.Page
    end
  end

  ######################
  ### Client Methods ###
  ######################

  defmodule State do
    defstruct page_module: nil,
              page_key: nil,
              model: %{}
  end

  @doc """
  Starts a `Presto.Page` GenServer
  """
  def start_link(page_module, page_key, initial_model \\ %{}) do
    key_spec = page_module.key_spec(page_key)
    name = via_tuple(key_spec)
    model = page_module.initial_model(initial_model)

    initial_state = %State{page_key: page_key, page_module: page_module, model: model}

    GenServer.start_link(__MODULE__, initial_state, name: name)
  end

  @doc """
  Sends an update message to the page, returning the newly
  rendered content.
  """
  def update(page, message) do
    GenServer.call(page, message)
  end

  ######################
  ### Server Methods ###
  ######################

  @doc """
  Initializes state with the page_module and initial model from
  `start_link`
  """
  def init(initial_state) do
    {:ok, initial_state}
  end

  @doc """
  Performs an update operation by calling `update(message, model)`
  on the page_module module from `init`
  """
  def handle_call(message, _from, state) do
    new_state = do_update(message, state)

    reply = {:ok, do_render(new_state)}

    {:reply, reply, new_state}
  end

  ######################
  ### Helper Methods ###
  ######################

  defp do_update(message, state = %{model: model, page_module: page_module}) do
    new_model = page_module.update(message, model)
    %{state | model: new_model}
  end

  defp do_render(%{model: model, page_module: page_module}) do
    page_module.render(model)
  end

  defp via_tuple(page_key) do
    {:via, Registry, {Presto.PageRegistry, page_key}}
  end
end
