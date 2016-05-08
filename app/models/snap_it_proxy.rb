class SnapItProxy < ActiveRecord::Base
  END_POINT = ENV['TARGET_URL']

  belongs_to :user
  belongs_to :snap_it_language
  belongs_to :snap_it_theme

  before_create :create_token
  after_create :clean_up


  def create_image_data
    response = ScreenshotAPI.get_base64(build_url)
    update!(:image_data => response)
  end


  private
  def clean_up
    SnapItProxy.where(:user_id => user_id)
      .where('id != ?', id)
      .destroy_all
  end


  def create_token
    str = "#{user_id}@#{Time.now} #{Time.now.usec}"
    hash = Digest::MD5.new.hexdigest(str)
    self.token = hash
  end


  def build_url
    [
      END_POINT,
      '?',
      'token',
      '=',
      token
    ].join
  end
end
