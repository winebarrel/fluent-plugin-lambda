require 'json'
require 'aws-sdk-core'
require 'fluent/plugin/output'

class Fluent::Plugin::LambdaOutput < Fluent::Plugin::Output
  Fluent::Plugin.register_output('lambda', self)

  helpers :compat_parameters, :inject

  DEFAULT_BUFFER_TYPE = "memory"

  config_param :profile,                    :string, :default => nil
  config_param :credentials_path,           :string, :default => nil
  config_param :aws_key_id,                 :string, :default => nil
  config_param :aws_sec_key,                :string, :default => nil
  config_param :region,                     :string, :default => nil
  config_param :endpoint,                   :string, :default => nil
  config_param :function_name,              :string, :default => nil
  config_param :qualifier,                  :string, :default => nil
  config_param :group_events,		            :bool,   :default => false

  config_set_default :include_time_key, false
  config_set_default :include_tag_key,  false

  config_section :buffer do
    config_set_default :@type, DEFAULT_BUFFER_TYPE
  end

  def initialize
    super
  end

  def configure(conf)
    compat_parameters_convert(conf, :buffer, :inject)
    super

    aws_opts = {}

    if @profile
      credentials_opts = {:profile_name => @profile}
      credentials_opts[:path] = @credentials_path if @credentials_path
      credentials = Aws::SharedCredentials.new(credentials_opts)
      aws_opts[:credentials] = credentials
    end

    if @group_events
      raise Fluent::ConfigError, "could not group events without 'function_name'" if @function_name.nil?
    end

    aws_opts[:access_key_id] = @aws_key_id if @aws_key_id
    aws_opts[:secret_access_key] = @aws_sec_key if @aws_sec_key
    aws_opts[:region] = @region if @region
    aws_opts[:endpoint] = @endpoint if @endpoint

    configure_aws(aws_opts)
  end

  def start
    super

    @client = create_client
  end

  def formatted_to_msgpack_binary
    true
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def write(chunk)
    chunk = chunk.to_enum(:msgpack_each)
    if @group_events
      write_batch(chunk)
    else
      write_by_one(chunk)
    end
  end

  private

  def configure_aws(options)
    Aws.config.update(options)
  end

  def create_client
    Aws::Lambda::Client.new
  end

  def write_batch(chunk) 
    func_name = @function_name
    chunk.group_by {|tag, time, record| 
      tag
    }.each{|key, group|
      events = []
      group.each do |time, tag, record|
        events << record
      end
      @client.invoke({
        :function_name => func_name,
        :payload => JSON.dump(events),
        :invocation_type => 'Event',
      })
    }
  end

  def write_by_one(chunk)
    chunk.select {|tag, time, record|
      if @function_name or record['function_name']
        true
      else
        log.warn("`function_name` key does not exist: #{[tag, time, record].inspect}")
        false
      end
    }.each {|tag, time, record|
      record = inject_values_to_record(tag, time, record)
      func_name = @function_name || record['function_name']

      payload = {
        :function_name => func_name,
        :payload => JSON.dump(record),
        :invocation_type => 'Event',
      }
      payload[:qualifier] = @qualifier unless @qualifier.nil?

      @client.invoke(payload)
    }
  end

end
