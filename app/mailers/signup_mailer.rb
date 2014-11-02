class SignupMailer < ActionMailer::Base
  default from: "bookstrap.info@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.signup_mailer.sendmail_activate.subject
  #
  def sendmail_activate(user)
    @user = user
    mail(to: user.email, subject: "Bookstrap登録確認" )
  end
end
