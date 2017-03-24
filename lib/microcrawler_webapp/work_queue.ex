defmodule MicrocrawlerWebapp.WorkQueue do
  @moduledoc """
  TODO
  """

  defstruct [:conn, :chan]

  require Logger

  alias MicrocrawlerWebapp.WorkQueue
  alias AMQP.Connection
  alias AMQP.Channel
  alias AMQP.Queue
  alias AMQP.Basic

  def open! do
    {:ok, work_queue} = open
    work_queue
  end

  def open do
    amqp_username = Application.fetch_env!(:amqp, :username)
    amqp_password = Application.fetch_env!(:amqp, :password)
    amqp_hostname = Application.fetch_env!(:amqp, :hostname)
    amqp_uri = "amqp://#{amqp_username}:#{amqp_password}@#{amqp_hostname}"
    with {:ok, conn} <- Connection.open(amqp_uri),
         true <- Process.link(conn.pid),
         {:ok, chan} <- Channel.open(conn),
         {:ok, _} <- Queue.declare(chan, "workq", durable: true),
    do: {:ok, %WorkQueue{conn: conn, chan: chan}}
  end

  def consume!(queue) do
    {:ok, consumer_tag} = consume(queue)
    consumer_tag
  end

  def consume(queue) do
    with :ok <- Basic.qos(queue.chan, prefetch_count: 1),
    do: Basic.consume(queue.chan, "workq", nil)
  end

  def ack!(queue, meta) do
    :ok = ack(queue, meta)
  end

  def ack(queue, meta) do
    Basic.ack(queue.chan, meta.delivery_tag)
  end

  def publish!(queue, payload) do
    :ok = publish(queue, payload)
  end

  def publish(queue, payload) do
    Basic.publish(queue.chan, "", "workq", payload, persistent: true)
  end

  def close(queue) do
    try do
      Connection.close(queue.conn)
    catch
      :exit, reason -> Logger.error "Rabbit close failed: #{inspect(reason)}"
    end
  end
end
