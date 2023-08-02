class Artists::TracksController < ApplicationController
  include Pagy::Backend

  def index
    pagy, tracks = pagy(tracks_scope)

    if turbo_frame_request?
      render partial: "tracks", locals: {artist:, tracks:, pagy:}
    else
      render action: :index, locals: {artist:, tracks:, pagy:}
    end
  end

  private

  def artist
    @artist ||= Artist.find(params[:artist_id])
  end

  def tracks_scope
    @tracks_scope ||= artist.tracks.popularity_ordered
  end
end
