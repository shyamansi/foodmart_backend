class ChangeCategoryNameTypeInProducts < ActiveRecord::Migration[7.2]
  def change
    change_column :products,:category_name,:text
  end
end
