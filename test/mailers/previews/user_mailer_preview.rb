# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/price_notifiaction
  def price_notifiaction
    UserMailer.price_notifiaction
  end

end
