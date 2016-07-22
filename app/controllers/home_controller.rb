class HomeController < ApplicationController
  def index
  end

  def new
    @url = params[:q]
    @request = Request.create(url: @url)
    if @request.invalid?
      render :index and return
    end
    request_type = determine_type

    if request_type
      @scraper = request_type.new
      @scraper.url = @url
      message = @scraper.scrape
    else
      flash.now[:error] = "That site is not currently supported."
      render :index and return
    end

    flash.now[:notice] = message
    render :index
  end



  private
  def request_params
    params.require(:q)
  end

  def determine_type
    @valid_domains = {"fanfiction.net" => FFNScraper}
    @valid_domains.each_key do |domain|
      if @url.include?(domain)
        return @valid_domains[domain]
      else
        return nil
      end
    end
  end
end
