-- get_current_session
local _get_current_session = ya.sync(function(state)
  local tabs = cx.tabs

  local session = {
    active_idx = tabs.idx,
    tabs = {},
  }

  for idx, tab in ipairs(tabs) do
    session.tabs[idx] = {
      cwd = tostring(tab.current.cwd):gsub("\\", "/"),
      sort = {
        by = tab.pref.sort_by,
        sensitive = tab.pref.sort_sensitive,
        reverse = tab.pref.sort_reverse,
        dir_first = tab.pref.sort_dir_first,
        translit = tab.pref.sort_translit,
      },
      linemode = tab.pref.linemode,
      show_hidden = tab.pref.show_hidden and "show" or "hide",
    }
  end

  return session
end)

-- _save_and_quit
local _save_and_quit = ya.sync(function(state)
  -- Mark that we're saving: `pub_to(0, ...)` broadcasts back to this same
  -- instance, and without this guard the restore handler would recreate
  -- every tab (duplicating the session) while the quit is still pending.
  state.saving = true

  local session = _get_current_session()
  -- state.event is nil when setup() was never called (e.g. YAZI_NO_SESSION=1
  -- in nvim file-manager sessions): skip publishing, still quit cleanly.
  if state.event then
    ps.pub_to(0, state.event, session)
    -- `ps.pub_to` queues the event and returns immediately; the DDS client
    -- flushes it to the daemon on a tokio worker. If we emit `quit` right
    -- away, the main thread drains the state file before the worker runs,
    -- and the session is silently lost (this used to be masked by the
    -- "unfinished tasks" popup delaying the quit). Block briefly so the
    -- worker can record the event in STATE before we quit.
    os.execute("sleep 0.1")
  end
  ya.emit("quit", {})
end)

-- restore_session
local _restore_session = ya.sync(function(state)
  session = state.session

  for idx, tab in ipairs(session.tabs) do
    if idx == 1 then
      ya.emit("cd", { tab.cwd })
    else
      ya.emit("tab_create", { tab.cwd })
    end
    ya.emit("sort", tab.sort)
    ya.emit("hidden", { tab.show_hidden })
  end

  ya.emit("tab_switch", { session.active_idx - 1 })
    
  state.restored = true
end)

return {
  setup = function(state, opts)
    state.restored = false
    state.event = "@autosession-event"

    ps.sub_remote(state.event, function(body)
      if not state.restored and not state.saving then
        state.session = body
        _restore_session()
      end
    end)

    -- Save the session on key-triggered quit (q). A ps.sub handler is NOT a
    -- scheduler task, so re-emitting quit from here avoids yazi's "unfinished
    -- tasks, quit anyway?" popup that appeared when the plugin command task
    -- emitted quit while still running.
    ps.sub("key-quit", function()
      _save_and_quit()
    end)
  end,

  entry = function(_, job)
    local action = job.args[1]
    if action == "save-and-quit" then
      _save_and_quit()
    end
  end,
}
