defmodule CrawlerManager.Subsupervisor do
  use DynamicSupervisor
  require Logger
  alias CrawlerManager.PageQueue, as: PageQueue
  alias CrawlerManager.PageGraph, as: PageGraph

  def start_link({queue_pid, graph_pid, num_urls}) do
    {:ok, _pid} =
      DynamicSupervisor.start_link(__MODULE__,
      {queue_pid, graph_pid, num_urls}, name: __MODULE__)
    Logger.info "Dynamic subsupervisor started! and my PID is: " <>
      Kernel.inspect(self())
    # REMOVED
    # # manage_queue(queue_pid, graph_pid)
    # Logger.info "Dynamic subsupervisor printing PageGraph!"
    # CrawlerManager.PageGraph.print_graph_to_file(graph_pid, "output_graph.txt")
  end

  def add_crawler(queue_pid, graph_pid) do
    require IEx
    IEx.pry
    if PageQueue.len(queue_pid) >
      DynamicSupervisor.count_children(__MODULE__).specs do
      response = case PageQueue.get_new_page(queue_pid) do
        url when is_binary(url) ->
          Logger.debug("Starting child on url: " <> url)
          {:ok, pid} = start_child(queue_pid, graph_pid, url)
        error ->
          Logger.error("Recieved something that is not a url!" <>
            Kernel.inspect(error))
          {:error, error}
      end
      response
    else
      {:ignore, "No urls to give new crawler"}
    end
  end

  def start_child(queue_pid, graph_pid, url) do
    child_spec = %{
      start: {
        CrawlerManager.Server,
        :start_link,
        [queue_pid, graph_pid, url]
      }
    }
    {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, child_spec)
    Logger.debug "Started child with child spec: " <>
      Kernel.inspect(child_spec) <> " at PID: " <> Kernel.inspect(pid)
    {:ok, pid}
  end

  def init(init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # def init({queue_pid, graph_pid, num_urls}) do
  #   Logger.info "I am the subsupervisor! and my PID is: " <> Kernel.inspect(self())
  #   child_processes =
  #     Enum.map(1..num_urls,
  #              fn _x ->
  #               worker(CrawlerManager.Server, [queue_pid, graph_pid]) end)
  #   Logger.info "Spawned children of subsupervisor! There are " <>
  #     Kernel.inspect(length(child_processes)) <> " child processes started!"
  #   supervise(child_processes, strategy: :one_for_one)
  # end
end
