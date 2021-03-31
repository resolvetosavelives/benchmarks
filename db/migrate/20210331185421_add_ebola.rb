class AddEbola < ActiveRecord::Migration[6.1]
  def change
    Disease.seed!
  end
end
