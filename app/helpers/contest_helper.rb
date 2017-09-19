module ContestHelper

	def isUserEnrolled?
		if !@contest.contest_enrollments.where(:actor_id => current_subject.actor.id).blank?
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

	def contest_fase
		return 2
	end
end
