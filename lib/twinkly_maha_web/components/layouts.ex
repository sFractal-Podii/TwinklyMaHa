defmodule TwinklyMahaWeb.Layouts do
  use TwinklyMahaWeb, :html

  embed_templates "templates/layout/*", root: ".."
end
