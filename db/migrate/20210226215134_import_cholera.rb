class ImportCholera < ActiveRecord::Migration[5.2]
  def up
    Disease.seed!
    BenchmarkIndicatorAction.seed_cholera_actions!
  end
end
