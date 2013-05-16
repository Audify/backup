# encoding: utf-8

require File.expand_path('../../spec_helper.rb', __FILE__)

module Backup
describe Notifier::Campfire do
  let(:model) { Model.new(:test_trigger, 'test label') }
  let(:notifier) { Notifier::Campfire.new(model) }

  it_behaves_like 'a class that includes Configuration::Helpers'
  it_behaves_like 'a subclass of Notifier::Base'

  describe '#initialize' do
    it 'provides default values' do
      expect( notifier.api_token  ).to be_nil
      expect( notifier.subdomain  ).to be_nil
      expect( notifier.room_id    ).to be_nil

      expect( notifier.on_success ).to be(true)
      expect( notifier.on_warning ).to be(true)
      expect( notifier.on_failure ).to be(true)
    end

    it 'configures the notifier' do
      notifier = Notifier::Campfire.new(model) do |campfire|
        campfire.api_token = 'token'
        campfire.subdomain = 'subdomain'
        campfire.room_id   = 'room_id'

        campfire.on_success = false
        campfire.on_warning = false
        campfire.on_failure = false
      end

      expect( notifier.api_token  ).to eq 'token'
      expect( notifier.subdomain  ).to eq 'subdomain'
      expect( notifier.room_id    ).to eq 'room_id'

      expect( notifier.on_success ).to be(false)
      expect( notifier.on_warning ).to be(false)
      expect( notifier.on_failure ).to be(false)
    end
  end # describe '#initialize'

  describe '#notify!' do
    let(:notifier) {
      Notifier::Campfire.new(model) do |campfire|
        campfire.api_token = 'my_token'
        campfire.subdomain = 'my_subdomain'
        campfire.room_id   = 'my_room_id'
      end
    }
    let(:interface) { Notifier::Campfire::Interface }
    let(:message) { '[Backup::%s] test label (test_trigger)' }

    context 'when status is :success' do
      it 'sends a success message' do
        interface.expects(:base_uri).with('https://my_subdomain.campfirenow.com')
        interface.expects(:basic_auth).with('my_token', 'x')
        interface.expects(:post).with(
          '/room/my_room_id/speak.json',
          { :body =>
            MultiJson.encode(
              { :message =>
                { :body => message % 'Success', :type => 'Textmessage' }
              }
            )
          }
        )

        expect( interface.headers['Content-Type'] ).to eq 'application/json'

        notifier.send(:notify!, :success)
      end
    end

    context 'when status is :warning' do
      it 'sends a warning message' do
        interface.expects(:base_uri).with('https://my_subdomain.campfirenow.com')
        interface.expects(:basic_auth).with('my_token', 'x')
        interface.expects(:post).with(
          '/room/my_room_id/speak.json',
          { :body =>
            MultiJson.encode(
              { :message =>
                { :body => message % 'Warning', :type => 'Textmessage' }
              }
            )
          }
        )

        expect( interface.headers['Content-Type'] ).to eq 'application/json'

        notifier.send(:notify!, :warning)
      end
    end

    context 'when status is :failure' do
      it 'sends a failure message' do
        interface.expects(:base_uri).with('https://my_subdomain.campfirenow.com')
        interface.expects(:basic_auth).with('my_token', 'x')
        interface.expects(:post).with(
          '/room/my_room_id/speak.json',
          { :body =>
            MultiJson.encode(
              { :message =>
                { :body => message % 'Failure', :type => 'Textmessage' }
              }
            )
          }
        )

        expect( interface.headers['Content-Type'] ).to eq 'application/json'

        notifier.send(:notify!, :failure)
      end
    end

  end # describe '#notify!'
end
end
