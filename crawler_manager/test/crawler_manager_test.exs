defmodule CrawlerManagerTest do
  use ExUnit.Case
  doctest CrawlerManager

  test "greets the world" do
    assert CrawlerManager.hello() == :world
  end

  test "greets the world with python" do
    assert CrawlerManager.test_python_hello() == :test_python_hello
  end

  test "testing map translation between python and elixir using json" do
    assert CrawlerManager.test_python_dict() == :test_python_dict
  end
end
