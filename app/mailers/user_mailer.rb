class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.price_notifiaction.subject
  #
  def price_notifiaction
    mail to: "oyvind@kvanes.no", subject: "Price notification"
  end
end
