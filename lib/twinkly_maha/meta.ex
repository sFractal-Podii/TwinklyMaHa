defmodule TwinklyMaha.Meta do
    @moduledoc """
    get metadata about app while running
    """
    @app :twinkly_maha
  
    @doc """
    get version of this app
    """
    def version do
      {:ok, vsn} = :application.get_key(@app, :vsn)
      vsn
    end
  end