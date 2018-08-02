require 'test_helper'

class GetResponse::BlacklistTest < Minitest::Spec

  def setup
    @ancestor = Object.new
    @connection = GetResponse::Connection.new "fake_api_key"
    @blacklist = GetResponse::Blacklist.new(["for@foobar.com", "foo@", "@bar.com"], @connection, @ancestor)
  end


  def test_truth
    assert true
  end

end
