defmodule CrawlerManager.Supervisor do
  use Supervisor

  def start_link(urls) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [urls])
    start_workers(sup, urls)
    result
  end

  def start_workers(sup, urls) do
    # Start the PageQueue
    {:ok, queue} =
      Supervisor.start_child(sup, worker(CrawlerManager.PageQueue, [urls]))
    # Start the PageGraph
    {:ok, graph} =
      Supervisor.start_child(sup, worker(CrawlerManager.PageGraph, [urls]))
    # Start the subsupervisor to manage the crawlers
    args = {queue, graph, length(urls)}
    Supervisor.start_child(sup,
      supervisor(CrawlerManager.Subsupervisor, [args]))
  end

  def init(_) do
    supervise([], strategy: :one_for_one)
  end
end
