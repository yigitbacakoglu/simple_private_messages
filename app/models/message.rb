class Message < ActiveRecord::Base


  validates_presence_of :sender_id, :receiver_id, :body
  belongs_to :sender, :class_name => "User"
  belongs_to :receiver, :class_name => "User"

  belongs_to :conversation


  def self.unread
    where("read_at IS NULL")
  end

  def self.not_deleted(user)
    where("(sender_id = ? AND sender_deleted_at IS NULL) OR (receiver_id = ? AND receiver_deleted_at IS NULL)", user.id, user.id)
  end

  def deleted_by?(user)
    (self.sender == user && !self.sender_deleted_at.blank?) || (self.receiver == user && !self.receiver_deleted_at.blank?)
  end

  def delete_for(user)
    key = user_type(user)
    if key.present?
      self.update_attribute("#{key}_deleted_at", Time.now)
    end
  end

  def user_type(user)
    return "sender" if user.id == sender_id
    return "receiver" if user.id == receiver_id
    nil
  end

  def is_read?
    !self.read_at.blank?
  end


end
