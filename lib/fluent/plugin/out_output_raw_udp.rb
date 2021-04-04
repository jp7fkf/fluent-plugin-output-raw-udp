#
# Copyright 2021 Yudai Hashimoto(jp7fkf)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/output"

require "socket"
require "json"

module Fluent
  module Plugin
    class OutputRawUdpOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("output_raw_udp", self)

      helpers :compat_parameters, :formatter, :inject

      # Define parameters for your plugin.
      config_param :host, :string, :default => nil
      config_param :port, :integer, :default => 514

      config_section :format do
        config_set_default :@type, "json" #"out_file"
      end


      config_section :buffer do
        config_set_default :flush_mode, :interval
        config_set_default :flush_interval, 5
        config_set_default :flush_thread_interval, 0.5
        config_set_default :flush_thread_burst_interval, 0.5
      end

      #config_section :format do
      #  config_set_default :@type, 'out_file'
      #end

      def configure(conf)
        compat_parameters_convert(conf, :buffer, :formatter, :inject)

        super

        if @host.nil?
          raise ConfigError, "host is required"
        end

	@formatter = formatter_create

        #@senders = []
      end

      def initialize()
        super
        @socket = UDPSocket.new
      end

      def format(tag, time, record)
        r = inject_values_to_record(tag, time, record)
        @formatter.format(tag, time, r)
      end


      #### Non-Buffered Output #############################
      # Implement `process()` if your plugin is non-buffered.
      # Read "Non-Buffered output" for details.
      ######################################################
      #def process(tag, es)
      #  es.each do |time, record|
      #    @socket.send(record['message'], 0, @host, @port)
      #  end
      #end

      #### Sync Buffered Output ##############################
      # Implement `write()` if your plugin uses normal buffer.
      # Read "Sync Buffered Output" for details.
      ########################################################
      def write(chunk)
	return if chunk.empty?

        #host = extract_placeholders(@host, chunk.metadata)
        #port = extract_placeholders(@port, chunk.metadata)
        #host = @host
        #port = @port

        log.debug 'writing data to file', chunk_id: dump_unique_id_hex(chunk.unique_id)

        # For standard chunk format (without `#format()` method)
        chunk.each do |time, record|
          @socket.send(record, 0, @host, @port)
        end

      end

    end
  end
end
