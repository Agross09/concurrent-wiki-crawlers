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

  def python_hello do
    python_pid = Helper.python_instance(to_char_list("lib/python_modules"))
    Helper.call_python(python_pid, :python_test, :print_hello, [])
    :python_hello
  end
end
