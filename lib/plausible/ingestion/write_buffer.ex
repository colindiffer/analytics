defmodule Plausible.Ingestion.WriteBuffer do
  @moduledoc false
  use GenServer
  require Logger

  alias Plausible.IngestRepo
  @default_retry_interval_ms 1_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.fetch!(opts, :name))
  end

  def insert(server, row_binary) do
    GenServer.cast(server, {:insert, row_binary})
  end

  def flush(server) do
    GenServer.call(server, :flush, :infinity)
  end

  @impl true
  def init(opts) do
    buffer = opts[:buffer] || []
    max_buffer_size = opts[:max_buffer_size] || default_max_buffer_size()
    flush_interval_ms = opts[:flush_interval_ms] || default_flush_interval_ms()
    retry_interval_ms = opts[:retry_interval_ms] || default_retry_interval_ms()

    Process.flag(:trap_exit, true)
    timer = Process.send_after(self(), :tick, flush_interval_ms)

    {:ok,
     %{
       buffer: buffer,
       timer: timer,
       name: Keyword.fetch!(opts, :name),
       insert_sql: Keyword.fetch!(opts, :insert_sql),
       insert_opts: Keyword.fetch!(opts, :insert_opts),
       header: Keyword.fetch!(opts, :header),
       buffer_size: IO.iodata_length(buffer),
       max_buffer_size: max_buffer_size,
       flush_interval_ms: flush_interval_ms,
       retry_interval_ms: retry_interval_ms
     }}
  end

  @impl true
  def handle_cast({:insert, row_binary}, state) do
    state = %{
      state
      | buffer: [row_binary | state.buffer],
        buffer_size: state.buffer_size + IO.iodata_length(row_binary)
    }

    if state.buffer_size >= state.max_buffer_size do
      Logger.notice("#{state.name} buffer full, flushing to ClickHouse")
      Process.cancel_timer(state.timer)
      flush_and_reschedule(state, fn new_state -> {:noreply, new_state} end)
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_info(:tick, state) do
    flush_and_reschedule(state, fn new_state -> {:noreply, new_state} end)
  end

  @impl true
  def handle_info(:retry_flush, state) do
    flush_and_reschedule(state, fn new_state -> {:noreply, new_state} end)
  end

  @impl true
  def handle_call(:flush, _from, state) do
    %{timer: timer} = state
    Process.cancel_timer(timer)
    flush_and_reschedule(state, fn new_state -> {:reply, :ok, new_state} end, fn new_state, reason ->
      {:reply, {:error, reason}, new_state}
    end)
  end

  @impl true
  def terminate(_reason, %{name: name} = state) do
    Logger.notice("Flushing #{name} buffer before shutdown...")
    case attempt_flush(state) do
      {:ok, _} ->
        :ok

      {:error, reason, _errored_state} ->
        Logger.error("Failed to flush #{name} buffer during shutdown:\n#{reason}")
    end
  end

  defp flush_and_reschedule(state, on_success, on_error \\ fn new_state, _reason ->
    {:noreply, new_state}
  end) do
    case attempt_flush(state) do
      {:ok, flushed_state} ->
        new_timer = schedule_tick(flushed_state)
        on_success.(%{flushed_state | timer: new_timer})

      {:error, reason, errored_state} ->
        log_flush_failure(errored_state, reason)
        new_timer = schedule_retry(errored_state)
        on_error.(%{errored_state | timer: new_timer}, reason)
    end
  end

  defp attempt_flush(%{buffer: []} = state), do: {:ok, state}

  defp attempt_flush(%{buffer: buffer, buffer_size: buffer_size, name: name} = state) do
    Logger.notice("Flushing #{buffer_size} byte(s) RowBinary from #{name}")

    flush_buffer = Enum.reverse(buffer)
    payload = [state.header | flush_buffer]

    case safe_query(state.insert_sql, payload, state.insert_opts) do
      :ok ->
        {:ok, %{state | buffer: [], buffer_size: 0}}

      {:error, reason} ->
        {:error, reason, state}
    end
  end

  defp safe_query(sql, payload, opts) do
    try do
      IngestRepo.query!(sql, payload, opts)
      :ok
    catch
      kind, reason ->
        {:error, Exception.format(kind, reason, __STACKTRACE__)}
    end
  end

  defp log_flush_failure(state, reason) do
    Logger.error(
      "Failed to flush #{state.name} buffer (#{state.buffer_size} byte(s)); retrying in #{state.retry_interval_ms}ms\n#{reason}"
    )
  end

  defp schedule_tick(%{flush_interval_ms: flush_interval_ms}) do
    Process.send_after(self(), :tick, flush_interval_ms)
  end

  defp schedule_retry(%{retry_interval_ms: retry_interval_ms}) do
    Process.send_after(self(), :retry_flush, retry_interval_ms)
  end

  defp default_flush_interval_ms do
    Keyword.fetch!(Application.get_env(:plausible, IngestRepo), :flush_interval_ms)
  end

  defp default_max_buffer_size do
    Keyword.fetch!(Application.get_env(:plausible, IngestRepo), :max_buffer_size)
  end

  defp default_retry_interval_ms, do: @default_retry_interval_ms

  @doc false
  def compile_time_prepare(schema) do
    fields =
      schema.__schema__(:fields)
      |> Enum.reject(&(&1 in fields_to_ignore()))

    types =
      Enum.map(fields, fn field ->
        type = schema.__schema__(:type, field) || raise "missing type for #{field}"

        type
        |> Ecto.Type.type()
        |> Ecto.Adapters.ClickHouse.Schema.remap_type(schema, field)
      end)

    encoding_types = Ch.RowBinary.encoding_types(types)

    header =
      fields
      |> Enum.map(&to_string/1)
      |> Ch.RowBinary.encode_names_and_types(types)
      |> IO.iodata_to_binary()

    insert_sql =
      "INSERT INTO #{schema.__schema__(:source)} (#{Enum.join(fields, ", ")}) FORMAT RowBinaryWithNamesAndTypes"

    %{
      fields: fields,
      types: types,
      encoding_types: encoding_types,
      header: header,
      insert_sql: insert_sql,
      insert_opts: [
        command: :insert,
        encode: false,
        source: schema.__schema__(:source),
        cast_params: []
      ]
    }
  end

  defp fields_to_ignore(), do: [:acquisition_channel, :interactive?]
end
