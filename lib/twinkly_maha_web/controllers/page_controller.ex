defmodule TwinklyMahaWeb.PageController do
  use TwinklyMahaWeb, :controller

  def sbom(conn, _params) do
    render(conn, "sbom.html")
  end
end
