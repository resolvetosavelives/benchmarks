class ReseedAssessments < ActiveRecord::Migration[7.0]
  def up
    ActiveRecord::Base.connection.exec_query(
      "TRUNCATE \"public\".\"assessments\" CASCADE"
    )
    Assessment.seed!
  end
end
