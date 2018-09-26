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
    @all_ratings = Movie.distinct.pluck(:rating)
    @sort_method = [:title, :release_date]
    
    if session[:second].nil?
      session[:second] = true
      #initialize session
      @sort_method.each do |m|
        session[m.to_sym] = false
      end
      
      @all_ratings.each do |rank|
        session[rank.to_sym] = true
      end
    end
    
    #get params and update session
    hash = params["ratings"]
    if (!hash.nil?) 
      array = hash.keys
      @all_ratings.each do |rank|
        if (array.include?(rank))
          session[rank.to_sym] = true
        else
          session[rank.to_sym] = false
        end
      end
    end
    
    #update session for sorting methods
    if request.path == '/movies/title'
      session[:title] = !(session[:title])
      session[:release_date] = false
    elsif request.path == '/movies/release'
      session[:title] = false
      session[:release_date] = !session[:release_date]
    end
    
    #get checked item from session
    @checked_item = []
    @all_ratings.each do |rank|
      if session[rank.to_sym] == true
        @checked_item.push(rank)
      end
    end
    
    #get sorting method from session
    @method = []
    @sort_method.each do |m|
      if session[m.to_sym] == true
        @method.push(m)
      end
    end
    
    @movies = Movie.where(rating: @checked_item).order(@method)
    @path1 = '/movies/title'
    @path2 = '/movies/release'
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
