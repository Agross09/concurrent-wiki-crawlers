defmodule Main do
  require Logger

  def start(num_crawlers) do
    urls = [
      "https://en.wikipedia.org",
      "https://en.wikipedia.org/wiki/Ontario",
      "https://en.wikipedia.org/wiki/Korean_idol"
    ]
    # num_crawlers = 5
    {queue_pid, graph_pid, subsupervisor_pid} =
      CrawlerManager.Supervisor.start_link(urls, num_crawlers)
    print? = Task.async(Process.sleep(120_000))
    run(queue_pid, graph_pid, subsupervisor_pid, run?)
    Task.await(print?, :infinity)
    if print? == :print do
      Logger.info "Dynamic subsupervisor printing PageGraph!"
      CrawlerManager.PageGraph.print_graph_to_file(
        graph_pid,
        "output_graph.txt"
      )
    end
  end
end
