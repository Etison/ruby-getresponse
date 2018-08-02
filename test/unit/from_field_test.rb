require 'test_helper'

class FromFieldTest < Minitest::Spec

  def test_initialize
    @from_field = GetResponse::FromField.new("name" => "text", "email" => "test@email.cc",
      "created_on" => "2010-12-23 00:00:00", "id" => "234")

    assert @from_field.id
    assert @from_field.name
    assert @from_field.email
    assert @from_field.created_on
  end

end
