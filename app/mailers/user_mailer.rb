class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.price_notifiaction.subject
  #
  def price_notifiaction(new_price,string)
    mail to: "to@example.org", subject: "Price notification for #{string}, price is #{new_price}", body: "Price notification for #{string}, price is #{new_price}"
  end
end
