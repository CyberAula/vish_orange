require 'builder'

class Excursion < ActiveRecord::Base
  include SocialStream::Models::Object
  has_many :excursion_contributors, :dependent => :destroy
  has_many :contributors, :class_name => "Actor", :through => :excursion_contributors

  validates_presence_of :json
  after_save :parse_for_meta
  after_save :fix_post_activity_nil
  after_destroy :remove_scorm
  after_destroy :remove_pdf
  
  define_index do
    activity_object_index
    
    has slide_count
    has draft
  end



  ####################
  ## Model methods
  ####################

  def to_json(options=nil)
    json
  end

  def interaction_attributes
    interaction_attributes = Hash.new
    interaction_attributes["id"] = self.id
    interaction_attributes["title"] = self.title
    interaction_attributes["LORIscore"] = self.reviewers_qscore.to_f
    i = self.lo_interaction
    unless i.nil?
      interaction_attributes = interaction_attributes.merge(i.attributes)
      interaction_attributes.delete "created_at"
      interaction_attributes.delete "updated_at"
      interaction_attributes.delete "activity_object_id"
    end
    interaction_attributes
  end

  ####################
  ## OAI-PMH Management
  ####################
  def oai_dc_identifier
    Rails.application.routes.url_helpers.excursion_url(:id => self.id)
  end

  def oai_dc_title
    title
  end

  def oai_dc_description
    description
  end

  def oai_dc_creator
    author.name
  end

  def to_oai_lom
    identifier = Rails.application.routes.url_helpers.excursion_url(:id => self.id)
    xmlMetadata = ::Builder::XmlMarkup.new(:indent => 2)
    Excursion.generate_LOM_metadata(JSON(self.json),self,{LOMschema: "ODS", :target => xmlMetadata, :id => identifier})
    xmlMetadata
  end



  ####################
  ## SCORM Management
  ####################

  def to_scorm(controller)
    if self.scorm_needs_generate
      filePath = "#{Rails.root}/public/scorm/excursions/"
      fileName = self.id
      json = JSON(self.json)
      Excursion.createSCORM(filePath,fileName,json,self,controller)
      self.update_column(:scorm_timestamp, Time.now)
    end
  end

  def scorm_needs_generate
    if self.scorm_timestamp.nil? or self.updated_at > self.scorm_timestamp or !File.exist?("#{Rails.root}/public/scorm/excursions/#{self.id}.zip")
      return true
    else
      return false
    end
  end

  def remove_scorm
    if File.exist?("#{Rails.root}/public/scorm/excursions/#{self.id}.zip")
      File.delete("#{Rails.root}/public/scorm/excursions/#{self.id}.zip") 
    end
  end

  def self.createSCORM(filePath,fileName,json,excursion,controller)
    require 'zip'

    # filePath = "#{Rails.root}/public/scorm/excursions/"
    # fileName = self.id
    # json = JSON(self.json)
    t = File.open("#{filePath}#{fileName}.zip", 'w')

    #Add manifest, main HTML file and additional files
    Zip::OutputStream.open(t.path) do |zos|
      xml_manifest = Excursion.generate_scorm_manifest(json,excursion)
      zos.put_next_entry("imsmanifest.xml")
      zos.print xml_manifest.target!()

      zos.put_next_entry("excursion.html")
      zos.print controller.render_to_string "show.scorm.erb", :locals => {:excursion=>excursion, :json => json}, :layout => false  
    end

    #Add required XSD files and folders
    xsdFileDir = "#{Rails.root}/public/xsd"
    xsdFiles = ["adlcp_v1p3.xsd","adlnav_v1p3.xsd","adlseq_v1p3.xsd","imscp_v1p1.xsd","imsss_v1p0.xsd","lom.xsd"]
    xsdFolders = ["common","extend","unique","vocab"]

    #Add required xsd files
    Zip::File.open(t.path, Zip::File::CREATE) { |zipfile|
      xsdFiles.each do |xsdFileName|
        zipfile.add(xsdFileName,xsdFileDir+"/"+xsdFileName)
      end
    }

    #Add required XSD folders
    xsdFolders.each do |xsdFolderName|
      zip_folder(t.path,xsdFileDir,xsdFileDir+"/"+xsdFolderName)
    end

    #Copy SCORM assets (image, javascript and css files)
    dir = "#{Rails.root}/lib/plugins/vish_editor/app/scorm"
    zip_folder(t.path,dir)

    #Add theme
    themesPath = "#{Rails.root}/lib/plugins/vish_editor/app/assets/images/themes/"
    theme = "theme1" #Default theme
    if json["theme"] and File.exists?(themesPath + json["theme"])
      theme = json["theme"]
    end
    #Copy excursion theme
    zip_folder(t.path,"#{Rails.root}/lib/plugins/vish_editor/app/assets",themesPath + theme)

    t.close
  end

  def self.zip_folder(zipFilePath,root,dir=nil)
    unless dir 
      dir = root
    end

    #Get subdirectories
    Dir.chdir(dir)
    subdir_list=Dir["*"].reject{|o| not File.directory?(o)}
    subdir_list.each do |subdirectory|
      subdirectory_path = "#{dir}/#{subdirectory}"
      zip_folder(zipFilePath,root,subdirectory_path)
    end

    #Look for files
    Zip::File.open(zipFilePath, Zip::File::CREATE) { |zipfile|
      Dir.foreach(dir) do |item|
        item_path = "#{dir}/#{item}"
        if File.file?item_path
          rpath = String.new(item_path)
          rpath.slice! root + "/"
          zipfile.add(rpath,item_path)
        end
      end
    }
  end

  # Metadata based on LOM (Learning Object Metadata) standard
  # LOM final draft: http://ltsc.ieee.org/wg12/files/LOM_1484_12_1_v1_Final_Draft.pdf
  def self.generate_scorm_manifest(ejson,excursion,options=nil)
    if excursion and !excursion.id.nil?
      identifier = excursion.id.to_s
      lomIdentifier = Rails.application.routes.url_helpers.excursion_url(:id => excursion.id)
    elsif (ejson["vishMetadata"] and ejson["vishMetadata"]["id"])
      identifier = ejson["vishMetadata"]["id"].to_s
      lomIdentifier = "urn:ViSH:" + identifier
    else
      count = Site.current.config["tmpCounter"].nil? ? 1 : Site.current.config["tmpCounter"]
      Site.current.config["tmpCounter"] = count + 1
      Site.current.save!
      
      identifier = "TmpSCORM_" + count.to_s
      lomIdentifier = "urn:ViSH:" + identifier
    end

    myxml = ::Builder::XmlMarkup.new(:indent => 2)
    myxml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    myxml.manifest("identifier"=>"VISH_VIRTUAL_EXCURSION_" + identifier,
      "version"=>"1.3",
      "xmlns"=>"http://www.imsglobal.org/xsd/imscp_v1p1",
      "xmlns:adlcp"=>"http://www.adlnet.org/xsd/adlcp_v1p3",
      "xmlns:adlseq"=>"http://www.adlnet.org/xsd/adlseq_v1p3",
      "xmlns:adlnav"=>"http://www.adlnet.org/xsd/adlnav_v1p3",
      "xmlns:imsss"=>"http://www.imsglobal.org/xsd/imsss",
      "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
      "xsi:schemaLocation"=>"http://www.imsglobal.org/xsd/imscp_v1p1 imscp_v1p1.xsd http://www.adlnet.org/xsd/adlcp_v1p3 adlcp_v1p3.xsd http://www.adlnet.org/xsd/adlseq_v1p3 adlseq_v1p3.xsd http://www.adlnet.org/xsd/adlnav_v1p3 adlnav_v1p3.xsd http://www.imsglobal.org/xsd/imsss imsss_v1p0.xsd",
    ) do

      myxml.metadata() do
        myxml.schema("ADL SCORM")
        myxml.schemaversion("2004 4th Edition")
        #Add LOM metadata
        Excursion.generate_LOM_metadata(ejson,excursion,{:target => myxml, :id => lomIdentifier, :LOMschema => (options and options[:LOMschema]) ? options[:LOMschema] : "custom"})
      end

      myxml.organizations('default'=>"defaultOrganization") do
        myxml.organization('identifier'=>"defaultOrganization", 'structure'=>"hierarchical") do
          if ejson["title"]
            myxml.title(ejson["title"])
          else
            myxml.title("Untitled")
          end
          myxml.item('identifier'=>"VIRTUAL_EXCURSION_" + identifier,'identifierref'=>"VIRTUAL_EXCURSION_" + identifier + "_RESOURCE") do
            if ejson["title"]
              myxml.title(ejson["title"])
            else
              myxml.title("Untitled")
            end
          end
        end
      end

      myxml.resources do         
        myxml.resource('identifier'=>"VIRTUAL_EXCURSION_" + identifier + "_RESOURCE", 'type'=>"webcontent", 'href'=>"excursion.html", 'adlcp:scormType'=>"sco") do
          myxml.file('href'=> "excursion.html")
        end
      end

    end    

    return myxml
  end



  ####################
  ## LOM Metadata
  ####################

  def self.generate_LOM_metadata(ejson, excursion, options=nil)
    _LOMschema = "custom"

    supportedLOMSchemas = ["custom","loose","ODS","ViSH"]
    if options and options[:LOMschema] and supportedLOMSchemas.include? options[:LOMschema]
      _LOMschema = options[:LOMschema]
    end

    if options and options[:target]
      myxml = ::Builder::XmlMarkup.new(:indent => 2, :target => options[:target])
    else
      myxml = ::Builder::XmlMarkup.new(:indent => 2)
      myxml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    end
   
    #Select LOM Header options
    lomHeaderOptions = {}

    case _LOMschema
    when "loose","custom"
      lomHeaderOptions =  { 'xmlns' => "http://ltsc.ieee.org/xsd/LOM",
                            'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                            'xsi:schemaLocation' => "http://ltsc.ieee.org/xsd/LOM lom.xsd"
                          }
    when "ODS"
      lomHeaderOptions =  { 'xmlns' => "http://ltsc.ieee.org/xsd/LOM",
                            'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                            'xsi:schemaLocation' => "http://ltsc.ieee.org/xsd/LOM lomODS.xsd"
                          }
    else
      #Extension not supported/recognized
      lomHeaderOptions = {}
    end


    myxml.tag!("lom",lomHeaderOptions) do

      #Calculate some recurrent vars

      #Identifier
      loIdIsURI = false
      loIdIsURN = false
      loId = nil

      if options and options[:id]
          loId = options[:id].to_s

          begin
            loUri = URI.parse(loId)
            if %w( http https ).include?(loUri.scheme)
              loIdIsURI = true
            elsif %w( urn ).include?(loUri.scheme)
              loIdIsURN = true
            end
          rescue
          end

          if !loIdIsURI and !loIdIsURN
            #Build URN
            loId = "urn:ViSH:"+loId
          end
      end

      #Location
      loLocation = nil
      if excursion
        if excursion.draft == false
          loLocation = Rails.application.routes.url_helpers.excursion_url(:id => excursion.id)
        end
      elsif ejson["vishMetadata"] and ejson["vishMetadata"]["id"] and (ejson["vishMetadata"]["draft"] == false or ejson["vishMetadata"]["draft"] == "false")
        begin
          excursionInstance = Excursion.find(ejson["vishMetadata"]["id"])
          loLocation = Rails.application.routes.url_helpers.excursion_url(:id => excursionInstance.id)
        rescue
        end
      end

      #Language (LO language and metadata language)
      loLanguage = getLOMLoLanguage(ejson["language"], _LOMschema)
      if loLanguage.nil?
        loLanOpts = {}
      else
        loLanOpts = { :language=> loLanguage }
      end
      metadataLanguage = "en"

      #Author name
      authorName = nil
      if ejson["author"] and ejson["author"]["name"]
        authorName = ejson["author"]["name"]
      elsif (!excursion.nil? and !excursion.author.nil? and !excursion.author.name.nil?)
        authorName = excursion.author.name
      end

      # loDate 
      # According to ISO 8601 (e.g. 2014-06-23)
      if excursion
        loDate = excursion.updated_at
      else
        loDate = Time.now
      end
      loDate = (loDate).strftime("%Y-%m-%d").to_s

      #VE version
      atVersion = ""
      if ejson["VEVersion"]
        atVersion = "v." + ejson["VEVersion"] + " "
      end
      atVersion = atVersion + "(http://github.com/ging/vish_editor)"

      myxml.general do
        
        if !loId.nil?
          myxml.identifier do
            if loIdIsURI
              myxml.catalog("URI")
            else
              myxml.catalog("URN")
            end
            myxml.entry(loId)
          end
        end

        myxml.title do
          if ejson["title"]
            myxml.string(ejson["title"], loLanOpts)
          else
            myxml.string("Untitled", :language=> metadataLanguage)
          end
        end

        if loLanguage
          myxml.language(loLanguage)
        end
        
        myxml.description do
          if ejson["description"]
            myxml.string(ejson["description"], loLanOpts)
          elsif ejson["title"]
            myxml.string(ejson["title"] + ". A Virtual Excursion provided by " + Vish::Application.config.full_domain + ".", :language=> metadataLanguage)
          else
            myxml.string("Virtual Excursion provided by " + Vish::Application.config.full_domain + ".", :language=> metadataLanguage)
          end
        end
        if ejson["tags"] && ejson["tags"].kind_of?(Array)
          ejson["tags"].each do |tag|
            myxml.keyword do
              myxml.string(tag.to_s, loLanOpts)
            end
          end
        end
        #Add subjects as additional keywords
        if ejson["subject"]
          if ejson["subject"].kind_of?(Array)
            ejson["subject"].each do |subject|
              myxml.keyword do
                myxml.string(subject, loLanOpts)
              end 
            end
          elsif ejson["subject"].kind_of?(String)
            myxml.keyword do
                myxml.string(ejson["subject"], loLanOpts)
            end
          end
        end

        myxml.structure do
          myxml.source("LOMv1.0")
          myxml.value("hierarchical")
        end
        myxml.aggregationLevel do
          myxml.source("LOMv1.0")
          myxml.value("2")
        end
      end

      myxml.lifeCycle do
        myxml.version do
          myxml.string("v"+loDate.gsub("-","."), :language=>metadataLanguage)
        end
        myxml.status do
          myxml.source("LOMv1.0")
          if ejson["vishMetadata"] and ejson["vishMetadata"]["draft"]==="true"
            myxml.value("draft")
          else
            myxml.value("final")
          end
        end

        if !authorName.nil?
          myxml.contribute do
            myxml.role do
              myxml.source("LOMv1.0")
              myxml.value("author")
            end
            authorEntity = generateVCard(authorName)
            myxml.entity(authorEntity)
            
            myxml.date do
              myxml.dateTime(loDate)
              unless _LOMschema == "ODS"
                myxml.description do
                  myxml.string("This date represents the date the author finished the indicated version of the Learning Object.", :language=> metadataLanguage)
                end
              end
            end
          end
        end
        myxml.contribute do
          myxml.role do
            myxml.source("LOMv1.0")
            myxml.value("technical implementer")
          end
          authoringToolName = "Authoring Tool ViSH Editor " + atVersion
          authoringToolEntity = generateVCard(authoringToolName)
          myxml.entity(authoringToolEntity)
        end
      end

      myxml.metaMetadata do
        if !loId.nil? and loIdIsURI and excursion
          myxml.identifier do
            myxml.catalog("URI")
            myxml.entry(Rails.application.routes.url_helpers.excursion_url(:id => excursion.id) + "/metadata.xml")
          end

          if !authorName.nil?
            myxml.contribute do
              myxml.role do
                myxml.source("LOMv1.0")
                myxml.value("creator")
              end

              creatorEntity = generateVCard(authorName)
              myxml.entity(creatorEntity)
              
              myxml.date do
                myxml.dateTime(loDate)
                unless _LOMschema == "ODS"
                  myxml.description do
                    myxml.string("This date represents the date the author finished authoring the metadata of the indicated version of the Learning Object.", :language=> metadataLanguage)
                  end
                end
              end

            end
          end

          myxml.metadataSchema("LOMv1.0")
          myxml.language(metadataLanguage)
        end
      end

      myxml.technical do
        myxml.format("text/html")
        if !loLocation.nil?
          myxml.location(loLocation)
        end
        myxml.requirement do
          myxml.orComposite do
            myxml.type do
              myxml.source("LOMv1.0")
              myxml.value("browser")
            end
            myxml.name do
              myxml.source("LOMv1.0")
              myxml.value("any")
            end
          end
        end
        myxml.otherPlatformRequirements do
          myxml.string("HTML5-compliant web browser", :language=> metadataLanguage)
          if ejson["VEVersion"]
            myxml.string("ViSH Viewer " + atVersion, :language=> metadataLanguage)
          end
        end
      end

      myxml.educational do
        myxml.interactivityType do
          myxml.source("LOMv1.0")
          myxml.value("mixed")
        end

        if !getLearningResourceType("lecture", _LOMschema).nil?
          myxml.learningResourceType do
            myxml.source("LOMv1.0")
            myxml.value("lecture")
          end
        end
        if !getLearningResourceType("presentation", _LOMschema).nil?
          myxml.learningResourceType do
            myxml.source("LOMv1.0")
            myxml.value("presentation")
          end
        end
        if !getLearningResourceType("slide", _LOMschema).nil?
          myxml.learningResourceType do
            myxml.source("LOMv1.0")
            myxml.value("slide")
          end
        end
        #TODO: Explore JSON and include more elements.

        myxml.interactivityLevel do
          myxml.source("LOMv1.0")
          myxml.value("very high")
        end
        myxml.intendedEndUserRole do
          myxml.source("LOMv1.0")
          myxml.value("learner")
        end
        _LOMcontext = readableContext(ejson["context"], _LOMschema)
        if _LOMcontext
          myxml.context do
            myxml.source("LOMv1.0")
            myxml.value(_LOMcontext)
          end
        end
        if ejson["age_range"]
          myxml.typicalAgeRange do
            myxml.string(ejson["age_range"], :language=> metadataLanguage)
          end
        end
        if ejson["difficulty"]
          myxml.difficulty do
            myxml.source("LOMv1.0")
            myxml.value(ejson["difficulty"])
          end
        end
        if ejson["TLT"]
          myxml.typicalLearningTime do
            myxml.duration(ejson["TLT"])
          end
        end
        if ejson["educational_objectives"]
          myxml.description do
              myxml.string(ejson["educational_objectives"], loLanOpts)
          end
        end
        if loLanguage
          myxml.language(loLanguage)                 
        end
      end

      myxml.rights do
        myxml.cost do
          myxml.source("LOMv1.0")
          myxml.value("no")
        end

        myxml.copyrightAndOtherRestrictions do
          myxml.source("LOMv1.0")
          myxml.value("yes")
        end

        myxml.description do
          myxml.string("For additional information or questions regarding copyright, distribution and reproduction, visit " + Vish::Application.config.full_domain + "/legal_notice", :language=> metadataLanguage)
        end

      end
      
    end

    myxml
  end

  def self.getLOMLoLanguage(language, _LOMschema)
    #List of language codes according to ISO-639:1988
    # lanCodes = ["aa","ab","af","am","ar","as","ay","az","ba","be","bg","bh","bi","bn","bo","br","ca","co","cs","cy","da","de","dz","el","en","eo","es","et","eu","fa","fi","fj","fo","fr","fy","ga","gd","gl","gn","gu","gv","ha","he","hi","hr","hu","hy","ia","id","ie","ik","is","it","iu","ja","jw","ka","kk","kl","km","kn","ko","ks","ku","kw","ky","la","lb","ln","lo","lt","lv","mg","mi","mk","ml","mn","mo","mr","ms","mt","my","na","ne","nl","no","oc","om","or","pa","pl","ps","pt","qu","rm","rn","ro","ru","rw","sa","sd","se","sg","sh","si","sk","sl","sm","sn","so","sq","sr","ss","st","su","sv","sw","ta","te","tg","th","ti","tk","tl","tn","to","tr","ts","tt","tw","ug","uk","ur","uz","vi","vo","wo","xh","yi","yo","za","zh","zu"]
    lanCodesMin = I18n.available_locales.map{|i| i.to_s}
    lanCodesMin.concat(["it","pt"]).uniq!

    case _LOMschema
    when "ODS"
      #ODS requires language, and admits blank language.
      if language.nil? or language == "independent" or !lanCodesMin.include?(language)
        return "none"
      end
    else
      #When language=nil, no language attribute is provided
      if language.nil? or language == "independent" or !lanCodesMin.include?(language)
        return nil
      end
    end

    #It is included in the lanCodes array
    return language
  end

  def self.readableContext(context, _LOMschema)
    case _LOMschema
    when "ODS" 
      #ODS LOM Extension
      #According to ODS, context has to be one of ["primary education", "secondary education", "informal context"]
      case context
      when "preschool", "pEducation", "primary education", "school"
        return "primary education"
      when "sEducation", "higher education", "university"
        return "secondary education"
      when "training", "other"
        return "informal context"
      else
        return nil
      end
    when "ViSH"
      #ViSH LOM extension
      case context
      when "unspecified"
        return "Unspecified"
      when "preschool"
        return "Preschool Education"
      when "pEducation"
        return "Primary Education"
      when "sEducation"
        return "Secondary Education"
      when "higher education"
        return "Higher Education"
      when "training"
        return "Professional Training"
      when "other"
        return "Other"
      else
        return context
      end
    else
      #Strict LOM mode. Extensions are not allowed
      case context
      when "unspecified"
        return nil
      when "preschool"
      when "pEducation"
      when "sEducation"
        return "school"
      when "higher education"
        return "higher education"
      when "training"
        return "training"
      else
        return "other"
      end
    end
  end

  def self.getLearningResourceType(lreType, _LOMschema)
    case _LOMschema
    when "ODS"
      #ODS LOM Extension
      #According to ODS, the Learning REsources type has to be one of this:
      allowedLREtypes = ["application","assessment","blog","broadcast","case study","courses","demonstration","drill and practice","educational game","educational scenario","learning scenario","pedagogical scenario","enquiry-oriented activity","exercise","experiment","glossaries","guide","learning pathways","lecture","lesson plan","open activity","other","presentation","project","reference","role play","simulation","social media","textbook","tool","website","wiki","audio","data","image","text","video"]
    else
      allowedLREtypes = ["exercise","simulation","questionnaire","diagram","figure","graph","index","slide","table","narrative text","exam","experiment","problem statement","self assessment","lecture"]
    end

    if allowedLREtypes.include? lreType
      return lreType
    else
      return nil
    end
  end

  def self.generateVCard(fullName)
    return "BEGIN:VCARD&#xD;VERSION:3.0&#xD;N:"+fullName+"&#xD;FN:"+fullName+"&#xD;END:VCARD"
  end


  ####################
  ## IMS QTI 2.1 Management (Handled by the IMSQTI module imsqti.rb)
  ####################

  def self.createQTI(filePath,fileName,qjson)
    require 'imsqti'
    IMSQTI.createQTI(filePath,fileName,qjson)
  end


  ####################
  ## Moodle Quiz XML Management (Handled by the MOODLEXML module moodlexml.rb)
  ####################

  def  self.createMoodleQUIZXML(filePath,fileName,qjson)
    require 'moodlexml'
    MOODLEQUIZXML.createMoodleQUIZXML(filePath,fileName,qjson)
  end


  ####################
  ## Excursion to PDF Management
  ####################

  def to_pdf
    if self.pdf_needs_generate and !Vish::Application.config.APP_CONFIG["selenium"].nil?
      
      remote = (!Vish::Application.config.APP_CONFIG["selenium"]["remote"].blank? and !Vish::Application.config.APP_CONFIG["selenium"]["remoteFolder"].blank?)
      
      vishPdfFolder = "#{Rails.root}/public/pdf/excursions/#{self.id}"
      Dir.mkdir(vishPdfFolder) unless File.exists?(vishPdfFolder) #Create folder if not exists

      if remote
        pdfFolder = Vish::Application.config.APP_CONFIG["selenium"]["remoteFolder"] + "/#{self.id}"
        Dir.mkdir(pdfFolder) unless File.exists?(pdfFolder)
      else
        pdfFolder = vishPdfFolder
      end

      #Selenium save the screenshots in the pdfFolder
      thumbnails = generate_thumbnails(remote,pdfFolder)

      unless thumbnails.nil? or thumbnails.length < 1
        
        ##Generate PDF using RMagick
        # require 'RMagick'
        # pdf = File.open(pdfFolder+"/#{self.id}.pdf", 'w')
        # images = []
        # thumbnails.each do |thumbnail|
        #   images.push(pdfFolder + "/#{thumbnail}")
        # end
        # pdf_image_list = ::Magick::ImageList.new
        # pdf_image_list.read(*images)
        # pdf_image_list.write(pdfFolder + "/#{self.id}.pdf")
        # pdf.close

        ##Generate PDF using ImageMagick
        #Imagemagick command example: convert 785_1.png  785_1_1.png 785_1_2.png 785_1_3.png 984c.pdf
        pdf_file_name = "#{self.id}.pdf"
        image_list = thumbnails.join(" ")
        
        if remote
          system "cd #{pdfFolder}; convert #{image_list} #{pdf_file_name}"
          #Copy file from SeleniumServer to ViSH Server
          system "cp #{pdfFolder}/#{pdf_file_name} #{vishPdfFolder}/#{pdf_file_name}"
        else
          system "cd #{pdfFolder}; convert #{image_list} #{pdf_file_name}"
        end

        self.update_column(:pdf_timestamp, Time.now)
      end
    end
  end

  def generate_thumbnails(remote,pdfFolder)
    thumbnails = []

    return thumbnails if Vish::Application.config.APP_CONFIG["selenium"].nil? or Vish::Application.config.APP_CONFIG["selenium"]["browser"].blank?

    begin
      require 'selenium-webdriver'

      #Set selenium browser and driver
      seleniumBrowser = Vish::Application.config.APP_CONFIG["selenium"]["browser"].downcase.to_sym
      profile = nil
      
      unless Vish::Application.config.APP_CONFIG["selenium"]["profile"].blank?
        #Load a specific profile (https://code.google.com/p/selenium/wiki/RubyBindings#Tweaking_profile_preferences)
        profile = Vish::Application.config.APP_CONFIG["selenium"]["profile"]
      end

      unless remote
        #Local
        unless Vish::Application.config.APP_CONFIG["selenium"]["driver_path"].blank?
          if seleniumBrowser == :chrome
            Selenium::WebDriver::Chrome.path = Vish::Application.config.APP_CONFIG["selenium"]["driver_path"]
          elsif seleniumBrowser == :firefox
            Selenium::WebDriver::Firefox.path = Vish::Application.config.APP_CONFIG["selenium"]["driver_path"]
            profile = Selenium::WebDriver::Firefox::Profile.from_name "default"
          end
        end
        unless profile.nil?
          driver = Selenium::WebDriver.for seleniumBrowser, :profile => profile
        else
          driver = Selenium::WebDriver.for seleniumBrowser
        end
      else
        #Remote
        if seleniumBrowser == :chrome
          capabilities = Selenium::WebDriver::Remote::Capabilities.chrome()
          #Possible capabilities: https://sites.google.com/a/chromium.org/chromedriver/capabilities
          unless Vish::Application.config.APP_CONFIG["selenium"]["driver_path"].blank?
            capabilities[:binary] = Vish::Application.config.APP_CONFIG["selenium"]["driver_path"]
          end
        elsif seleniumBrowser == :firefox
          capabilities = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile)
          unless Vish::Application.config.APP_CONFIG["selenium"]["driver_path"].blank?
            capabilities[:binary] = Vish::Application.config.APP_CONFIG["selenium"]["driver_path"]
          end
        end

        driver = Selenium::WebDriver.for(:remote, :url => Vish::Application.config.APP_CONFIG["selenium"]["remote"], :desired_capabilities => capabilities)
      end


      #Interact with the driver

      excursion_url = self.getUrl + ".full"

      # driver.navigate.to excursion_url
      driver.get excursion_url

      #Specify screenshots dimensions
      width = 775
      height = 1042
      driver.execute_script %Q{ window.resizeTo(#{width}, #{height}); }

      #Hide fullscreen button
      driver.execute_script %Q{ $("#page-fullscreen").hide(); }
      #Hide other elements, not useful or annoying in printed versions
      driver.execute_script %Q{ $("#page-switcher-start, #page-switcher-end").hide(); }
      driver.execute_script %Q{ $(".buttonQuiz").hide(); }
      
      #Disable non-iframe alerts
      driver.execute_script %Q{ window.alert = function(){}; }

      #Get slidesQuantity
      slidesQuantity = driver.execute_script %Q{ 
        return VISH.Slides.getSlidesQuantity();
      }

      #Take a screenshot of each slide
      slidesQuantity.times do |num|
        driver.execute_script %Q{
          VISH.Slides.goToSlide(#{num+1});
        }
        driver.execute_script %Q{ 
          $("article.current").css("display","block");
          $("article").not(".current").css("display","none");
        }

        Selenium::WebDriver::Wait.new(:timeout => 120).until {
          # TODO:// VISH.SlideManager.isSlideLoaded()
          driver.execute_script("return true")
        }
        #Wait a constant period
        sleep 2.5

        #Remove alerts (if present)
        driver.switch_to.alert.accept rescue Selenium::WebDriver::Error::NoAlertOpenError

        driver.save_screenshot(pdfFolder + "/#{self.id}_#{num+1}.png")

        thumbnails.push("#{self.id}_#{num+1}.png");

        isSlideset = driver.execute_script %Q{ 
          return VISH.Slideset.isSlideset(VISH.Slides.getCurrentSlide())
        }

        if isSlideset 
          #Look for subslides
          subslidesIds = (driver.execute_script %Q{ 
            array = []; 
            $(VISH.Slides.getCurrentSlide()).children("article").each(function(index,value){ array.push($(value).attr("id")) }); 
            return array.join(",");
          }).split(",")

          subslidesIds.each_with_index do|sid,index|

            driver.execute_script %Q{ 
              $("#"+"#{sid}").css("display","block");
              VISH.Slides.openSubslide("#{sid}");
            }
            sleep 3.0
            driver.save_screenshot(pdfFolder + "/#{self.id}_#{num+1}_#{index+1}.png")
            thumbnails.push("#{self.id}_#{num+1}_#{index+1}.png");
            driver.execute_script %Q{ 
              VISH.Slides.closeSubslide("#{sid}");
            }
            sleep 0.5
          end
        end

      end

      driver.quit
      return thumbnails

    rescue Exception => e
      begin
        driver.quit
      rescue
      end
      puts e.message
      return nil
    end
  end

  def pdf_needs_generate
    if self.pdf_timestamp.nil? or self.updated_at > self.pdf_timestamp or !File.exist?("#{Rails.root}/public/pdf/excursions/#{self.id}/#{self.id}.pdf")
      return true
    else
      return false
    end
  end

  def remove_pdf
    if File.exist?("#{Rails.root}/public/pdf/excursions/#{self.id}")
      FileUtils.rm_rf("#{Rails.root}/public/pdf/excursions/#{self.id}") 
    end
  end


  ####################
  ## Other Methods
  #################### 

  def afterPublish
    
    #Check if post_activity is public. If not, make it public and update the created_at param.
    post_activity = self.post_activity
    unless post_activity.nil? or post_activity.public?
      #Update the created_at param.
      post_activity.created_at = Time.now
      #Make it public
      post_activity.relation_ids = [Relation::Public.instance.id]
      post_activity.save!
    end

    #Try to infer the language of the excursion if it is not spcifiyed
    if (self.language.nil? or !self.language.is_a? String or self.language=="independent")
      self.inferLanguage
    end

    #If LOEP is enabled, upload the excursion to LOEP
    unless Vish::Application.config.APP_CONFIG['loep'].nil?
      VishLoep.registerActivityObject(self.activity_object) rescue nil
    end
  end

  def inferLanguage
    unless Vish::Application.config.APP_CONFIG["languageDetectionAPIKEY"].nil?
      stringToTestLanguage = ""
      if self.title.is_a? String and !self.title.blank?
        stringToTestLanguage = stringToTestLanguage + self.title + " "
      end
      if self.description.is_a? String and !self.description.blank?
        stringToTestLanguage = stringToTestLanguage + self.description + " "
      end

      if stringToTestLanguage.is_a? String and !stringToTestLanguage.blank?
        
        begin
          detectionResult = DetectLanguage.detect(stringToTestLanguage)
        rescue Exception => e
          detectionResult = []
        end
        
        validLanguageCodes = ["de","en","es","fr","it","pt","ru"]

        detectionResult.each do |result|
          if result["isReliable"] == true
            detectedLanguageCode = result["language"]
            if validLanguageCodes.include? detectedLanguageCode
              lan = detectedLanguageCode
            else
              lan = "ot"
            end

            #Update language
            self.activity_object.update_column :language, lan
            eJson = JSON(self.json)
            eJson["language"] = lan
            self.update_column :json, eJson.to_json
            break
          end
        end
      end
    end
  end

  def clone_for sbj
    return nil if sbj.blank?
    e=Excursion.new
    e.author=sbj
    e.owner=sbj
    e.user_author=sbj.user.actor

    eJson = JSON(self.json)
    eJson["author"] = {name: sbj.name, vishMetadata:{ id: sbj.id}}
    if eJson["contributors"].nil?
      eJson["contributors"] = []
    end
    eJson["contributors"].push({name: self.author.name, vishMetadata:{ id: self.author.id}})
    e.json = eJson.to_json

    e.contributors=self.contributors.push(self.author)
    e.contributors.uniq!
    e.contributors.delete(sbj)
    e.draft=true
    e.save!
    e
  end

  #method used to return json objects to the recommendation in the last slide
  def reduced_json(controller)
      rjson = { 
        :id => id,
        :url => controller.excursion_url(:id => self.id),
        :title => title,
        :author => author.name,
        :description => description,
        :image => thumbnail_url ? thumbnail_url : Vish::Application.config.full_domain + "/assets/logos/original/excursion-00.png",
        :views => visit_count,
        :favourites => like_count,
        :number_of_slides => slide_count
      }
      
      unless self.score_tracking.nil?
        rjson[:recommender_data] = self.score_tracking
        rsEngineCode = TrackingSystemEntry.getRSCode(JSON(rjson[:recommender_data])["rec"])
        unless rsEngineCode.nil?
          rjson[:url] = controller.excursion_url(:id => self.id, :rec => rsEngineCode)
        end
      end

      rjson
  end

  def increment_download_count
    self.activity_object.increment_download_count
  end



  ####################
  ## Quality Metrics
  ####################

  #See app/decorators/social_stream/base/activity_object_decorator.rb
  #Method calculate_qscore


  private

  def parse_for_meta
    parsed_json = JSON(json)

    activity_object.title = parsed_json["title"] ? parsed_json["title"] : "Title"
    activity_object.description = parsed_json["description"] 
    activity_object.tag_list = parsed_json["tags"]
    activity_object.language = parsed_json["language"]

    unless parsed_json["age_range"].blank?
      begin
        ageRange = parsed_json["age_range"]
        activity_object.age_min = ageRange.split("-")[0].delete(' ')
        activity_object.age_max = ageRange.split("-")[1].delete(' ')
      rescue
      end
    end

    if self.draft
      activity_object.scope = 1 #private
    else
      activity_object.scope = 0 #public
    end
    
    original_updated_at = self.updated_at
    activity_object.save!

    #Ensure that the updated_at value of the AO is consistent with the object
    #Prevent admin to modify updated_at values as well.
    self.update_column :updated_at, original_updated_at
    activity_object.update_column :updated_at, original_updated_at

    unless parsed_json["vishMetadata"]
      parsed_json["vishMetadata"] = {}
    end
    parsed_json["vishMetadata"]["id"] = self.id.to_s
    parsed_json["vishMetadata"]["draft"] = self.draft.to_s

    parsed_json["author"] = {name: author.name, vishMetadata:{ id: author.id}}

    self.update_column :json, parsed_json.to_json
    self.update_column :slide_count, parsed_json["slides"].size
    self.update_column :thumbnail_url, parsed_json["avatar"] ? parsed_json["avatar"] : Vish::Application.config.full_domain + "/assets/logos/original/excursion-00.png"
  end

  # Ensure that activity inside the activity_object is not nil. Social Stream does not guarantee this 100%.
  def fix_post_activity_nil
    if self.post_activity == nil
      a = Activity.new :verb         => "post",
                       :author_id    => self.activity_object.author_id,
                       :user_author  => self.activity_object.user_author,
                       :owner        => self.activity_object.owner,
                       :relation_ids => self.activity_object.relation_ids,
                       :parent_id    => self.activity_object._activity_parent_id

      a.activity_objects << self.activity_object

      a.save!
    end
  end
  
end
