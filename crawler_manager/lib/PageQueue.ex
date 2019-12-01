defmodule CrawlerManager.PageQueue do
  use GenServer

  @moduledoc """
  Documentation for CrawlerManager.PageQueue

  Each instance of this module is a GenServer that facilitates a queue.
  This queue stores the pages that the crawlers will eventually explore.
  """

  @moduledoc """
  External API for CrawlerManager.PageQueue
  """

  @doc """
  Function: start_link/1

  Initialization of a pageQueue process and its state.

  Given a list of pages (url strings), start a GenServer process
  to hold the state of a queue of pages to explore.
  """
  def start_link(urls) when is_list(urls) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, urls)
  end

  @doc """
  Function: get_new_page/1

  Function to dequeue a page from queue pageQueue.

  Given a pid of pageQueue, CALL a change of state for the pageQueue
  by dequeuing a page from pageQueue queue and return the page.
  """
  def get_new_page(queue_pid) do
    GenServer.call(queue_pid, :get_new_page)
  end

  @doc """
  Function: put_page/3

  Function to enqueue a page into queue pageQueue.

  Given a new page (url string), a pid of a pageQueue process, and
  a pid of a pageGraph process, CAST a change of state to the pageQueue
  to add the given page to the queue of pages to explore. Function does
  not add page to pageQueue queue if the given page exists as a key in
  the graph pageGraph.
  """
  def put_page(new_page, queue_pid, graph_pid) do
    GenServer.cast(queue_pid, {:put_page, new_page, graph_pid})
  end

  #############################################################################
  # GenServer Implementation

  # GenServer handle_call for getting a new page from the queue pageQueue.
  def handle_call(:get_new_page, _from, pageQueue) do
    {page, updatedQueue} = get_new_page_aux(pageQueue)
    {:reply, page, updatedQueue}
  end

  # GenServer handle_cast for putting a new page into the queue pageQueue.
  # Checks to see if the page is unexplored (not a key in graph pageGraph).
  def handle_cast({:put_page, new_page, graph_pid}, pageQueue) do
    updatedQueue = put_page_aux(new_page, graph_pid, pageQueue)
    {:noreply, updatedQueue}
  end


  #############################################################################
  # Helper functions

  # FUNCTION: get_new_page_aux/1
  # Dequeues page from queue page Queue.
  # Returns tuple {page, pageQueue - page}
  defp get_new_page_aux(pageQueue) do
    List.pop_at(pageQueue, 0)
  end

  # FUNCTION: put_page_aux/3
  # Checks if page exists in graph pageGraph. If so, function returns
  # the original queue, otherwise, it enqueues the new page to the end of the
  # queue.
  # Returns the updated pageQueue.
  defp put_page_aux(new_page, graph_pid, pageQueue) do
    case CrawlerManager.PageGraph.is_duplicate(graph_pid, new_page) do
      true -> pageQueue
      false -> List.insert_at(pageQueue, -1, new_page)
    end
  end
end
