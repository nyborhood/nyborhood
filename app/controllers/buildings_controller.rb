class BuildingsController < ApplicationController

  def index
    @buildings = Building.limit(1000)
    respond_to do |format|
      format.html
      format.csv { render text: @buildings.to_csv }
    end
  end
end

# def index
  # @buildings = Building.search(params[:search])
# end