class ContestNotificationMailer < ActionMailer::Base
	default from: Vish::Application.config.APP_CONFIG["no_reply_mail"]


	def contest_welcome_email(user, contest)
		@user = user
		@contest = contest
		subject = t('contest.educa2017.mailers.first_subject_email')

		mail(:to => user.email, 
			 :subject => subject, 
			 :content_type => "text/html").deliver
	end
end
