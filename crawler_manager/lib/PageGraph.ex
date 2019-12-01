defmodule CrawlerManager.PageGraph do
  use GenServer

  @moduledoc """
  Documentation for CrawlerManager.PageGraph

  Each instance of this module is a GenServer that facilitates a graph.
  This graph is the state of the subgraph of Wikipedia pages received from the
  python crawlers.
  """

  @moduledoc """
  External API for CrawlerManager.PageGraph
  """

  @doc """
  Function: start_link/1

  Initialization of a pageGraph process and its state.

  Given a page (url string), start a GenServer process and map of lists for
  each page and its neighbors (list of url strings).
  """
  def start_link(originPage) when is_string(originPage) do
    pageGraph = %{originPage => []}
    {:ok, _pid} = GenServer.start_link(__MODULE__, pageGraph)
  end

  @doc """
  Function: put_edge/3

  Function to add an edge between existing page and neighbor page.

  Given a pid of pageGraph, url string of existing page, and url string of
  neighboring page, CAST a change of state for the pageGraph by adding an
  edge between the two given pages.
  """
  def put_edge(graph_pid, originPage, nextPage) do
    GenServer.cast(graph_pid, {:put_edge, originPage, nextPage})
  end

  @doc """
  Function: is_duplicate/2

  Function to check if page already exists in the pageGraph.

  Given pid of pageGraph and a url string of a page, CALL a query to check
  if the given page is an exisiting node in pageGraph. Function replies
  with a boolean True or False and does not change the pageGraph state.
  """
  def is_duplicate(graph_pid, page) do
    GenServer.call(graph_pid, {:is_duplicate, page})
  end


  @doc """
  Function: add_subgraph/2

  Function to add urls explored by the crawler and their neighbors to the
  pageGraph graph.

  Given a pid of pageGraph and a map of url strings of explored pages as keys
  and their neighboring url strings as values, use put_edge/3 to add edges
  between the key url strings and their neighbors and add this subgraph
  to the graph pageGraph.
  """
  def add_subgraph(graph_pid, urls_subgraph) when is_map(urls_subgraph) do
    Enum.map(
      urls_subgraph,
      fn {base_url, neighbors} ->
        Enum.map(
          neighbors,
          fn url ->
            put_edge(graph_pid, base_url, url)
          end
        )
      end
    )
  end
  #############################################################################
  # GenServer Implementation

  # GenServer handle_cast for putting an edge between two pages in the graph.
  def handle_cast({:put_edge, originPage, nextPage}, pageGraph) do
    updatedGraph = put_edge_aux(originPage, nextPage, pageGraph)
    {:noreply, updatedGraph}
  end

  # GenServer handle_call for checking if a page exists
  # as a key in the pageGraph.
  def handle_call({:is_duplicate, page}, _from, pageGraph) do
    {:reply, is_duplicate_aux(page, pageGraph), pageGraph}
  end

  #############################################################################
  # Helper functions

  # FUNCTION: put_edge_aux/3
  # Facilitates the putting of a edge between two pages in pageGraph.
  # Given a url string for a page, a url string for its neighbor,
  # and the pageGraph map, check to see if the originPage is in the pageGraph
  # map. If so, change the list of neighbors associated with the originPage in
  # the pageGraph map, else add originPage to the pageGraph map and add the
  # nextPage url as the first element in its list of neighbors.
  defp put_edge_aux(originPage, nextPage, pageGraph) do
    if Enum.member?(Map.keys(pageGraph), originPage) do
        neighbors = Map.fetch!(pageGraph, originPage)
        new_neighbors = [nextPage | neighbors]
        Map.replace!(pageGraph, originPage, new_neighbors)
    else
        Map.put(pageGraph, originPage, [nextPage])
    end
  end

  # FUNCTION: is_duplicate_aux/2
  # Checks if a given page (url string) is a key in the pageGraph map.
  defp is_duplicate_aux(page, pageGraph) do
    Enum.member?(Map.keys(pageGraph), page)
  end
end
