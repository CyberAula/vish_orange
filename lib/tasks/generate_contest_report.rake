# encoding: utf-8

namespace :contest do

  #Usage
  #Development:   bundle exec rake contest:report
  #In production: bundle exec rake contest:report RAILS_ENV=production
  task :report => :environment do
    require "#{Rails.root}/lib/task_utils"

    filePath = "reports/contest-enrolled-"+Time.now.strftime('%Y-%m-%d_%H-%M')+".xlsx"
    printTitle("Generating contest report to file: " + filePath)
    prepareFile(filePath)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Usuarios apuntados al concurso") do |sheet|
        rows = []
        rows << ["Nombre de usuario","Email","Twitter","Provincia","Código postal","Nombre de la escuela", "Asignatura","Número de teléfono"]
        c = Contest.last
        Contest.last.enrolled_participants.map do |a|
          j = JSON.parse(a.contest_enrollments.first.settings)
          rows << [a.name, a.email, j["additional_fields"]["twitter"],j["additional_fields"]["province"],j["additional_fields"]["postal_code"], j["additional_fields"]["school_name"], j["additional_fields"]["teaching_subject"], j["additional_fields"]["phone_number"]  ]
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
