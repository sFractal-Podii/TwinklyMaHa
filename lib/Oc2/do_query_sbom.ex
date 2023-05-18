defmodule Oc2.DoQuerySbom do
  @moduledoc """
  Documentation for `Query SBOM` contains helper functions for
  blah blah
  """

  require Logger

  @doc """
  return_sbom returns sbom
     (or error)
  """
  def return_sbom(command) do
    ## only choice is cyclonedx so validate it
    {ok?, answer} =
      command.target_specifier
      |> sbom_map_chk
      |> sbom_type_chk
      |> ts_is_list
      |> cdx_chk

    case ok? do
      false ->
        Oc2.Command.return_error(answer)

      true ->
        %Oc2.Command{command | response: cyclonedx()}
    end
  end

  defp sbom_map_chk(target_specifier) do
    case is_map(target_specifier) do
      true ->
        {true, target_specifier}

      false ->
        Logger.debug("sbom_map_chk: #{inspect(target_specifier)}")
        {false, "invalid target specifier"}
    end
  end

  defp sbom_type_chk({false, error}) do
    ## upstream error
    {false, error}
  end

  defp sbom_type_chk({true, target_specifier}) do
    case Map.has_key?(target_specifier, "type") do
      true ->
        {true, target_specifier}

      false ->
        Logger.debug("sbom_type_chk: #{inspect(target_specifier)}")
        {false, "invalid target specifier"}
    end
  end

  defp ts_is_list({false, error}) do
    ## upstream error
    {false, error}
  end

  defp ts_is_list({true, target_specifier}) do
    case is_list(target_specifier[:type]) do
      true ->
        {true, target_specifier}

      false ->
        Logger.debug("ts_is_list: #{inspect(target_specifier)}")
        {false, "invalid target specifier"}
    end
  end

  defp cdx_chk({false, error}) do
    ## upstream error
    {false, error}
  end

  defp cdx_chk({true, target_specifier}) do
    case Enum.member?(target_specifier[:type], "cyclonedx") do
      true ->
        {true, "cyclonedx"}

      false ->
        Logger.debug("cdx_chk: #{inspect(target_specifier)}")
        {false, "invalid target specifier"}
    end
  end

  defp cyclonedx do
    ## return sbom in cyclonedx format
    ## build result starting innermost at binary
    cyclonedx_bin =
      "PD94bWwgdmVyc2lvbj0nMS4wJz8+PGJvbSBzZXJpYWxOdW1iZXI9JzllMjUzZjkyLTRlMWMtNDk3ZS04Zjg3LTUwNzMwZDI0ZjE4YScgeG1sbnM9J2h0dHA6Ly9jeWNsb25lZHgub3JnL3NjaGVtYS9ib20vMS4xJz48Y29tcG9uZW50cz48Y29tcG9uZW50IHR5cGU9J2xpYnJhcnknPjxkZXNjcmlwdGlvbj5OZXJ2ZXMgU3lzdGVtIEJSIC0gQnVpbGRyb290IGJhc2VkIGJ1aWxkIHBsYXRmb3JtIGZvciBOZXJ2ZXMgU3lzdGVtczwvZGVzY3JpcHRpb24+PGhhc2hlcz48aGFzaCBhbGc9J1NIQS0yNTYnPmUzZmRhNmJjNDlmOGUzNjYyZDM3MzU1YWFkODhjMDgzOTI5NjU5N2MwYjZmNjY1M2QyMTk2N2RiMTg5MGIwMzg8L2hhc2g+PC9oYXNoZXM+PGxpY2Vuc2VzPjxsaWNlbnNlPjxpZD5BcGFjaGUtMi4wPC9pZD48L2xpY2Vuc2U+PGxpY2Vuc2U+PG5hbWU+R1BMdjI8L25hbWU+PC9saWNlbnNlPjwvbGljZW5zZXM+PG5hbWU+bmVydmVzX3N5c3RlbV9icjwvbmFtZT48cHVybD5wa2c6aGV4L25lcnZlc19zeXN0ZW1fYnJAMS45LjU8L3B1cmw+PHZlcnNpb24+MS45LjU8L3ZlcnNpb24+PC9jb21wb25lbnQ+PGNvbXBvbmVudCB0eXBlPSdsaWJyYXJ5Jz48ZGVzY3JpcHRpb24+TmVydmVzIC0gQ3JlYXRlIGZpcm13YXJlIGZvciBlbWJlZGRlZCBkZXZpY2VzIGxpa2UgUmFzcGJlcnJ5IFBpLCBCZWFnbGVCb25lIEJsYWNrLCBhbmQgbW9yZTwvZGVzY3JpcHRpb24+PGhhc2hlcz48aGFzaCBhbGc9J1NIQS0yNTYnPjA3MDc5MzQyZGIzYTAzZDE5Njk0MTE4YTkzZjIyMDM1OWZiZDk0YjZlMTc0Yjk4ZDFlYTI3MDlkYjllODFkYTk8L2hhc2g+PC9oYXNoZXM+PGxpY2Vuc2VzPjxsaWNlbnNlPjxpZD5BcGFjaGUtMi4wPC9pZD48L2xpY2Vuc2U+PC9saWNlbnNlcz48bmFtZT5uZXJ2ZXM8L25hbWU+PHB1cmw+cGtnOmhleC9uZXJ2ZXNAMS41LjE8L3B1cmw+PHZlcnNpb24+MS41LjE8L3ZlcnNpb24+PC9jb21wb25lbnQ+PGNvbXBvbmVudCB0eXBlPSdsaWJyYXJ5Jz48ZGVzY3JpcHRpb24+U29ja2V0IGhhbmRsaW5nIGxpYnJhcnkgZm9yIEVsaXhpcjwvZGVzY3JpcHRpb24+PGhhc2hlcz48aGFzaCBhbGc9J1NIQS0yNTYnPjk4YTJhYjIwY2UxN2Y5NWZiNTEyYzVjYWRkZGJhMzJiNTcyNzNlMGQyZGJhMmQyZTVmOTc2YzU5NjlkMGM2MzI8L2hhc2g+PC9oYXNoZXM+PGxpY2Vuc2VzPjxsaWNlbnNlPjxpZD5XVEZQTDwvaWQ+PC9saWNlbnNlPjwvbGljZW5zZXM+PG5hbWU+c29ja2V0PC9uYW1lPjxwdXJsPnBrZzpoZXgvc29ja2V0QDAuMy4xMzwvcHVybD48dmVyc2lvbj4wLjMuMTM8L3ZlcnNpb24+PC9jb21wb25lbnQ+PGNvbXBvbmVudCB0eXBlPSdsaWJyYXJ5Jz48ZGVzY3JpcHRpb24+UmVhZCBhbmQgd3JpdGUgdG8gVS1Cb290IGVudmlyb25tZW50IGJsb2NrczwvZGVzY3JpcHRpb24+PGhhc2hlcz48aGFzaCBhbGc9J1NIQS0yNTYnPmIwMWUzZWMwOTczZTk5NDczMjM0ZjI3ODM5ZTI5ZTYzYjViODFlYmE2YTEzNmExOGE3OGQwNDlkNDgxM2Q2YzU8L2hhc2g+PC9oYXNoZXM+PGxpY2Vuc2VzPjxsaWNlbnNlPjxpZD5BcGFjaGUtMi4wPC9pZD48L2xpY2Vuc2U+PC9saWNlbnNlcz48bmFtZT51Ym9vdF9lbnY8L25hbWU+PHB1cmw+cGtnOmhleC91Ym9vdF9lbnZAMC4xLjE8L3B1cmw+PHZlcnNpb24+MC4xLjE8L3ZlcnNpb24+PC9jb21wb25lbnQ+PGNvbXBvbmVudCB0eXBlPSdsaWJyYXJ5Jz48ZGVzY3JpcHRpb24+TmVydmVzIFRvb2xjaGFpbiBDVE5HIC0gVG9vbGNoYWluIFBsYXRmb3JtPC9kZXNjcmlwdGlvbj48aGFzaGVzPjxoYXNoIGFsZz0nU0hBLTI1Nic+NDUyZjg1ODljMWE1OGFjNzg3NDc3Y2FhYjIwYThjZmM2NjcxZTM0NTgzN2NjYzE5YmVlZmU0OWFlMzViYTk4MzwvaGFzaD48L2hhc2hlcz48bGljZW5zZXM+PGxpY2Vuc2U+PGlkPkFwYWNoZS0yLjA8L2lkPjwvbGljZW5zZT48L2xpY2Vuc2VzPjxuYW1lPm5lcnZlc190b29sY2hhaW5fY3RuZzwvbmFtZT48cHVybD5wa2c6aGV4L25lcnZlc190b29sY2hhaW5fY3RuZ0AxLjYuMDwvcHVybD48dmVyc2lvbj4xLjYuMDwvdmVyc2lvbj48L2NvbXBvbmVudD48Y29tcG9uZW50IHR5cGU9J2xpYnJhcnknPjxkZXNjcmlwdGlvbj5BIHJpbmcgYnVmZmVyIGJhY2tlbmQgZm9yIEVsaXhpciBMb2dnZXIgd2l0aCBJTyBzdHJlYW1pbmcuPC9kZXNjcmlwdGlvbj48aGFzaGVzPjxoYXNoIGFsZz0nU0hBLTI1Nic+YjFiYWRkYzI2OTA5OWIyYWZlMmVhM2E4N2I4ZTJiNzFlNTczMzFjMDAwMDAzOGFlNTUwOTAwNjhhYWM2NzlkYjwvaGFzaD48L2hhc2hlcz48bGljZW5zZXM+PGxpY2Vuc2U+PGlkPkFwYWNoZS0yLjA8L2lkPjwvbGljZW5zZT48L2xpY2Vuc2VzPjxuYW1lPnJpbmdfbG9nZ2VyPC9uYW1lPjxwdXJsPnBrZzpoZXgvcmluZ19sb2dnZXJAMC44LjA8L3B1cmw+PHZlcnNpb24+MC44LjA8L3ZlcnNpb24+PC9jb21wb25lbnQ+PGNvbXBvbmVudCB0eXBlPSdsaWJyYXJ5Jz48ZGVzY3JpcHRpb24+TmVydmVzIFN5c3RlbSBMaW50ZXIgLSBMaW50IE5lcnZlcyBTeXN0ZW0gRGVmY29uZmlncy48L2Rlc2NyaXB0aW9uPjxoYXNoZXM+PGhhc2ggYWxnPSdTSEEtMjU2Jz44NGUwZjYzYzhhYzE5NmIxNmI3NzYwOGJiZTdkZjY2ZGNmMzUyODQ1YzRlNGZiMzk0YmZmZDJiNTcyMDI1NDEzPC9oYXNoPjwvaGFzaGVzPjxsaWNlbnNlcz48bGljZW5zZT48aWQ+QXBhY2hlLTIuMDwvaWQ+PC9saWNlbnNlPjwvbGljZW5zZXM+PG5hbWU+bmVydmVzX3N5c3RlbV9saW50ZXI8L25hbWU+PHB1cmw+cGtnOmhleC9uZXJ2ZXNfc3lzdGVtX2xpbnRlckAwLjMuMDwvcHVybD48dmVyc2lvbj4wLjMuMDwvdmVyc2lvbj48L2NvbXBvbmVudD48Y29tcG9uZW50IHR5cGU9J2xpYnJhcnknPjxkZXNjcmlwdGlvbj5ETlMgbGlicmFyeSBmb3IgRWxpeGlyIHVzaW5nIGBpbmV0X2Ruc2AgbW9kdWxlLiIgbmFtZT0iQ295b3RlIFNlcnZpY2VzLCBJbmMuIiByZWdpZD0ibXljb3lvdGUuY29tIiByb2xlPSJkaXN0cmlidXRvciIvPiA8TGluayByZWw9ImxpY2Vuc2UiIGhyZWY9Ind3dy5nbnUub3JnL2xpY2Vuc2VzL2dwbC50eHQiLz4gPE1ldGEgYWN0aXZhdGlvblN0YXR1cz0idHJpYWwiIHByb2R1Y3Q9IlJvYWRydW5uZXIgRGV0ZWN0b3IiIGNvbGxvcXVpYWxWZXJzaW9uPSIyMDEzIiBlZGl0aW9uPSJjb3lvdGUiIHJldmlzaW9uPSJzcDEiLz4gPFBheWxvYWQ+IDxEaXJlY3Rvcnkgcm9vdD0iJXByb2dyYW1kYXRhJSIgbmFtZT0icnJkZXRlY3RvciI+IDxGaWxlIG5hbWU9InJyZGV0ZWN0b3IuZXhlIiBzaXplPSI1MzI3MTIiIFNIQTI1NjpoYXNoPSJhMzE0ZmMyZGM2NjNhZTdhNmI2YmM2Nzg3NTk0MDU3Mzk2ZTZiM2Y1NjljZDUwZmQ1ZGRiNGQxYmJhZmQyYjZhIi8+IDwvRGlyZWN0b3J5PiA8L1BheWxvYWQ+IDwvU29mdHdhcmVJZGVudGl0eT4"

    ## put binary in payload map
    payload = %{bin: cyclonedx_bin}
    ## build manifest dictionary of payload and mime
    manifest = %{mime_type: "application/cyclonedx+xml", payload: payload}
    ## build sbom_results from manifest and descriptors
    sbom_results = %{type: "CycloneDX", depth: "one-hop", manifest: manifest}
    ## build results sbom_results
    results = %{sbom: sbom_results}
    ## build response from status and results
    return_map = %{status: 200, results: results}
    return_map
  end
end
