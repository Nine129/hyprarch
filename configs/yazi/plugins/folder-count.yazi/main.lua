local counts = {}

local set_count = ya.sync(function(state, path, count)
    counts[path] = count
    state.changed = true
    ui.render()
end)

local function setup(_, opts)
    opts = opts or {}
    function Linemode:folder_count()
        if not self._file.in_current then
            return ""
        end
        if not self._file.cha.is_dir then
            local size = self._file:size()
            return size and ya.readable_size(size) or "-"
        end
        local count = counts[tostring(self._file.url)]
        return count == nil and "…" or tostring(count)
    end
end

local function fetch(_, job)
    for _, file in ipairs(job.files) do
        if file.cha.is_dir then
            local path = tostring(file.url)
            if counts[path] == nil then
                local output, err = Command("find")
                    :arg({ path, "-mindepth", "1", "-maxdepth", "1", "-not", "-name", ".*" })
                    :output()
                if not output then
                    return true, Err("Cannot count directory %s: %s", path, err)
                end

                local count = 0
                for _ in output.stdout:gmatch("[^\r\n]+") do
                    count = count + 1
                end
                set_count(path, count)
            end
        end
    end
    return false
end

return { setup = setup, fetch = fetch }
