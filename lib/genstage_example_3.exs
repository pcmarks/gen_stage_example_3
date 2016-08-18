alias Experimental.GenStage

defmodule GenStageExample3 do

  defmodule Splitter do
    @moduledoc """
    This GenStage example is meant to illustrate the splitting of an output flow of
    events - a list of integers - to more than one stage. This is accomplished by
    using the PartitionDispatcher dispatcher and a "splitter" function that shunts
    even integers to one partition and odd integers to another partition. For a more
    detailed explanation, please see this blog [post](www.elixirfbp.com)
    """
    use GenStage

    def init(_) do
      {:producer_consumer, %{},
        dispatcher: {GenStage.PartitionDispatcher,
                      partitions: 2,
                      hash: &split/2}}
    end

    @doc """
    The "hash function"
    """
    def split(event, no_of_partitions ) do
      {event, rem(event, no_of_partitions)}
    end

    @doc """
    Simply pass input events onto the partition dispatcher
    """
    def handle_events(events, _from, state) do
      {:noreply, events, state}
    end
  end

  defmodule Ticker do
    use GenStage
    def init(state) do
      {:consumer, state}
    end
    def handle_events(events, _from, {sleeping_time, name} = state) do
      IO.puts "Ticker(#{name}) events: #{inspect events, charlists: :as_lists}"
      Process.sleep(sleeping_time)
      {:noreply, [], state}
    end
  end

  {:ok, inport}    = GenStage.from_enumerable(1..10)
  {:ok, splitter}  = GenStage.start_link(Splitter, 0)
  {:ok, evens}     = GenStage.start_link(Ticker, {2_000, :evens})
  {:ok, odds}      = GenStage.start_link(Ticker, {2_000, :odds})

  GenStage.sync_subscribe(evens, to: splitter, partition: 0, max_demand: 1)
  GenStage.sync_subscribe(odds,  to: splitter, partition: 1, max_demand: 1)
  GenStage.sync_subscribe(splitter, to: inport, max_demand: 1)

  Process.sleep(:infinity)

end
