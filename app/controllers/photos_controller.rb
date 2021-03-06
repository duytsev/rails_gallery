class PhotosController < ApplicationController
  before_action :require_login, only: :download

  def index
    @photos = Photo.paginate(page: params[:page]).order('id ASC')
    session[:last_photo_page] = photos_url
  end

  def edit
    @photo = Photo.find(params[:id])
  end

  def download
    @photo = Photo.find(params[:id])
    if Rails.env.development? || Rails.env.test?
      send_file @photo.image.file.file, disposition: :attachment
    elsif Rails.env.production
      data = open(@photo.image.file.url)
      send_data data.read, filename: @photo.image.to_s, disposition: :attachment
    end
  end

  def new
    @photo = Photo.new
  end

  def create

  end

  def update
    @photo = Photo.find(params[:id])
    if @photo.update(photo_params)
      flash[:success] = 'Описание к изображению сохранено'
      redirect_to edit_photo_path
    else
      render 'edit'
    end
  end

  def nodesc
    @photos = Photo.nodesc.paginate(page: params[:page]).order('id ASC')
    session[:last_photo_page] = nodesc_photos_path
  end

  private

  def photo_params
    params.require(:photo).permit({category_ids: []}, :tag_list)
  end
end
