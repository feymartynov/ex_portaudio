defmodule PortAudio do
  alias PortAudio.Native

  def devices do
    # TODO: convert to struct
    for device_idx <- 0 .. Native.device_count() - 1 do
      Native.device_info(device_idx)
    end
  end

  def host_apis do
    for host_idx <- 0 .. Native.host_api_count() - 1 do
      Native.host_api_info(host_idx)
    end
  end

  def test_gc do
    spawn(fn ->
      {:ok, s} = Native.stream_open_default(32, 32, :float32, 1000.0, 256)
      Native.stream_start(s)
    end)
  end

  def feedback do
    spawn(fn ->
      {:ok, s} = Native.stream_open_default(32, 32, :float32, 44100.0, 256)
      Native.stream_start(s)

      loop(s)
    end)
  end

  defp loop(s) do
    case Native.stream_read(s) do
      {:ok, pcmdata} ->
        IO.puts "Streaming #{byte_size(pcmdata)} bytes"
        Native.stream_write(s, pcmdata)

      _ -> nil
    end
    loop(s)
  end
end
