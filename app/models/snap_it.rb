class SnapIt < ActiveRecord::Base
  include Dateable
  include Searchable
  include ActivityFeedable

  searchable_fields :title, :description

  activity_feedable_user_methods :user
  activity_feedable_actions :create  


  belongs_to :user
  belongs_to :snap_it_language
  belongs_to :snap_it_theme
  has_one :photo, :as => :attachable, :dependent => :destroy
  has_many :comments, as: :parent, :dependent => :destroy
  has_many :likes, as: :parent, :dependent => :destroy
  has_many :taggings, :as => :taggable
  has_many :tags, :through => :taggings

  validates :title,
            :presence => true

  validates :description,
            :length => { :maximum => 512 },
            :presence => true

  validates :body,
            :presence => true

  validates :user,
            :presence => true

  validates :snap_it_language,
            :presence => true

  validates :snap_it_theme,
            :presence => true


  accepts_nested_attributes_for :photo

  after_create :create_tags


  def self.new_from_token(token)
    snap_it_proxy = SnapItProxy.find_by_token(token)
    if snap_it_proxy
      new({
        :title => snap_it_proxy.title,
        :description => snap_it_proxy.description,
        :body => snap_it_proxy.body,
        :font_size => snap_it_proxy.font_size,
        :wrap_limit => snap_it_proxy.wrap_limit,
        :photo_attributes => { 
          :file => snap_it_proxy.image_data_to_image_file
        },
        :user_id => snap_it_proxy.user.id,
        :snap_it_language_id => snap_it_proxy.snap_it_language_id,
        :snap_it_theme_id => snap_it_proxy.snap_it_theme_id
      })
    else
      new
    end
  end


  def create_tags
    tag_names = description.scan(/.?#[A-Za-z_0-9]+/)
      .map { |tag| tag.strip }
      .reject { |tag| tag.chars.first != '#' }
      .map { |tag| tag[1..-1] }
    tag_names += [snap_it_theme.editor_name, snap_it_language.editor_name]
    tag_names.each do |tag_name|
      tag = Tag.find_or_create_by!(
        :name => tag_name
      )
      taggings.find_or_create_by!(
        :tag => tag
      )
    end
  end
end





