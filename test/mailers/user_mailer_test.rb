require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "price_notifiaction" do
    mail = UserMailer.price_notifiaction(0.01, "BTC")
    assert_equal "Price notification for BTC, price is 0.01", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Price notification for BTC, price is 0.01", mail.body.encoded
  end

end
