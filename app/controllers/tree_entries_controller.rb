class TreeEntriesController < ApplicationController
  before_action :set_tree_entry, only: [:show, :edit, :update, :destroy]

  def index
    @current_season = Season.find_or_create_by_year(Date.current.year)
    @is_family_admin = current_family && current_user.family_admin?(current_family)
    
    if @is_family_admin
      # Family admins see all entries for the current season
      @tree_entries = TreeEntry.for_season(@current_season).recent
      @my_entries = TreeEntry.where(user: current_user).recent
      @family_entries = current_family ? TreeEntry.where(family: current_family).recent : []
    elsif current_family
      # Regular users see their family's entries
      @my_entries = TreeEntry.where(user: current_user).recent
      @family_entries = TreeEntry.where(family: current_family).recent
      @tree_entries = @family_entries
    else
      # If no family, just show user's entries
      @my_entries = TreeEntry.where(user: current_user).recent
      @family_entries = []
      @tree_entries = @my_entries
    end
  end

  def new
    @tree_entry = TreeEntry.new
    @tree_entry.entry_date = Date.current
    @tree_entry.family = current_family # Default to user's current family if they have one
    @current_season = Season.find_or_create_by_year(Date.current.year)
    @families = Family.all.order(:name) # All families available for selection
  end

  def create
    @tree_entry = TreeEntry.new(tree_entry_params)
    @tree_entry.user = current_user
    
    # Family is selected from the form via family_id
    # If no family_id provided, default to current_family if user has one
    if @tree_entry.family_id.blank? && current_family
      @tree_entry.family = current_family
    end
    
    # Validate that a family is selected
    unless @tree_entry.family
      @tree_entry.errors.add(:family, "must be selected")
      @current_season = Season.find_or_create_by_year(Date.current.year)
      @families = Family.all.order(:name)
      render :new, status: :unprocessable_entity
      return
    end
    
    # Auto-associate with season based on entry date
    year = @tree_entry.entry_date.year
    @tree_entry.season = Season.find_or_create_by_year(year)
    
    if @tree_entry.save
      redirect_to tree_entries_path, notice: 'Tree entry created successfully!'
    else
      @current_season = Season.find_or_create_by_year(Date.current.year)
      @families = Family.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @families = Family.all.order(:name)
  end

  def update
    if @tree_entry.update(tree_entry_params)
      # Update season if date changed
      year = @tree_entry.entry_date.year
      @tree_entry.season = Season.find_or_create_by_year(year)
      @tree_entry.save
      
      redirect_to @tree_entry, notice: 'Tree entry updated successfully!'
    else
      @families = Family.all.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Authorization is already checked in set_tree_entry
    @tree_entry.destroy
    redirect_to tree_entries_path, notice: 'Tree entry deleted successfully!'
  end

  def show
  end

  private

  def set_tree_entry
    @tree_entry = TreeEntry.find(params[:id])
    # Allow family admins to edit any entry, or users to edit their own entries
    is_admin = current_family && current_user.family_admin?(current_family)
    unless is_admin || @tree_entry.user == current_user
      redirect_to tree_entries_path, alert: 'Not authorized'
    end
  end

  def tree_entry_params
    params.require(:tree_entry).permit(:entry_date, :tree_count, :family_id)
  end
end
