defmodule PageGraph do
    def put_edge(originPage, nextPage, pageGraph) do
        if Enum.member?(Map.keys(pageGraph), originPage) do
            neighbors = Map.fetch!(pageGraph, originPage)
            new_neighbors = [nextPage | neighbors]
            Map.replace!(pageGraph, originPage, new_neighbors)
        else
            Map.put(pageGraph, originPage, [nextPage])
        end
    end
    def is_duplicate(pageGraph, page) do
        Enum.member?(Map.keys(pageGraph), page)
    end
end
