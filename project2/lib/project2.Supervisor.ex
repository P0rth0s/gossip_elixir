defmodule Project2.Supervisor do
    use Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, [])
    end

    def init(_) do
        children = [
            {DynamicSupervisor, strategy: :one_for_one, name: Project2.DynamicSupervisor}
        ]

        Supervisor.init(children, strategy: :one_for_one)
    end
end
