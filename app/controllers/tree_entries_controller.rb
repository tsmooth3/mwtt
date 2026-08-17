class TreeEntriesController < ApplicationController
  before_action :set_tree_entry, only: [ :show, :edit, :update, :destroy ]

  def index
    @all_seasons = Season.order(year: :desc)
    @current_season = selected_season
    @is_family_admin = current_family && current_user.family_admin?(current_family)
    @filter = params[:filter].presence || "collections"

    @tree_entries = apply_filter(visible_entries)
  end

  def new
    @tree_entry = TreeEntry.new
    @tree_entry.entry_date = default_entry_date
    @tree_entry.family = current_family
    @tree_entry.location_id = params[:location_id] if params[:location_id].present?
    @prefill_lat = params[:lat]
    @prefill_lng = params[:lng]
    prepare_form
  end

  def create
    @tree_entry = TreeEntry.new(tree_entry_params)
    @tree_entry.user = current_user
    assign_default_family(@tree_entry)
    attach_location(@tree_entry)

    if @tree_entry.save
      redirect_to tree_entries_path, notice: "Entry logged successfully!"
    else
      prepare_form
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    prepare_form
  end

  def update
    @tree_entry.assign_attributes(tree_entry_params)
    assign_default_family(@tree_entry)
    attach_location(@tree_entry)

    if @tree_entry.save
      redirect_to @tree_entry, notice: "Entry updated successfully!"
    else
      prepare_form
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tree_entry.destroy
    redirect_to tree_entries_path, notice: "Entry deleted successfully!"
  end

  def show
  end

  private

  def visible_entries
    if @is_family_admin
      TreeEntry.for_season(@current_season).recent
    elsif current_family
      TreeEntry.where(family: current_family).or(TreeEntry.where(user: current_user)).recent
    else
      TreeEntry.where(user: current_user).recent
    end
  end

  def apply_filter(scope)
    case @filter
    when "scouting"
      scope.scouting
    when "all"
      scope
    else
      scope.collections
    end
  end

  def set_tree_entry
    @tree_entry = TreeEntry.find(params[:id])
    is_admin = current_family && current_user.family_admin?(current_family)
    unless is_admin || @tree_entry.user == current_user
      redirect_to tree_entries_path, alert: "Not authorized"
    end
  end

  def tree_entry_params
    permitted = params.require(:tree_entry).permit(:entry_date, :seen, :collected, :family_id, :location_id)
    permitted[:family_id] = nil if permitted[:family_id].blank?
    permitted[:location_id] = nil if permitted[:location_id].blank?
    permitted[:seen] = nil if permitted[:seen].blank?
    permitted
  end

  def location_params
    params.require(:tree_entry).permit(:latitude, :longitude, :location_name, :location_id)
  end

  def assign_default_family(entry)
    return if entry.family_id.present?
    return unless current_family
    return unless entry.collected.to_i.positive?

    entry.family = current_family
  end

  def attach_location(entry)
    extras = params[:tree_entry] || {}
    if extras[:location_id].present?
      entry.location = Location.visible.find_by(id: extras[:location_id])
      return
    end

    latitude = extras[:latitude].presence
    longitude = extras[:longitude].presence
    if latitude.blank? || longitude.blank?
      entry.location = nil
      return
    end

    entry.location = Location.new(
      latitude: latitude,
      longitude: longitude,
      name: extras[:location_name].presence,
      creator: current_user
    )
  end

  def prepare_form
    @current_season = Season.current
    @families = Family.all.order(:name)
    @selected_location = @tree_entry.location
    @nearby_locations = if @selected_location
      Location.nearby(@selected_location.latitude, @selected_location.longitude).where.not(id: @selected_location.id)
    else
      Location.none
    end
  end

  def selected_season
    if params[:season_id].present?
      Season.find_or_create_by_year(params[:season_id].to_i)
    else
      Season.current
    end
  end

  def default_entry_date
    Date.current
  end
end
