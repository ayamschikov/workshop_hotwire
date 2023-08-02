class ArtistsController < ApplicationController
  MAX_LIMIT = 10
  DEFAULT_LIMIT = 5

  def show
    artist = Artist.find(params[:id])
    albums = selected_albums(artist.albums, params[:album_type]).with_attached_cover.preload(:artist)
    tracks = artist.tracks.popularity_ordered.limit(limit).offset(offset)
    tracks_count = artist.tracks.count
    show_load_more = tracks_count > offset + limit

    if turbo_frame_request?
      case turbo_frame_request_id
      when /popular_tracks/
        render partial: "popular_tracks", locals: {artist:, tracks:, show_load_more:, limit:, offset:}
      when /discography/
        render partial: "discography", locals: {artist:, albums:}
      end
    else
      render action: :show, locals: {artist:, albums:, tracks:, show_load_more:, offset:, limit:}
    end
  end

  private

  def selected_albums(albums, album_type)
    return albums.lp if album_type.blank?

    return albums.lp unless Album.kinds.key?(album_type)

    albums.where(kind: album_type)
  end

  def offset
    params[:offset].to_i || 0
  end

  def limit
    if params[:limit].to_i.positive?
      [MAX_LIMIT, params[:limit].to_i].max
    else
      DEFAULT_LIMIT
    end
  end
end
