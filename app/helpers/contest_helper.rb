module ContestHelper

	def isUserEnrolled?
		if user_signed_in? && !@contest.contest_enrollments.where(:actor_id => current_subject.actor.id).blank?
			return true
		end
		return false
	end

	def contest_page_path(contest,pageName=nil,useName=true)
		if useName
			contestPath = "/contest/" + contest.name
		else
			contestPath = contest_path(contest)
		end
		unless pageName.blank? or pageName=="index"
			contestPath + "/page/" + pageName
		else
			contestPath
		end
	end

	def contest_phase
		return Vish::Application.config.APP_CONFIG["contest_phase"]
	end

	def is_contest?
		if defined? @contest
			return true
		end
	end
end
