defmodule CrawlerManager.Server do
  alias ElixirPython.Helper
  alias CrawlerManager.PageQueue, as: PageQueue
  alias CrawlerManager.PageGraph, as: PageGraph
  use GenServer
  require Logger
  @moduledoc """
  Documentation for CrawlerManager.Server

  Each Instance of this module is a manager who runs a python web crawler
  """

  defmodule State do
    defstruct queue_pid: nil, graph_pid: nil, url: ""
  end

  ### External API

  def start_link(queue_pid, graph_pid, url) do
    {:ok, pid} =
      GenServer.start_link(
        __MODULE__,
        {queue_pid, graph_pid, url},
        name: __MODULE__
      )
    # run(url, 0)
    {:ok, pid}
  end

  def get_queue_pid do
    GenServer.call(__MODULE__, :get_queue_pid)
  end

  def get_graph_pid do
    GenServer.call(__MODULE__, :get_graph_pid)
  end

  def get_current_url do
    GenServer.call(__MODULE__, :get_current_url)
  end

  def set_new_url(url) do
    GenServer.cast(__MODULE__, {:new_url, url})
    url
  end

  def run(url, times_run) do
    if times_run < 11 do
      GenServer.call(__MODULE__, {:run, url})
      |> set_new_url()
      |> run(times_run + 1)
    end
  end

  def crawl do
    url_map = GenServer.call(__MODULE__, :crawl)
    Logger.info Kernel.inspect(url_map)
    url_map
  end

  ### GenServer implementation

  def init({queue_pid, graph_pid, url})do
    Logger.info "I am a server and my PID is: " <> Kernel.inspect(self())
    {:ok, %State{queue_pid: queue_pid, graph_pid: graph_pid, url: url}}
  end

  # call to run crawler and get a map of its
  # def handle_call(:crawl, _from, state) do
  #   urls_and_neighbors = run_python_crawler(state.url)
  #   {:reply, urls_and_neighbors, state} #change current url here?
  # end

  def handle_call(:get_queue_pid, _from, state) do
    {:reply, state.queue_pid, state}
  end

  def handle_call(:get_graph_pid, _from, state) do
    {:reply, state.graph_pid, state}
  end

  def handle_call(:get_current_url, _from, state) do
    {:reply, state.url, state}
  end

  # cast to change the current url to explore from
  def handle_cast({:new_url, url}, state) do
    {:noreply, %{state | url: url}}
  end

  def handle_call({:run, url}, _from, state) do
    new_url = run_aux(url, state)
    {:reply, new_url, state}
  end



  ### Internal functions ######################################################

  defp run_aux(url, state) do
    if not is_binary(url) do
      Logger.warn "Crawler " <> Kernel.inspect(self()) <> " did not get a url!"
      Process.exit(self(), :normal)
    end
    Logger.info "Crawler running on " <> url

    # 1) CALL :crawl to get urls and their adjacent pages map
    urls_map = run_python_crawler(url)
    # 2 & 3) CAST PageGraph process the map of the urls and their adjacent urls
    #        for processing. CAST PageQueue process to update queue and
    #        add unexplored pages to it.
    PageGraph.add_subgraph(state.graph_pid, urls_map)
    |> Enum.map(fn url ->
                  PageQueue.put_page(url, state.queue_pid, state.graph_pid)
                end)

    # 5) CALL new URL from PageQueue (pop url off queue and thus change queue state)
    new_url = PageQueue.get_new_page(state.queue_pid)
    new_url
  end

  defp run_python_crawler(url) do
    ppid = Helper.python_instance(to_charlist("lib/python_modules")) # CHANGE TO Application.get_env(:crawler_manager, :python_path)
    json_dict_string = Helper.call_python(ppid, :"regular-spider", :crawl, [url])
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
