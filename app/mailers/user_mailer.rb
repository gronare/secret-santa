class UserMailer < ApplicationMailer
  default from: "Secret Santa <noreply@secretsanta.gronare.com>"

  def magic_link(user, magic_link)
    @user = user
    @magic_link = magic_link

    mail(
      to: @user.email,
      subject: "Your Secret Santa login link"
    )
  end
end
