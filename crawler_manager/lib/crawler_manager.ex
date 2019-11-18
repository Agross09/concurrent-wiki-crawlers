defmodule CrawlerManager do
  @moduledoc """
  Documentation for CrawlerManager.
  """
  alias ElixirPython.Helper


  @doc """
  Hello world.

  ## Examples

      iex> CrawlerManager.hello()
      :world

  """
  def hello do
    :world
  end

  def test_python_hello do
    python_pid = Helper.python_instance(to_charlist("lib/python_modules"))
    url_to_python = "racecar.com"
    url_from_python = Helper.call_python(python_pid, :python_test, :scrape, [url_to_python])
    # IO.puts(url_to_python)
    # IO.puts(url_from_python)
    :test_python_hello
  end

  def test_python_dict do
    ppip = Helper.python_instance(to_charlist("lib/python_modules"))
    url = "wikipedia.com"
    json_dict_string = Helper.call_python(ppip, :python_test, :scrape_dict, [url])
    IO.puts(json_dict_string)
    url_map = Poison.decode!(json_dict_string)
    IO.inspect(url_map)
    :test_python_dict
  end

  def to_url_map(json_string) do
    {:ok, map} = Poison.decode!(json_string)
    map
  end

end
