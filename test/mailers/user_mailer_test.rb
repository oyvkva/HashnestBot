require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "price_notifiaction" do
    mail = UserMailer.price_notifiaction
    assert_equal "Price notifiaction", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
