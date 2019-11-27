defmodule PageQueue do
    alias PageGraph
    def get_new_page(pageQueue) do
        List.pop_at(pageQueue, 0)
    end
    def put_page(new_page, pageQueue, pageGraph) do
        if !PageGraph.is_duplicate(pageGraph, new_page) do
            List.insert_at(pageQueue, -1, new_page)
        end
    end
end
