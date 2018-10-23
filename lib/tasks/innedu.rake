# encoding: utf-8

namespace :innedu do

  #Usage
  #Development:   bundle exec rake innedu:report
  #In production: bundle exec rake innedu:report RAILS_ENV=production
  task :report => :environment do
    require "#{Rails.root}/lib/task_utils"

    filePath = "reports/innedu.xlsx"
    printTitle("EducaInternet report: " + filePath)
    prepareFile(filePath)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Recursos EducaInternet") do |sheet|
        rows = []
        rows << ["Titulo","Edad","Tematica","Tipo","Descripcion","Autor", "Autor URL", "Licencia","Idioma", "Popularidad", "Visualizaciones", "Favoritos", "Descargas", "Quality score", "URL"]

        ActivityObject.getAllPublicResources().each do |ao|
          puts "Saving resource " + ao.id.to_s
          if ao.license.nil?
            puts "Has nil license"
            ao.license = License.find(9) #private if nil
          end
          rows << [ao.title, "Age: " + ao.age_min.to_s + "-"+ ao.age_max.to_s, ao.tags.join(","), ao.object_type, ao.description, ao.author.name, "http://educainternet.es/"+ao.author.slug, ao.license.key, ao.language, ao.popularity, ao.visit_count, ao.like_count, ao.download_count, ao.reviewers_qscore, ao.getUrl]
        end

        rows.each do |row|
          sheet.add_row row
        end
      end
      p.serialize(filePath)
    end

    printTitle("Task Finished")
  end

end
