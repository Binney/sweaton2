class AddApprovalTickToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :approved, :boolean, default: 0
  end
end
