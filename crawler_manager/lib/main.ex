defmodule Main do
  require Logger

  def start(url) do
    time_to_sleep = 1_000
    num_crawlers = 1 # for now
    {queue_pid, graph_pid, subsupervisor_pid} =
      CrawlerManager.Supervisor.start_link([url], num_crawlers)
    Logger.debug("Sleeping for two minutes")
    Logger.info "Dynamic subsupervisor printing PageGraph!"
    CrawlerManager.PageGraph.print_graph_to_file(
      graph_pid,
      "output_graph.txt"
    )
  end
end
