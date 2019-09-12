defmodule Project2 do
  use Application

  def start(_type, _args) do
    Project2.Supervisor.start_link
  end
end
