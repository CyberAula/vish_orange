# encoding: utf-8

namespace :loep do

  #Usage
  #Development:   bundle exec rake loep:registerLOs
  #In production: bundle exec rake loep:registerLOs RAILS_ENV=production
  task :registerLOs => :environment do

    puts "#####################################"
    puts "Bringing LOs from ViSH to LOEP"
    puts "#####################################"

    #Select an array of excursions to be registered in LOEP
    #Examples:

    #One single excursion
    # excursions = [Excursion.last]
    # excursions = [Excursion.find(690)]

    #All published excursions
    excursions = Excursion.all.select{ |ex| ex.draft==false }

    #Excursions tagged with ViSHCompetition2013
    # excursions = ActivityObject.tagged_with("ViSHCompetition2013").map(&:object).select{|a| a.class==Excursion && a.draft == false}

    #Excursions published in the last 3 months
    # endDate = Time.now
    # startDate = endDate.advance(:months => -3)
    # excursions = Excursion.where(:draft=> false, :created_at => startDate..endDate)
    
    aos = excursions.map{|ex| ex.activity_object}
    VishLoep.registerActivityObjects(aos,{:sync=>true,:trace=>true})
    # Async
    # VishLoep.registerActivityObjects(aos,{:async=>true,:trace=>true})
    
  end

  #Usage
  #Development:   bundle exec rake loep:getAllMetrics
  #In production: bundle exec rake loep:getAllMetrics RAILS_ENV=production
  task :getAllMetrics => :environment do
    puts "#####################################"
    puts "Getting quality metrics from LOEP and updating ViSH database"
    puts "#####################################"

    Excursion.all.each do |ex|
      VishLoep.getActivityObjectMetrics(ex.activity_object){ |response|
        puts "Metrics for excursion: " + ex.id.to_s
        puts response
      }
      sleep 2
    end
  end

end
