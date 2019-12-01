defmodule CrawlerManager.Server do
  @moduledoc """
  Documentation for CrawlerManager.Server

  Each Instance of this module is a manager who runs a python web crawler
  """
  alias ElixirPython.Helper
  use GenServer

  defmodule State do
    defstruct queue_pid: nil, graph_pid: nil, url: ""
  end

  ### External API

  def start_link({queue_pid, graph_pid}) do
    {:ok, _pid} =
      GenServer.start_link(__MODULE__, {queue_pid, graph_pid}, name: __MODULE__)
    run()
  end

  def run do
    # 1) CALL new URL from PageQueue (pop url off queue and thus change queue state)
    url = CrawlerManager.PageQueue.get_new_page(state.queue_pid)
    # 2) CAST new URL to Server (simple state change)
    GenServer.cast(__MODULE__, {:new_url, url})
    # 3) CALL :crawl to get urls and their adjacent pages map
    urls_and_neighbors = GenServer.call(__MODULE__, :crawl)
    # 4) CAST PageGraph process the map of the urls and their adjacent urls
    #    for processing.
    {:ok, _values} =
      CrawlerManager.PageGraph.add_subgraph(state.graph_pid, urls_and_neighbors)
    run() #no stopping condition?
  end


  ### GenServer implementation

  def init({queue_pid, graph_pid})do
    # Request url from PageQueue Process
    curr_url = CrawlerManager.PageQueue.get_new_page(queue_pid)
    {:ok, %State{queue_pid: queue_pid, graph_pid: graph_pid, url: curr_url}}
  end

  # call to run crawler and get a map of its
  def handle_call(:crawl, _from, state) do
    urls_and_neighbors = run_python_crawler(state.url)
    {:reply, urls_and_neighbors, state} #change current url here?
  end

  # cast to change the current url to explore from
  def handle_cast({:new_url, url}, state) do
    {:noreply, %{state | url: url}}
  end




  ### Internal functions ######################################################

  defp run_python_crawler(url) do
    ppid = Helper.python_instance(to_charlist("lib/python_modules")) # CHANGE TO Application.get_env(:crawler_manager, :python_path)
    json_dict_string = Helper.call_python(ppid, :python_test, :scrape_dict, [url])
    #IO.puts(json_dict_string)
    url_map = Poison.decode!(json_dict_string)
    url_map
  end

  # def test_python_hello do
  #   python_pid = Helper.python_instance(to_charlist("lib/python_modules"))
  #   url_to_python = "racecar.com"
  #   url_from_python = Helper.call_python(python_pid, :python_test, :scrape, [url_to_python])
  #   # IO.puts(url_to_python)
  #   # IO.puts(url_from_python)
  #   :test_python_hello
  # end

  # def test_python_dict do
  #   ppid = Helper.python_instance(to_charlist("lib/python_modules"))
  #   url = "wikipedia.com"
  #   json_dict_string = Helper.call_python(ppid, :python_test, :scrape_dict, [url])
  #   IO.puts(json_dict_string)
  #   url_map = Poison.decode!(json_dict_string)
  #   IO.inspect(url_map)
  #   :test_python_dict
  # end

  # def to_url_map(json_string) do
  #   {:ok, map} = Poison.decode!(json_string)
  #   map
  # end

end
