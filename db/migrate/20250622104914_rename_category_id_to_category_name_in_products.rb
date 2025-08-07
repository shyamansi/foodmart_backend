class RenameCategoryIdToCategoryNameInProducts < ActiveRecord::Migration[7.2]
  def change
    rename_column :products ,:category_id, :category_name
  end
end
