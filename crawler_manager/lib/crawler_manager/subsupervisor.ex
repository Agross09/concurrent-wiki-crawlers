defmodule CrawlerManager.Subsupervisor do
  use Supervisor
  require Logger
  alias CrawlerManager.PageQueue, as: PageQueue
  alias CrawlerManager.PageGraph, as: PageGraph

  def start_link({queue_pid, graph_pid, num_urls}) do
    {:ok, _pid} =
      Supervisor.start_link(
        __MODULE__,
        {queue_pid, graph_pid, num_urls},
        name: __MODULE__
      )
    Logger.info "Subsupervisor started! and my PID is: " <>
      Kernel.inspect(self())
    {:ok, _pid}
  end

  def init({queue_pid, graph_pid, num_urls}) do
    Logger.info "I am the subsupervisor! and my PID is: " <> Kernel.inspect(self())
    child_processes =
      Enum.map(1..num_urls,
               fn x ->
                worker(
                  CrawlerManager.Server,
                  [queue_pid, graph_pid, ""],
                  id: x
                )
                end)
    Logger.info "Spawned children of subsupervisor! There are " <>
      Kernel.inspect(length(child_processes)) <> " child processes started!"
    supervise(child_processes, strategy: :one_for_one)
  end
end
