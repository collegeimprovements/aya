ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Aya.Repo, :manual)

# Copy modules for Mimic mocking
Mimic.copy(Req)
