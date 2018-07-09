class AddElabUrlFiles < ActiveRecord::Migration
  def change
  	create_table "elab_url_files" do |t|
      t.text "name", :default => "{}"
    end
  end
end
