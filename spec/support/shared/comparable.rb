require 'rails_helper'


RSpec.shared_examples 'a comparable object' do |test_data|
  let(:test_klass) { test_data[:test_klass] }

  context '#<=>' do
    let(:test_obj) {
      data = test_data[:cases].first
      (data[:arg_expand]) ? test_klass.new(*(data[:arg])) : test_klass.new(data[:arg])
    }

    specify 'is implemented' do
      expect(test_obj).to respond_to :<=>
    end

    context 'is not comparable' do
      test_data[:invalid_other].each do |invalid|
        specify "to \"#{invalid}\"" do
          expect(test_obj <=> invalid).to be_nil
        end
      end
    end

    test_data[:cases].each do |test|
      context "with value \"#{test[:arg]}\"" do
        let(:test_obj) { (test[:arg_expand]) ? test_klass.new(*(test[:arg])) : test_klass.new(test[:arg]) }

        context 'is less' do
          test[:less].each do |less|
            let(:other) { (test[:init_other]) ? test_klass.new(less) : less }

            specify "than \"#{less}\"" do
              expect(test_obj < other).to be_truthy
            end
          end
        end

        context 'is equal' do
          test[:equal].each do |equal|
            let(:other) {
              if equal == :same_args
                (test[:arg_expand]) ? test_klass.new(*(test[:arg])) : test_klass.new(test[:arg])
              else
                (test[:init_other]) ? test_klass.new(equal) : equal
              end
            }

            specify "to \"#{equal}\"" do
              expect(test_obj == other).to be_truthy
            end
          end
        end

        context 'is greater' do
          test[:greater].each do |greater|
            let(:other) { (test[:init_other]) ? test_klass.new(greater) : greater }

            specify "than \"#{greater}\"" do
              expect(test_obj > other).to be_truthy
            end
          end
        end
      end
    end
  end
end
