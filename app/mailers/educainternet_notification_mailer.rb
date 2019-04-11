class EducainternetNotificationMailer < ActionMailer::Base
	default from: Vish::Application.config.APP_CONFIG["no_reply_mail"]

	def platform_welcome_email(user)
		@user = user
		subject = t('contest.second_mail.subject')

		mail(:to => user.email,
			 :subject => subject,
			 :content_type => "text/html").deliver
	end

	def course_welcome_email(user, course)
		@user = user
		@course = course
		subject = t('course.first_mail.subject')

		mail(:to => user.email,
			 :subject => subject,
			 :content_type => "text/html").deliver
	end


	def contest_welcome_email(user, contest)
		@user = user
		@contest = contest
		subject = t('contest.first_mail.subject')

		mail(:to => user.email,
			 :subject => subject,
			 :content_type => "text/html").deliver
	end

	def send_spam_report(user, issueType, issue, activity_object_id)
    	@user = user
    	@issueType = issueType
    	@issue = issue
    	@activity_object_id = activity_object_id
    	mail(:to => Vish::Application.config.spam_report_recipient, :subject => "ViSH spam/error report")
  end
end
