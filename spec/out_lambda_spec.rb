describe Fluent::LambdaOutput do
  let(:time) {
    Time.parse('2014-09-01 01:23:45 UTC').to_i
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

        d.emit({'key1' => 'foo', 'key2' => 100}, time)
        d.emit({'key1' => 'bar', 'key2' => 200}, time)
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

        d.emit({'function_name' => 'my_func1', 'key1' => 'foo', 'key2' => 100}, time)
        d.emit({'function_name' => 'my_func2', 'key1' => 'bar', 'key2' => 200}, time)
      end
    end
  end

  context 'when events is sent without function_name' do
    it 'should be warned' do
      run_driver do |d, client|
        expect(client).to_not receive(:invoke)

        d.emit({'key1' => 'foo', 'key2' => 100}, time)
        d.emit({'key1' => 'bar', 'key2' => 200}, time)

        expect(d.instance.log).to receive(:warn).
           with('`function_name` key does not exist: ["test.default", 1409534625, {"key1"=>"foo", "key2"=>100}]')
        expect(d.instance.log).to receive(:warn).
           with('`function_name` key does not exist: ["test.default", 1409534625, {"key1"=>"bar", "key2"=>200}]')
      end
    end
  end
end
