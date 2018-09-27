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
    rank_hash = params["ratings"]
    if (!rank_hash.nil?)   
      key_hash = rank_hash.keys
      @checked_item = []
      @all_ratings.each do |rank|
        if (key_hash.include?(rank))
          session[rank.to_sym] = true
          @checked_item.push(rank.to_sym)
        else
          session[rank.to_sym] = false
        end
      end
      if !params["commit"].nil? && params["commit"] = "Refresh"
        flash.keep
        redirect_to movies_path
      end
      @method = []
      if (!params["title"].nil?)
        @method = [:title]
      elsif (!params["release_date"].nil?)
        @method = [:release_date]
      end
      @movies = Movie.where(rating: @checked_item).order(@method)
    else
      redir_add = "?"
      @all_ratings.each do |rank|
        if (session[rank.to_sym] == true)
          redir_add += "&ratings[#{rank}]=true"
        end
      end
      
      if !params["title"].nil?
        if session[:title] == true
          session[:title] = false
        else
          session[:title] = true
          session[:release_date] = false
        end
      elsif !params["release_date"].nil?
        if session[:release_date] == true
          session[:release_date] = false
        else
          session[:release_date] = true
          session[:title] = false
        end
      end
      
      if session[:title] == true
        redir_add += "&title=true"
      elsif session[:release_date] == true
        redir_add += "&release_date=true"
      end
      flash.keep
      redirect_to movies_path + URI.encode(redir_add)
    end
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
