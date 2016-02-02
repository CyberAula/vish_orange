#ruby '2.2.0'
source 'http://rubygems.org'

gem 'rails', :git => 'git://github.com/rails/rails.git', :branch => "3-2-stable"

#Database Adapters
gem 'sqlite3', '= 1.3.9'
gem 'pg', '= 0.17.1'
gem 'mysql2', '= 0.3.16'

gem 'sass-rails', '= 3.2.6'
gem 'bootstrap-sass', '= 3.1.1.0'

gem 'coffee-rails', '= 3.2.2'
gem 'uglifier', '= 1.2.3'
gem 'jquery-rails', '= 3.1.0'
gem 'jquery-ui-rails', '= 4.1.2'
gem 'json', '= 1.8.1'
gem 'sinatra', '= 1.3.2'
gem 'selenium-webdriver', '= 2.44.0'
gem 'god', :git => 'git://github.com/mojombo/god.git', :ref => 'a0602dda2e767f2b711e37bf2d4199c0614af480'
gem 'redis', '= 3.0.7'
gem 'resque', '= 1.23.1'
gem 'rmagick', '=2.13.2'
gem 'thinking-sphinx', '= 2.0.14'
gem 'exception_notification', '= 4.1.1'
gem 'rspec-rails', '= 2.9'
gem 'net-ssh', '= 2.4.0'
gem 'shortener', '= 0.3.0'
gem 'rubyzip', '= 1.0.0'
gem 'pry', '= 0.9.12.6'
gem 'rest-client', '= 1.6.7'
gem 'pdf-reader', '= 1.3.3'
gem 'avatars_for_rails', '= 1.1.4'
gem 'axlsx', '= 2.0.1' #xlsx generation
gem 'axlsx_rails', '= 0.1.5'
gem 'acts_as_xlsx', :git => 'git://github.com/randym/acts_as_xlsx.git', :ref => '919817e590b1cf8e27632e630469603c78a50402'
gem "paperclip", '= 3.5.1'
gem "delayed_paperclip", "= 2.7.0"
gem 'sanitize', '= 2.1.0'
gem 'mailboxer', '= 0.10.3'
gem 'hashie', '= 2.1.2'
gem 'detect_language', '=1.0.5'
gem 'faker', '= 1.4.3'
gem 'acts-as-taggable-on', '= 2.4.1'
gem 'test-unit', '= 3.0.9'
gem 'sitemap_generator'
gem 'descriptive_statistics', '~> 2.4.0', :require => 'descriptive_statistics/safe'

#Gems from Git repositories
gem 'simple_captcha', :git => 'git://github.com/galetahub/simple-captcha.git', :ref => '2602bf1'
gem 'delegates_attributes_to', :git => 'git://github.com/pahanix/delegates_attributes_to.git', :ref => '69704cb'
gem "oai_repository", :git => 'git://github.com/ebarra/oai_repository.git'
gem 'paperclip-ffmpeg', :git => 'git://github.com/ebarra/paperclip-ffmpeg.git'

#Customized/Local Gems
# $ export FORCE_LOCAL_SS=socialStreamPath
if ENV['FORCE_LOCAL_SS'] 
  path ENV['FORCE_LOCAL_SS'] do
    gem 'social_stream-base'
    gem 'social_stream-documents'
    gem 'social_stream-linkser'
    gem 'social_stream-ostatus'
    gem 'social_stream-events'
  end
else
  git 'git://github.com/ging/social_stream.git', branch: "vish", ref: "9fdcec65f4bdfe48e0142e2ee51e52459c33a43c"  do
    gem 'social_stream-base'
    gem 'social_stream-documents'
    gem 'social_stream-linkser'
    gem 'social_stream-ostatus'
    gem 'social_stream-events'
  end
end

#for INVITATION ONLY
gem 'devise_invitable', '= 1.1.8'
gem 'devise_cas_authenticatable'

# $ export FORCE_LOCAL_SCORM=scormGemPath
if ENV['FORCE_LOCAL_SCORM']
  gem "scorm", :path => ENV['FORCE_LOCAL_SCORM'], :branch => "master"
else
  gem "scorm", :git => 'git://github.com/agordillo/scorm.git', :branch => "master"
end


#Development & Test gems

group :development do
  # Use unicorn as the web server
  #Usage bundle exec unicorn -p 3000 -c config/unicorn.rb
  gem 'unicorn', '= 4.8.3'
  gem 'capistrano', '= 2.14.2'
  gem 'forgery', '= 0.6.0'
end

group :test do
  # Pretty printed test output
  gem 'factory_girl', '= 2.6'
  gem 'capybara', '= 2.3.0'
end
