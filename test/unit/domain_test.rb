require 'test_helper'

class DomainTest < Minitest::Spec

  def test_instance
    @domain = GetResponse::Domain.new("id" => "234", "domain" => "newsletter.company.com",
      "created_on" => "2011-01-20 00:00:00")

    assert @domain.respond_to?(:id)
    assert @domain.respond_to?(:domain)
    assert @domain.respond_to?(:created_on)
  end

end
