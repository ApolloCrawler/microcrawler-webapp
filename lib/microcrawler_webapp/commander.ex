defmodule MicrocrawlerWebapp.Commander do
  @moduledoc """
  Command Line Wrapper
  """

  def cmd(cmd, args) do
    System.cmd(cmd, args)
  end
end
