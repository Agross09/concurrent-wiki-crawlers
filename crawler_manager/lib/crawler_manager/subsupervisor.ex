defmodule CrawlerManager.Subsupervisor do
  use Supervisor

  def start_link({queue_pid, graph_pid, num_urls}) do
    {:ok, _pid} =
      Supervisor.start_link(__MODULE__, {queue_pid, graph_pid, num_urls})
  end

  def init({queue_pid, graph_pid, num_urls}) do
    child_processes =
      Eunm.map(1..num_urls,
               fn worker(CrawlerManager.Server, [queue_pid, graph_pid]) end)
    supervise(child_processes, strategy: :one_for_one)
  end
end
