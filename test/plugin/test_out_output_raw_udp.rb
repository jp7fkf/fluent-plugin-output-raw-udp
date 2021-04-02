require "helper"
require "fluent/plugin/out_output_raw_udp.rb"

class OutputRawUdpOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::OutputRawUdpOutput).configure(conf)
  end
end
