defmodule MicrocrawlerWebapp.IpInfoLoader do
  @moduledoc """
  TODO
  """

  use Bitwise
  require Logger

  def get_ip_infos(dir) do
    {:ok, files} = File.ls Path.join dir
    IO.puts "Loading #{length files} IP files"
    res = files
    |> Enum.map(&Path.join(dir ++ [&1]))
    |> Enum.reduce([], &process_file/2)
    |> Enum.sort
    |> merge
    |> List.to_tuple
    IO.puts "IP files loaded"
    res
  end

  def ip_to_int(ip) when is_tuple(ip) do
    ip
    |> Tuple.to_list
    |> ip_to_int
  end

  def ip_to_int(ip) when is_binary(ip) do
    ip
    |> String.split(".")
    |> Enum.map(&String.to_integer/1)
    |> ip_to_int
  end

  def ip_to_int(ip) when is_list(ip) do
    ip
    |> Enum.reduce(0, &((&2 <<< 8) + &1))
  end

  defp process_file(filename, lines) do
    IO.puts "Loading #{filename}"
    filename
    |> File.stream!([:read])
    |> Enum.reduce(lines, &process_line/2)
  end

  defp process_line(line, lines) do
    case line |> String.trim_trailing |> String.split("|") |> parse_line do
      {:ok, parsed} -> [parsed | lines]
      :error        -> lines
    end
  end

  defp parse_line([_reg, code, "ipv4", ip, count, _date, _status | _])
  when byte_size(code) == 2 do
    start = ip_to_int(ip)
    {:ok, {start, start + String.to_integer(count) - 1, code}}
  end

  defp parse_line([_, _, "ipv6" | _]), do: :error

  defp parse_line([_, _, "asn" | _]), do: :error

  defp parse_line(line) do
    Logger.debug ~s(UNKNOWN: #{Enum.join(line, "|")})
    :error
  end

  defp merge([]) do
    []
  end

  defp merge([ip | ip_infos]) do
    Enum.reverse merge(ip_infos, ip, [])
  end

  defp merge([], last, merged) do
    [last | merged]
  end

  defp merge([ip | ip_infos], {last_from, last_to, last_code} = last, merged) do
    case ip do
      {from, to, code} when last_to + 1 == from and last_code == code ->
        merge(ip_infos, {last_from, to, code}, merged)
      _ ->
        merge(ip_infos, ip, [last | merged])
    end
  end
end

defmodule MicrocrawlerWebapp.IpInfo do
  @moduledoc """
  TODO
  """

  require MicrocrawlerWebapp.IpInfoLoader

  alias MicrocrawlerWebapp.IpInfoLoader

  @dir ["data", "ip"]

  @external_resource Path.join(@dir ++ ["delegated-afrinic-latest"])
  @external_resource Path.join(@dir ++ ["delegated-apnic-latest"])
  @external_resource Path.join(@dir ++ ["delegated-arin-extended-latest"])
  @external_resource Path.join(@dir ++ ["delegated-iana-latest"])
  @external_resource Path.join(@dir ++ ["delegated-lacnic-latest"])
  @external_resource Path.join(@dir ++ ["delegated-ripencc-latest"])

  def for(ip) do
    search(IpInfoLoader.ip_to_int(ip), all_ranges)
  end

  defp search(ip, ranges) do
    bsearch(ip, ranges, 0, tuple_size(ranges) - 1)
  end

  defp bsearch(_ip, _ranges, low, high) when low > high do
    :error
  end

  defp bsearch(ip, ranges, low, high) do
    mid = div(low + high, 2)
    {start, stop, code} = elem(ranges, mid)
    case {ip >= start, ip <= stop} do
      {true, true}  -> {:ok, code}
      {true, false} -> bsearch(ip, ranges, mid + 1, high)
      {false, true} -> bsearch(ip, ranges, low, mid - 1)
    end
  end

  infos = IpInfoLoader.get_ip_infos(["data", "ip"])

  defp all_ranges do
    unquote(Macro.escape(infos))
  end
end

