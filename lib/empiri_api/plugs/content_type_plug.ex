defmodule EmpiriApi.Plugs.ContentTypePlug do
  import Plug.Conn
  import EmpiriApi.Extensions.ControllerExtensions

  def init(opts) do
    opts
  end

  def call(conn, opts \\ nil) do
    if String.downcase(conn.method) == "get", do: conn, else: validate_content_type(conn, opts)
  end

  defp validate_content_type(conn, opts) do
     if opts[:multipart_regex] && Regex.match?(opts[:multipart_regex], conn.request_path) do
      extract_content_type(conn) |> ensure_multipart_content(conn)
    else
      extract_content_type(conn) |> ensure_json_content(conn)
    end
  end

  defp extract_content_type(conn) do
    type = conn.req_headers |> Enum.find(fn(header) -> elem(header, 0) == "content-type" end)
    if type, do: type |> elem(1) |> Plug.Conn.Utils.media_type, else: :error
  end

  defp ensure_json_content({:ok, type, subtype, _}, conn) do
    if type == "application" && subtype == "json", do: conn, else: render_unsupported_media_type(conn) |> halt
  end

  defp ensure_json_content(:error, conn), do: render_unsupported_media_type(conn) |> halt

  defp ensure_multipart_content({:ok, type, _subtype, _}, conn) do
    if type == "multipart", do: conn, else: render_unsupported_media_type(conn) |> halt
  end

  defp ensure_multipart_content(:error, conn), do: render_unsupported_media_type(conn) |> halt
end