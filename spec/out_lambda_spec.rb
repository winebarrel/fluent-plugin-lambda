describe Fluent::Plugin::LambdaOutput do
  include Fluent::Test::Helpers

  let(:time) {
    event_time('2014-09-01 01:23:45 UTC')
  }

  context 'when events is sent' do
    it 'should be call invoke' do
      run_driver(function_name: 'my_func') do |d, client|
        expect(client).to receive(:invoke).with(
          function_name: 'my_func',
          payload: JSON.dump('key1' => 'foo', 'key2' => 100),
          invocation_type: 'Event',
        )

        expect(client).to receive(:invoke).with(
          function_name: 'my_func',
          payload: JSON.dump('key1' => 'bar', 'key2' => 200),
          invocation_type: 'Event',
        )

        d.feed(time, {'key1' => 'foo', 'key2' => 100})
        d.feed(time, {'key1' => 'bar', 'key2' => 200})
      end
    end
  end

  context 'when events is sent with function_name' do
    it 'should be call invoke' do
      run_driver do |d, client|
        expect(client).to receive(:invoke).with(
          function_name: 'my_func1',
          payload: JSON.dump('function_name' => 'my_func1', 'key1' => 'foo' , 'key2' => 100),
          invocation_type: 'Event',
        )

        expect(client).to receive(:invoke).with(
          function_name: 'my_func2',
          payload: JSON.dump('function_name' => 'my_func2', 'key1' => 'bar' , 'key2' => 200),
          invocation_type: 'Event',
        )

        d.feed(time, {'function_name' => 'my_func1', 'key1' => 'foo', 'key2' => 100})
        d.feed(time, {'function_name' => 'my_func2', 'key1' => 'bar', 'key2' => 200})
      end
    end
  end

  context 'when events is sent without function_name' do
    it 'should be warned' do
      run_driver do |d, client|
        expect(client).to_not receive(:invoke)

        d.feed(time, {'key1' => 'foo', 'key2' => 100})
        d.feed(time, {'key1' => 'bar', 'key2' => 200})

        expect(d.instance.log).to receive(:warn).
           with('`function_name` key does not exist: ["test.default", 1409534625, {"key1"=>"foo", "key2"=>100}]')
        expect(d.instance.log).to receive(:warn).
           with('`function_name` key does not exist: ["test.default", 1409534625, {"key1"=>"bar", "key2"=>200}]')
      end
    end
  end

  context 'when a qualifier is provided' do
    it 'invokes that alias' do
      run_driver(qualifier: 'staging') do |d, client|
        expect(client).to receive(:invoke).with(
          function_name: 'my_func1',
          payload: JSON.dump('function_name' => 'my_func1', 'key1' => 'foo' , 'key2' => 100),
          invocation_type: 'Event',
          qualifier: 'staging'
        )

        expect(client).to receive(:invoke).with(
          function_name: 'my_func2',
          payload: JSON.dump('function_name' => 'my_func2', 'key1' => 'bar' , 'key2' => 200),
          invocation_type: 'Event',
          qualifier: 'staging'
        )

        d.feed(time, {'function_name' => 'my_func1', 'key1' => 'foo', 'key2' => 100})
        d.feed(time, {'function_name' => 'my_func2', 'key1' => 'bar', 'key2' => 200})
      end
    end
  end

  context 'when bulk write is turned on' do
    it 'should call invoke with array of events' do
      run_driver(group_events: true, function_name: 'my_func') do |d, client|

        expect(client).to receive(:invoke).with(
          function_name: 'my_func',
          payload: JSON.dump([{'key' => 1}, {'key' => 2}, {'key' => 3}]),
          invocation_type: 'Event'
        )

        d.feed(time, {'key' => 1})
        d.feed(time, {'key' => 2})
        d.feed(time, {'key' => 3})
      end
    end
  end
  it 'should throw error when @group_events is on, but function_name is missed' do
    expect {
      run_driver(group_events: true)
    }.to raise_error(Fluent::ConfigError)
  end
end
