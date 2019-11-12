defmodule CrawlerManagerTest do
  use ExUnit.Case
  doctest CrawlerManager

  test "greets the world" do
    assert CrawlerManager.hello() == :world
  end

  test "greets the world with python" do
    assert CrawlerManager.python_hello() == :python_hello
  end
end
