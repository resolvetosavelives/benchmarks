class AddWhoColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :access_reason, :string
    add_column :users, :affiliation, :string
    add_column :users, :country_alpha3, :string, limit: 3
    add_column :users, :institution, :string
    add_column :users, :status, :string

    add_foreign_key :users,
                    :countries,
                    column: "country_alpha3",
                    primary_key: "alpha3"
    add_index :users, :country_alpha3
  end
end
