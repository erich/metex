defmodule Metex.Cache do
  @moduledoc false

  use GenServer

  @name CA

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: CA])
  end

  def write(term, value) do
    GenServer.call(@name, {:write, term, value})
  end

  def read(term) do
    GenServer.call(@name, {:read, term})
  end

  def delete(term) do
    GenServer.cast(@name, {:delete, term})
  end

  def inspect() do
    GenServer.call(@name, {:inspect})
  end

  def clear() do
    GenServer.cast(@name, {:clear})
  end

  def exist?(term) do
    GenServer.call(@name, {:exist?, term})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:write, term, value}, _from, terms) do
    new_item = {term, value}
    new_terms =  [new_item | terms]
    {:reply, "#{term} added", new_terms}
  end

  def handle_call({:read, term}, _from, terms) do
    msg = fetch_term_to_message(Keyword.fetch(terms, term))
    {:reply, msg, terms}
  end

  def handle_call({:inspect}, _from, terms) do
    IO.inspect(terms)
    {:reply, "List", terms}
  end

  def handle_call({:exist?, term}, _from, terms) do
    boolean = Keyword.has_key?(terms, term)
    {:reply, "#{term} in list? #{boolean}", terms}
  end

  def handle_cast({:delete, term}, terms) do
    new_terms = Keyword.delete(terms, term)
    {:noreply, new_terms}
  end

  def handle_cast({:clear}, _terms) do
    {:noreply, []}
  end

  defp fetch_term_to_message({:ok, term}) do
    "Term: #{term}"
  end

  defp fetch_term_to_message(:error) do
    "Error"
  end
end
