defmodule CrawlerManager.Supervisor do
  use Supervisor
  require Logger

  def start_link(urls) do
    if length(urls) == 1, do: urls = [urls]
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [urls])
    {queue, graph, subsupervisor} = start_workers(sup, urls)
    {queue, graph, subsupervisor}
  end

  def start_workers(sup, urls) do
    # Start the PageQueue
    {:ok, queue} =
      Supervisor.start_child(sup, worker(CrawlerManager.PageQueue, [urls]))
    # Start the PageGraph
    [head | _tail] = urls
    {:ok, graph} =
      Supervisor.start_child(sup, worker(CrawlerManager.PageGraph, [head]))
    # Start the subsupervisor to manage the crawlers
    args = {queue, graph, length(urls)}
    {:ok, subsupervisor} = Supervisor.start_child(sup,
      supervisor(CrawlerManager.Subsupervisor, [args]))
    {queue, graph, subsupervisor}
  end

  def init(_) do
    Logger.info "I am the supervisor! and my PID is: " <> Kernel.inspect(self())
    supervise([], strategy: :one_for_one)
  end
end
