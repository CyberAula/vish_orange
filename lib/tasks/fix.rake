# encoding: utf-8

namespace :fix do

  #Usage
  #Development:   bundle exec rake fix:resetScormTimestamps
  #In production: bundle exec rake fix:resetScormTimestamps RAILS_ENV=production
  task :resetScormTimestamps => :environment do
    printTitle("Reset SCORM timestamps")

    Excursion.all.map { |ex|
      ex.update_column :scorm2004_timestamp, nil
      ex.update_column :scorm12_timestamp, nil
    }

    printTitle("Task Finished")
  end

  #Usage
  #Development:   bundle exec rake fix:fillExcursionsLanguage
  #In production: bundle exec rake fix:fillExcursionsLanguage RAILS_ENV=production
  task :fillExcursionsLanguage => :environment do

    printTitle("Filling Excursions language")

    validLanguageCodes = ["de","en","es","fr","it","pt","ru"]
    #"ot" is for "other"

    Excursion.all.map { |ex|
      eJson = JSON(ex.json)

      lan = eJson["language"]
      emptyLan = (lan.nil? or !lan.is_a? String or lan=="independent")

      if emptyLan and !Vish::Application.config.APP_CONFIG["languageDetectionAPIKEY"].nil?
        #Try to infer language
        #Use https://github.com/detectlanguage/detect_language gem

        stringToTestLanguage = ""
        if ex.title.is_a? String and !ex.title.blank?
          stringToTestLanguage = stringToTestLanguage + ex.title + " "
        end
        if ex.description.is_a? String and !ex.description.blank?
          stringToTestLanguage = stringToTestLanguage + ex.description + " "
        end

        if stringToTestLanguage.is_a? String and !stringToTestLanguage.blank?
          detectionResult = (DetectLanguage.detect(stringToTestLanguage) rescue [])
          detectionResult.each do |result|
            if result["isReliable"] == true
              detectedLanguageCode = result["language"]
              if validLanguageCodes.include? detectedLanguageCode
                lan = detectedLanguageCode
              else
                lan = "ot"
              end
              emptyLan = false
              break
            end
          end
        end
      end

      if !emptyLan
        ao = ex.activity_object
        if ao.language != lan
          ao.update_column :language, lan
        end

        if eJson["language"] != lan
          eJson["language"] = lan
          ex.update_column :json, eJson.to_json
        end
      end

    }

    printTitle("Task Finished")
  end

  #Usage
  #Development:   bundle exec rake fix:AOsLanguage
  #In production: bundle exec rake fix:AOsLanguage RAILS_ENV=production
  task :AOsLanguage => :environment do
    User.all.select{|u| u.language.blank?}.each do |user|
      user.update_column :language, "en"
      user.activity_object.update_column :language, "en"
    end

    ActivityObject.all.select{|ao| ao.language.blank?}.each do |ao|
      if ao.object_type=="Actor"
        ao.update_column :language, "en"
      elsif ["Document", "Link", "Excursion", "Embed", "Scormfile", "Webapp"].include? ao.object_type
        ao.update_column :language, "independent"
      end
    end

    User.all.select{|u| !u.language.blank? and u.language!=u.activity_object.language}.each do |user|
      user.activity_object.update_column :language, user.language
    end
  end



  #Usage
  #Development:   bundle exec rake fix:recalculateScores
  #In production: bundle exec rake fix:recalculateScores RAILS_ENV=production
  task :recalculateScores => :environment do
    printTitle("Recalculating activity object scores")
    ActivityObject.all.each do |ao|
      ao.calculate_qscore
    end
    printTitle("Task Finished")
  end

  #Usage
  #Development:   bundle exec rake fix:fillIndexedLengths
  #In production: bundle exec rake fix:fillIndexedLengths RAILS_ENV=production
  task :fillIndexedLengths => :environment do
    printTitle("Filling indexed lengths")
    ActivityObject.all.each do |ao|
      if ao.title.is_a? String and ao.title.scan(/\w+/).size>0
        ao.update_column :title_length, ao.title.scan(/\w+/).size
      end
      if ao.description.is_a? String and ao.description.scan(/\w+/).size>0
        ao.update_column :desc_length, ao.description.scan(/\w+/).size
      end
      if ao.tag_list.is_a? ActsAsTaggableOn::TagList and ao.tag_list.length>0
        ao.update_column :tags_length, ao.tag_list.length
      end
    end
    printTitle("Task Finished")
  end


  #Usage
  #Development:   bundle exec rake fix:absoluteZipPaths
  #In production: bundle exec rake fix:absoluteZipPaths RAILS_ENV=production
  task :absoluteZipPaths => :environment do
    printTitle("Fixing absolute zip paths")

    (Scormfile.all + Webapp.all).each do |resource|
      unless resource.zippath.nil? or resource.zippath.index("/documents/").nil? or resource.zippath.index("/documents/")==0
        newZippath = resource.zippath[resource.zippath.index("/documents/")..-1]
        resource.update_column :zippath, newZippath
      end

      #Fix also loPaths when APP_CONFIG["code_path"] is not defined
      if Vish::Application.config.APP_CONFIG["code_path"].nil?
        unless resource.class != Scormfile or resource.lopath.nil? or resource.lopath.index("/public/scorm/packages").nil? or resource.lopath.index("/public/scorm/packages")==0
          #Fix Scormfiles
          newLopath = resource.lopath[resource.lopath.index("/public/scorm/packages")..-1]
          resource.update_column :lopath, newLopath
        end

        unless resource.class != Webapp or resource.lopath.nil? or resource.lopath.index("/public/webappscode").nil? or resource.lopath.index("/public/webappscode")==0
          #Fix WebApps
          newLopath = resource.lopath[resource.lopath.index("/public/webappscode")..-1]
          resource.update_column :lopath, newLopath
        end
      end

    end

    printTitle("Task Finished")
  end

  #Usage
  #Development:   bundle exec rake fix:ViSHCompetition2013
  #In production: bundle exec rake fix:ViSHCompetition2013 RAILS_ENV=production
  task :ViSHCompetition2013 => :environment do
    printTitle("Fixing ViSH Competitions 2013")

    competitionsIds = [616, 560, 488, 485, 483, 477, 476, 634, 515, 543, 484, 487, 486, 516, 517, 601, 512, 536, 527, 479, 617, 556, 480, 631, 44, 64, 620, 511, 287, 614, 603, 590, 522, 592, 659, 656, 74, 531, 496, 613, 682, 503, 448, 606, 450, 632, 508, 510, 675, 667, 564, 474, 562, 668, 645, 605, 530, 97, 669, 397, 465, 650, 458, 520, 430, 646, 648, 435, 390, 461, 431, 624, 630, 526, 539, 162, 657, 432, 454, 540, 437, 460, 433, 429, 593, 492, 434, 463, 647, 469, 414, 436, 653, 563, 548, 439, 654, 490, 440, 629, 441, 447, 535, 636, 602, 655, 421, 644, 591, 600, 491, 473, 468, 416, 660, 415, 413, 412, 678, 580, 674, 579, 686, 676, 688, 637, 482, 842, 481]

    Excursion.record_timestamps=false
    ActivityObject.record_timestamps=false

    Scormfile.all.each do |scormfile|
      begin
        scormfile.updateScormfile
      rescue Exception => e
        puts "Exception in Scormfile with id '" + scormfile.id.to_s + "'. Exception message: " + e.message
      end
    end

    Rake::Task["fix:resetScormTimestamps"].invoke

    Scormfile.record_timestamps=true
    ActivityObject.record_timestamps=true
    printTitle("Task finished")
  end

  #Usage
  #Development:   bundle exec rake fix:updateImscPackages
  #In production: bundle exec rake fix:updateImscPackages RAILS_ENV=production
  task :updateImscPackages => :environment do
    printTitle("Updating IMS Content Packages")
    Imscpfile.record_timestamps=false
    ActivityObject.record_timestamps=false

    Imscpfile.all.each do |imscpfile|
      begin
        imscpfile.updateImscpfile
      rescue Exception => e
        puts "Exception in Imscpfile with id '" + imscpfile.id.to_s + "'. Exception message: " + e.message
      end
    end

    Imscpfile.record_timestamps=true
    ActivityObject.record_timestamps=true
    printTitle("Task finished")
  end

  #Usage
  #Development:   bundle exec rake fix:updateWebapps
  #In production: bundle exec rake fix:updateWebapps RAILS_ENV=production
  task :updateWebapps => :environment do
    printTitle("Updating Web Applications")
    Webapp.record_timestamps=false
    ActivityObject.record_timestamps=false

    Webapp.all.each do |webapp|
      begin
        webapp.updateWebapp
      rescue Exception => e
        puts "Exception in Webapp with id '" + webapp.id.to_s + "'. Exception message: " + e.message
      end

      eJson = JSON(e.json)
      eJson["avatar"] = newAvatarURL
      e.update_column :json, eJson.to_json
      e.update_column :thumbnail_url, newAvatarURL
    end

    Webapp.record_timestamps=true
    ActivityObject.record_timestamps=true

    system("rm -rf tmp/externalAvatars")

    printTitle("Task Finished")
  end

  def downloadAvatar(pictureURL,owner,index)
    begin
      pictureURI = URI.parse(pictureURL)
      fileName = index.to_s + "_" + File.basename(pictureURI.path)
      filePath = "tmp/externalAvatars/" + fileName
      pictureURL = URI.encode(pictureURL)
      command = "wget " + pictureURL + " --output-document='" + filePath + "'"
      system(command)
    rescue => e
      filePath = nil
      fileName = index.to_s + "_default"
    end

    if filePath.nil? or !File.exist?(filePath) or File.zero?(filePath)
      filePath = Rails.root.to_s + '/app/assets/images/logos/original/ao-default.png'
    end

    pic = Picture.new
    pic.title = fileName
    pic.owner_id = owner.id
    pic.author_id = owner.id
    pic.user_author_id = owner.id
    pic.scope = 1
    pic.file = File.open(filePath, "r")

    begin
      pic.save!
    rescue => e
      #Corrupted (but downloaded) images
      filePath = Rails.root.to_s + '/app/assets/images/logos/original/ao-default.png'
      pic.file = File.open(filePath, "r")
      pic.save!
    end

    return pic.getAvatarUrl
  end

  #Usage
  #Development:   bundle exec rake fix:updateDefaultAgeRanges
  #In production: bundle exec rake fix:updateDefaultAgeRanges RAILS_ENV=production
  task :updateDefaultAgeRanges => :environment do

    printTitle("Updating default age ranges")

    aos = ActivityObject.all

    aos.map { |ao|
      if ((ao.age_min === 4) && ((ao.age_max === 20)||(ao.age_max === 30)))
        #Default age range detected
        ao.update_column :age_min, 0
        ao.update_column :age_max, 0

        if ao.object_type=="Excursion"
          #Update json
          excursion = ao.object
          unless excursion.nil?
            eJson = JSON(excursion.json)
            unless eJson["age_range"].blank?
              eJson.delete("age_range")
              excursion.update_column :json, eJson.to_json
            end
          end
        end
      end
    }

    printTitle("Task Finished")
  end

  #Usage
  #Development:   bundle exec rake fix:updateTagsPlainNames
  #In production: bundle exec rake fix:updateTagsPlainNames RAILS_ENV=production
  task :updateTagsPlainNames => :environment do

    printTitle("Updating the plain names of the tags")

    ActsAsTaggableOn::Tag.all.each do |tag|
      tag.update_column :plain_name, ActsAsTaggableOn::Tag.getPlainName(tag.name)
    end

    printTitle("Task Finished")
  end

  #Usage
  #Development:   bundle exec rake fix:updateTagArrayText
  #In production: bundle exec rake fix:updateTagArrayText RAILS_ENV=production
  task :updateTagArrayText => :environment do
    printTitle("Updating the tag_array_text field of the activity objects")
    ActivityObject.all.each do |ao|
      ao.update_column :tag_array_text, ao.save_tag_array_text if ao.tag_list.is_a? ActsAsTaggableOn::TagList
    end
    printTitle("Task Finished")
  end

  #Usage
  #Development:   bundle exec rake fix:roles
  #In production: bundle exec rake fix:roles RAILS_ENV=production
  task :roles => :environment do

    printTitle("Fixing roles")

    Rake::Task["db:populate:create:roles"].invoke

    Actor.record_timestamps=false
    Actor.all.select{|a| a.roles.empty?}.each do |a|
      a.roles.push(Role.default)
    end
    Actor.record_timestamps=true

    printTitle("Task Finished")
  end

  #Usage
  #Development:   bundle exec rake fix:codeResourcesExcursions
  #In production: bundle exec rake fix:codeResourcesExcursions RAILS_ENV=production
  task :codeResourcesExcursions => :environment do

    printTitle("Fixing code resources in excursions")

    #Get all excursions
    excursions = Excursion.all
    excursions.each do |excursion|
      begin
        jsonChange = false
        eJson = JSON(excursion.json)
        eJson["slides"].each do |slide|
          sElements = []
          if slide["type"] == "standard"
            sElements << slide["elements"]
          else
            if slide["slides"].is_a? Array
              slide["slides"].each do |subslide|
                sElements << subslide["elements"]
              end
            end
          end
          sElements.each do |elArray|
            elArray.each do |el|
              if el["type"]=="object" and el["body"].class == String and el["body"].include?("vishubcode.global.dit.upm.es") and el["body"].include?("</iframe>")
                newBody = el["body"].gsub("vishubcode.global.dit.upm.es",Vish::Application.config.APP_CONFIG['code_domain'])
                el["body"] = newBody
                jsonChange = true
              end
            end
          end
        end
        if jsonChange
          puts "Excursion ID"
          puts excursion.id.to_s
          excursion.update_column :json, eJson.to_json
        end
      rescue Exception => e
        puts "Exception with excursion id:"
        puts excursion.id.to_s
        puts "Exception message"
        puts e.message
      end
    end

    printTitle("Task Finished")
  end

  #Usage
  #Development:   bundle exec rake fix:updateCodeResources
  #In production: bundle exec rake fix:updateCodeResources RAILS_ENV=production
  task :updateCodeResources => :environment do
    printTitle("Updating code resources")
    Rake::Task["fix:updateScormPackages"].invoke
    Rake::Task["fix:updateWebapps"].invoke
    Rake::Task["fix:updateImscPackages"].invoke
    Rake::Task["fix:codeResourcesExcursions"].invoke
    printTitle("Task finished")
  end

  #Usage
  #Development:   bundle exec rake fix:createEducaInternet2016Contest
  task :createEducaInternet2016Contest => :environment do
    printTitle("Create the EducaInternet 2016 Contest")

    c = Contest.find_by_template("educa2016")
    c.destroy unless c.nil?

    ml = MailList.find_by_name("Educa2016 MailList")
    ml.destroy unless ml.nil?

    #Create MailList
    ml = MailList.new
    ml.name = "Educa2016 MailList"
    ml.settings = ({"require_login" => "false", "require_name" => "false"}).to_json
    ml.save!

    c = Contest.new
    c.name = "educa2016"
    c.template = "educa2016"
    c.show_in_ui = true
    c.settings = ({"enroll" => "false", "submission" => "one_per_user", "submission_require_enroll" => "false"}).to_json
    c.mail_list_id = ml.id
    c.save!

    cc = ContestCategory.new
    cc.name = "General"
    cc.contest_id = c.id
    cc.save!

    printTitle("Task finished. Contest created with id " + c.id.to_s)
  end

  task :createEducaInternet2017Contest => :environment do
    printTitle("Create the EducaInternet 2017 Contest")

    c = Contest.find_by_template("educa2017")
    c.destroy unless c.nil?

    ml = MailList.find_by_name("Educa2017 MailList")
    ml.destroy unless ml.nil?

    #Create MailList
    ml = MailList.new
    ml.name = "Educa2017 MailList"
    ml.settings = ({"require_login" => "true", "require_name" => "true"}).to_json
    ml.save!

    c = Contest.new
    c.name = "educa2017"
    c.template = "educa2017"
    c.show_in_ui = true
    c.settings = ({"enroll" => "true", "submission" => "free", "submission_require_enroll" => "true", "additional_fields" => ["province","postal_code", "school_name", "teaching_subject", "phone_number"]}).to_json
    c.mail_list_id = ml.id
    c.save!

    cc = ContestCategory.new
    cc.name = "General"
    cc.contest_id = c.id
    cc.save!

    printTitle("Task finished. Contest created with id " + c.id.to_s)
  end

  #Usage
  #Development:   bundle exec rake fix:createTestContest
  task :createTestContest => :environment do
    printTitle("Create a test Contest")

    c = Contest.find_by_template("test")
    c.destroy unless c.nil?

    ml = MailList.find_by_name("MailList Contest Test")
    ml.destroy unless ml.nil?

    #Create MailList
    ml = MailList.new
    ml.name = "MailList Contest Test"
    ml.settings = ({"require_login" => "false", "require_name" => "false"}).to_json
    ml.save!

    c = Contest.new
    c.name = "test"
    c.template = "test"
    c.show_in_ui = true
    c.settings = ({"enroll" => "true", "submission" => "one_per_user", "submission_require_enroll" => "false"}).to_json
    c.mail_list_id = ml.id
    c.save!

    cc = ContestCategory.new
    cc.name = "General"
    cc.contest_id = c.id
    cc.save!

    printTitle("Task finished. Test contest created with id " + c.id.to_s)
  end

 #Usage
  #Development:   bundle exec rake fix:createTestContest
  task :createTestOtherDataContest => :environment do
    printTitle("Create a test Contest")

    c = Contest.find_by_template("test")
    c.destroy unless c.nil?

    ml = MailList.find_by_name("MailList Contest Test")
    ml.destroy unless ml.nil?

    #Create MailList
    ml = MailList.new
    ml.name = "MailList Contest Test"
    ml.settings = ({"require_login" => "false", "require_name" => "false"}).to_json
    ml.save!

    c = Contest.new
    c.name = "test"
    c.template = "test"
    c.show_in_ui = true
    c.settings = ({"enroll" => "true", "submission" => "one_per_user", "submission_require_enroll" => "false", "additional_fields" => ["province","postal_code"]}).to_json
    c.mail_list_id = ml.id
    c.save!

    cc = ContestCategory.new
    cc.name = "General"
    cc.contest_id = c.id
    cc.save!

    printTitle("Task finished. Test contest created with id " + c.id.to_s)
  end

  #Usage
  #Development:   bundle exec rake fix:populateusers
  task :populateusers => :environment do |t,args|
    printTitle("Populate users")
    require 'csv'
    csv_text = File.read('tmp/users.csv',:quote_char => "|")
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      email = row["email"]

      #Create user with email and password
      user = User.find_by_email(email)
      user = User.new if user.blank?

      user.name = row["username"]
      user.email = email
      user.password = "changeme"
      user.password_confirmation = "changeme"
      user.language = "es"

      begin 
        user.save!
        user.update_column :encrypted_password, row["password"]
        puts "OK"
      rescue 
        puts row.to_s
      end
    end

    printTitle("Task finished")
  end

  ####################
  #Task Utils
  ####################

  def printTitle(title)
    if !title.nil?
      puts "#####################################"
      puts title
      puts "#####################################"
    end
  end

  def printSeparator
    puts ""
    puts "--------------------------------------------------------------"
    puts ""
  end

end
