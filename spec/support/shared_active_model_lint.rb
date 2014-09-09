require "active_model/lint"
require "minitest/assertions"

shared_examples_for 'ActiveModel' do
  include ActiveModel::Lint::Tests
  include Minitest::Assertions

  before do 
    @assertions = 0
    @model = subject
  end

  def assertions
    @assertions
  end

  def assertions=(num)
    @assertions = num
  end

  ActiveModel::Lint::Tests.public_instance_methods.map(&:to_s).grep(/^test/).each do |test|
    example test.gsub("_", " ") do
      send test
    end
  end
end
