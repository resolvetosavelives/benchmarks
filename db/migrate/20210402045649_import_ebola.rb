class ImportEbola < ActiveRecord::Migration[6.1]
  def up
    Disease.seed!
    BenchmarkIndicatorAction.seed_ebola_actions!
  end
end
