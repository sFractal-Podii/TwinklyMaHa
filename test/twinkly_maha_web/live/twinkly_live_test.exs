defmodule TwinklyMahaWeb.TwinklyLiveTest do
  use TwinklyMahaWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected render", %{conn: conn} do
    {:ok, _page_live, _disconnected_html} = live(conn, "/twinkly")
  end

  test "Led starts in off state", %{conn: conn} do
    {:ok, page_live, _disconnected_html} = live(conn, "/twinkly")
    assert render(page_live) =~ "class=\"led led-off\""
  end

  test "toggle led on and off", %{conn: conn} do
    {:ok, view, _disconnected_html} = live(conn, "/twinkly")
    content = view |> element(".button") |> render_click()
    assert content =~ "<div class=\"led led-on\""
    content = view |> element(".button") |> render_click()
    assert content =~ "<div class=\"led led-off\""
  end

  test "toggle words on the button", %{conn: conn} do
    {:ok, view, _disconnected_html} = live(conn, "/twinkly")
    assert render(view) =~ "Turn LED ON\n"
    content = view |> element(".button") |> render_click()
    assert content =~ "Turn LED OFF\n"
    content = view |> element(".button") |> render_click()
    assert content =~ "Turn LED ON\n"
  end
end
