
class HomeController < ApplicationController
  require 'open-uri'

  def index
    @canonical = "http://omnibuser.com"
  end

  def download
    begin
      @doc = Document.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    end
    if @doc
      open(@doc.path, 'wb') do |file|
        file << open(@doc.aws_url).read
      end
      send_file(@doc.path)
    else
      redirect_to root_path
    end
  end

  def status
    request = Request.find(params[:id])
    respond_to do |format|
      format.json {render json: request.to_json, status: :ok}
    end
  end

  def scrape
    puts "begin scrape"
    respond_to do |format|
      begin
        @request = Request.find(params[:id])
        @request.update(complete: false, status: "In Progress")
        Resque.enqueue(Scraper, @request.id)
        format.json {render json: @request, status: :ok}
      rescue ScraperError => e
        @request.update(complete: true, status: e)
        format.json {render json: @request, status: 422}
      rescue Exception => e
        @request.update(complete: true, status: "Sorry, something went wrong.")
        format.json {render json: @request, status: 422}
        raise e
      end
    end
  end

  def new
    @request = Request.create(url: params[:q], extension: params[:ext],  status: "Initializing")
    respond_to do |format|
      format.json {render json: @request.to_json, status: :created}
    end
  end

  private
  def request_params
    params.require(:q, :ext)
  end

end
