defmodule CrawlerManager.Supervisor do
  use Supervisor
  require Logger

  def start_link(urls, num_crawl) do
    if length(urls) == 1, do: urls = [urls]
    {:ok, sup} = Supervisor.start_link(__MODULE__, [urls, num_crawl])
    {queue, graph, subsupervisor} = start_workers(sup, urls, num_crawl)
    {queue, graph, subsupervisor}
  end

  def start_workers(sup, urls, num_crawl) do
    # Start the PageQueue
    {:ok, queue} =
      Supervisor.start_child(sup, worker(CrawlerManager.PageQueue, [urls]))
    # Start the PageGraph
    [head | _tail] = urls
    {:ok, graph} =
      Supervisor.start_child(sup, worker(CrawlerManager.PageGraph, [head]))
    # Start the subsupervisor to manage the crawlers
    args = {queue, graph, num_crawl}
    {:ok, subsupervisor} = Supervisor.start_child(sup,
      supervisor(CrawlerManager.Subsupervisor, [args]))
    Logger.info "All workers started under Supervisor: " <>
      Kernel.inspect({queue, graph, subsupervisor})
    {queue, graph, subsupervisor}
  end

  def init(_) do
    Logger.info "I am the supervisor! and my PID is: " <> Kernel.inspect(self())
    supervise([], strategy: :one_for_one)
  end
end
