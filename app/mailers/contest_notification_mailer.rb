class ContestNotificationMailer < ActionMailer::Base
	default from: Vish::Application.config.APP_CONFIG["no_reply_mail"]


	def contest_welcome_email(user, contest)
		@user = user
		@contest = contest
		subject = t('contest.first_mail.subject')

		mail(:to => user.email,
			 :subject => subject,
			 :content_type => "text/html").deliver
	end
end
