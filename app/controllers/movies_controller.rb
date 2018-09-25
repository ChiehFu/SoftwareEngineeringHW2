class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def index
    @checked_item = []
    if request.path == '/movies/title'
      @movies = Movie.all.order(:title)
      @path1 = '/movies'
      @path2 = '/movies/release'
    elsif 
      request.path == '/movies/release'
      @movies = Movie.all.order(:release_date)
      @path1 = '/movies/title'
      @path2 = '/movies'
    else
      hash = params["ratings"];
      if (hash.nil?)
        @movies = Movie.all
      elsif
        array = hash.keys
        @movies = Movie.where(rating: array)
        @checked_item = array
      end
      @path1 = '/movies/title'
      @path2 = '/movies/release'
    end
    @all_ratings = Movie.distinct.pluck(:rating)
  end
  
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
