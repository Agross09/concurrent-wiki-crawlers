defmodule PageQueue do
    def get_new_page(pageQueue) do
        List.pop_at(pageQueue, 0)
    end
    def put_page(new_page, pageQueue) do
        if !PageQueue.is_duplicate(new_page) do
            List.insert_at(pageQueue, -1, new_page)
        end
    end
    # Currently a dummy function... will interact with adjacency matrix
    def is_duplicate(page) do
        false
    end
end
