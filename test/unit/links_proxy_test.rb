require 'test_helper'

class GetResponse::LinksProxyTest < Minitest::Spec

  def setup
    @connection = GetResponse::Connection.new("my_api_key")
    @links_proxy = GetResponse::LinksProxy.new(@connection)
  end


  def test_all_without_conditions
    mock(@connection).send_request("get_links", {}) { get_links_response }
    @links = @links_proxy.all

    assert_kind_of Array, @links
    assert @links.all? { |link| link.instance_of?(GetResponse::Link) }
  end


  def test_all_with_conditions
    mock(@connection).send_request("get_links", {"message_id" => ['oxc']}) { get_links_response }
    @links = @links_proxy.all("message_id" => ["oxc"])

    assert_kind_of Array, @links
    assert @links.all? { |link| link.instance_of?(GetResponse::Link) }
  end

end
